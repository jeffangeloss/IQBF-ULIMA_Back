"""Autorizaciones de uso y excepciones — US-023 a US-029.

Dos decisiones que conviene no deshacer:

1. **El saldo autorizado no se guarda en ninguna columna.** Se recalcula desde
   el kardex en cada consulta (`v_autorizacion_saldo`). Un saldo almacenado se
   queda rancio en cuanto entra un movimiento por otra vía, y aquí hay varias:
   la API, el cargador del censo y las correcciones por SQL.

2. **Exigir autorización es una decisión del establecimiento**, no una
   constante del programa (`establecimiento.exige_autorizacion`). Nace apagado:
   encenderlo con cero autorizaciones cargadas dejaría al laboratorio sin poder
   registrar nada, y un control que obliga a saltárselo el primer día no es un
   control.
"""

import hashlib
from datetime import date
from decimal import Decimal, InvalidOperation
from typing import Annotated, Any, Literal

from fastapi import APIRouter, Depends, File, Query, Response, UploadFile, status
from psycopg import Connection

from app.contracts import Page
from app.dependencies import get_connection, get_current_user, require_roles
from app.errors import ProblemException
from app.modules.auth.schemas import CurrentUser
from app.modules.autorizaciones.schemas import (
    AutorizacionCreate,
    AutorizacionOut,
    AutorizacionUpdate,
    DocumentoOut,
    ExcepcionCreate,
    ExcepcionOut,
    ExcepcionResolver,
)


router = APIRouter(prefix="/api", tags=["Autorizaciones y excepciones"])

ROLES_MANTIENE = ("RESPONSABLE_IQBF",)
ROLES_APRUEBA = ("APROBADOR", "RESPONSABLE_IQBF")

#: US-024. Un oficio es un PDF o una imagen escaneada. Nada ejecutable.
MIMES_PERMITIDOS = {
    "application/pdf": ".pdf",
    "image/jpeg": ".jpg",
    "image/png": ".png",
}
TAMANO_MAXIMO = 10 * 1024 * 1024

FACTOR_G = {"g": Decimal(1), "kg": Decimal(1000)}
FACTOR_ML = {"mL": Decimal(1), "L": Decimal(1000)}

_COLUMNAS = """
    s.id_autorizacion, s.codigo, s.id_investigador, s.titular, s.id_insumo,
    s.nombre_comercial, s.id_presentacion, s.id_establecimiento,
    s.id_laboratorio, s.laboratorio, s.cantidad_autorizada_g,
    s.cantidad_registrada, s.unidad_registrada, s.consumido_g, s.disponible_g,
    s.disponible_kg, s.vigencia_desde, s.vigencia_hasta, s.estado_registro,
    s.estado_efectivo, s.motivo_revocacion, s.observaciones, s.documentos
"""


def _a_gramos(
    connection: Connection, cantidad: Decimal, unidad: str, id_insumo: str
) -> tuple[Decimal, Decimal | None]:
    """Convierte a la unidad canónica. Devuelve (gramos, densidad usada)."""
    if unidad in FACTOR_G:
        return (cantidad * FACTOR_G[unidad]).quantize(Decimal("0.0001")), None

    # Un volumen necesita densidad, y la densidad es del insumo. Si el insumo
    # tiene varias presentaciones con densidades distintas, autorizar en
    # volumen es ambiguo: se exige gramos o kilos.
    densidades = connection.execute(
        """
        SELECT DISTINCT COALESCE(p.densidad, dv.valor) AS densidad
          FROM presentacion p
          LEFT JOIN LATERAL (
                SELECT valor FROM densidad_vigencia d
                 WHERE d.id_presentacion = p.id_presentacion
                   AND d.vigencia_hasta IS NULL
                 ORDER BY d.vigencia_desde DESC LIMIT 1
          ) dv ON TRUE
         WHERE p.id_insumo = %s AND COALESCE(p.densidad, dv.valor) IS NOT NULL
        """,
        (id_insumo,),
    ).fetchall()
    valores = {row["densidad"] for row in densidades}
    if len(valores) != 1:
        raise ProblemException(
            422,
            "DENSIDAD_REQUERIDA",
            "No se puede autorizar en volumen",
            f"El insumo '{id_insumo}' tiene {len(valores)} densidades distintas "
            "entre sus presentaciones: autorice la cantidad en gramos o kilos.",
            field="unidad",
        )
    densidad = valores.pop()
    gramos = cantidad * FACTOR_ML[unidad] * Decimal(densidad)
    return gramos.quantize(Decimal("0.0001")), Decimal(densidad)


def _obtener(connection: Connection, id_autorizacion: int) -> AutorizacionOut:
    row = connection.execute(
        f"SELECT {_COLUMNAS} FROM v_autorizacion_saldo s WHERE s.id_autorizacion = %s",
        (id_autorizacion,),
    ).fetchone()
    if row is None:
        raise ProblemException(
            404, "REGISTRO_NO_EXISTE", "Autorización inexistente",
            f"No existe la autorización {id_autorizacion}.",
        )
    return AutorizacionOut(**row)


@router.get(
    "/autorizaciones",
    response_model=Page[AutorizacionOut],
    summary="Consultar autorizaciones y saldos (US-026)",
)
def listar(
    connection: Annotated[Connection, Depends(get_connection)],
    user: Annotated[CurrentUser, Depends(get_current_user)],
    titular: Annotated[int | None, Query()] = None,
    insumo: Annotated[str | None, Query(max_length=20)] = None,
    estado: Annotated[str | None, Query()] = None,
    page: Annotated[int, Query(ge=1)] = 1,
    page_size: Annotated[int, Query(ge=1, le=100)] = 20,
) -> Page[AutorizacionOut]:
    """US-026. «Mis autorizaciones» para quien no mantiene maestros.

    Una cuenta sin alcance global ve solo las suyas. No es un adorno: la
    cantidad autorizada a un investigador es información suya.
    """
    condiciones: list[str] = []
    params: list[Any] = []

    if not user.alcance_global and not set(user.roles) & set(ROLES_MANTIENE):
        condiciones.append(
            "s.id_investigador IN ("
            "  SELECT i.id_investigador FROM investigador i"
            "   WHERE normalizar_busqueda(i.nombre) = normalizar_busqueda(%s)"
            "      OR normalizar_busqueda(COALESCE(i.email,'')) ="
            "         normalizar_busqueda(%s))"
        )
        params.extend([user.nombre, user.email])
    if titular is not None:
        condiciones.append("s.id_investigador = %s")
        params.append(titular)
    if insumo:
        condiciones.append("s.id_insumo = %s")
        params.append(insumo)
    if estado:
        condiciones.append("s.estado_efectivo = %s")
        params.append(estado)

    where = "WHERE " + " AND ".join(condiciones) if condiciones else ""
    total = connection.execute(
        f"SELECT count(*) AS total FROM v_autorizacion_saldo s {where}", params
    ).fetchone()["total"]
    filas = connection.execute(
        f"""
        SELECT {_COLUMNAS} FROM v_autorizacion_saldo s {where}
         ORDER BY s.vigencia_hasta NULLS LAST, s.codigo
         LIMIT %s OFFSET %s
        """,
        [*params, page_size, (page - 1) * page_size],
    ).fetchall()
    return Page[AutorizacionOut](
        items=[AutorizacionOut(**f) for f in filas],
        total=total, page=page, page_size=page_size,
    )


@router.post(
    "/autorizaciones",
    response_model=AutorizacionOut,
    status_code=status.HTTP_201_CREATED,
    summary="Registrar una autorización de uso (US-023)",
)
def crear(
    payload: AutorizacionCreate,
    connection: Annotated[Connection, Depends(get_connection)],
    user: Annotated[CurrentUser, Depends(require_roles(*ROLES_MANTIENE))],
) -> AutorizacionOut:
    try:
        cantidad = Decimal(payload.cantidad)
    except InvalidOperation as error:
        raise ProblemException(
            422, "VALIDACION", "Cantidad inválida",
            "La cantidad no es un número.", field="cantidad",
        ) from error

    gramos, densidad = _a_gramos(
        connection, cantidad, payload.unidad, payload.id_insumo
    )
    fila = connection.execute(
        """
        INSERT INTO autorizacion (
          codigo, id_investigador, id_insumo, id_presentacion,
          id_establecimiento, id_laboratorio, cantidad_autorizada_g,
          cantidad_registrada, unidad_registrada, densidad_aplicada,
          vigencia_desde, vigencia_hasta, observaciones, estado, creado_por
        ) VALUES (
          %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
          COALESCE(%s, CURRENT_DATE), %s, %s, 'BORRADOR', %s
        )
        RETURNING id_autorizacion
        """,
        (
            payload.codigo, payload.id_investigador, payload.id_insumo,
            payload.id_presentacion, payload.id_establecimiento,
            payload.id_laboratorio, gramos, cantidad, payload.unidad, densidad,
            payload.vigencia_desde, payload.vigencia_hasta,
            payload.observaciones, user.id_usuario,
        ),
    ).fetchone()
    return _obtener(connection, fila["id_autorizacion"])


@router.get(
    "/autorizaciones/{id_autorizacion}",
    response_model=AutorizacionOut,
    summary="Consultar una autorización",
)
def obtener(
    id_autorizacion: int,
    connection: Annotated[Connection, Depends(get_connection)],
    _user: Annotated[CurrentUser, Depends(get_current_user)],
) -> AutorizacionOut:
    return _obtener(connection, id_autorizacion)


@router.patch(
    "/autorizaciones/{id_autorizacion}",
    response_model=AutorizacionOut,
    summary="Editar en borrador, poner en vigor o revocar",
)
def actualizar(
    id_autorizacion: int,
    payload: AutorizacionUpdate,
    connection: Annotated[Connection, Depends(get_connection)],
    user: Annotated[CurrentUser, Depends(require_roles(*ROLES_MANTIENE))],
) -> AutorizacionOut:
    actual = connection.execute(
        "SELECT estado, id_insumo FROM autorizacion WHERE id_autorizacion = %s",
        (id_autorizacion,),
    ).fetchone()
    if actual is None:
        raise ProblemException(
            404, "REGISTRO_NO_EXISTE", "Autorización inexistente",
            f"No existe la autorización {id_autorizacion}.",
        )
    if payload.estado == "REVOCADA" and not (payload.motivo_revocacion or "").strip():
        raise ProblemException(
            422, "MOTIVO_REQUERIDO", "Motivo requerido",
            "Revocar una autorización exige decir por qué.",
            field="motivo_revocacion",
        )

    campos: list[str] = []
    params: list[Any] = []
    if payload.cantidad is not None:
        if actual["estado"] != "BORRADOR":
            raise ProblemException(
                409, "REGLA_NEGOCIO", "Autorización en vigor",
                "Una autorización vigente no cambia de cantidad: registre una "
                "ampliación o revóquela.", field="cantidad",
            )
        gramos, densidad = _a_gramos(
            connection, Decimal(payload.cantidad),
            payload.unidad or "g", actual["id_insumo"],
        )
        campos += ["cantidad_autorizada_g = %s", "cantidad_registrada = %s",
                   "unidad_registrada = %s", "densidad_aplicada = %s"]
        params += [gramos, Decimal(payload.cantidad), payload.unidad or "g",
                   densidad]
    for nombre, valor in (
        ("id_presentacion", payload.id_presentacion),
        ("id_laboratorio", payload.id_laboratorio),
        ("vigencia_desde", payload.vigencia_desde),
        ("vigencia_hasta", payload.vigencia_hasta),
        ("observaciones", payload.observaciones),
        ("estado", payload.estado),
        ("motivo_revocacion", payload.motivo_revocacion),
    ):
        if valor is not None:
            campos.append(f"{nombre} = %s")
            params.append(valor)
    if not campos:
        return _obtener(connection, id_autorizacion)

    params.append(id_autorizacion)
    connection.execute(
        f"UPDATE autorizacion SET {', '.join(campos)} WHERE id_autorizacion = %s",
        params,
    )
    return _obtener(connection, id_autorizacion)


# ─── US-024 · El soporte documental ─────────────────────────────────────────

@router.get(
    "/autorizaciones/{id_autorizacion}/documentos",
    response_model=list[DocumentoOut],
    summary="Versiones del soporte documental (US-024)",
)
def listar_documentos(
    id_autorizacion: int,
    connection: Annotated[Connection, Depends(get_connection)],
    _user: Annotated[CurrentUser, Depends(get_current_user)],
) -> list[DocumentoOut]:
    filas = connection.execute(
        """
        SELECT d.id_documento, d.version, d.nombre_archivo, d.tipo_mime,
               d.tamano_bytes, d.sha256, d.subido_en, u.nombre AS subido_por
          FROM autorizacion_documento d
          LEFT JOIN usuario u ON u.id_usuario = d.subido_por
         WHERE d.id_autorizacion = %s
         ORDER BY d.version DESC
        """,
        (id_autorizacion,),
    ).fetchall()
    return [DocumentoOut(**f) for f in filas]


@router.post(
    "/autorizaciones/{id_autorizacion}/documentos",
    response_model=DocumentoOut,
    status_code=status.HTTP_201_CREATED,
    summary="Adjuntar soporte; sustituir crea una versión nueva (US-024)",
)
async def subir_documento(
    id_autorizacion: int,
    connection: Annotated[Connection, Depends(get_connection)],
    user: Annotated[CurrentUser, Depends(require_roles(*ROLES_MANTIENE))],
    archivo: UploadFile = File(...),
) -> DocumentoOut:
    """Sustituir NO borra: añade versión. En un sistema fiscalizado, el
    documento que sustentaba una autorización el año pasado tiene que seguir
    recuperable aunque hoy haya otro."""
    if archivo.content_type not in MIMES_PERMITIDOS:
        raise ProblemException(
            422, "VALIDACION", "Tipo de archivo no admitido",
            f"Solo se aceptan {', '.join(sorted(MIMES_PERMITIDOS))}. "
            f"El archivo enviado es {archivo.content_type}.",
            field="archivo",
        )
    contenido = await archivo.read()
    if not contenido:
        raise ProblemException(
            422, "VALIDACION", "Archivo vacío",
            "El archivo no tiene contenido.", field="archivo",
        )
    if len(contenido) > TAMANO_MAXIMO:
        raise ProblemException(
            422, "VALIDACION", "Archivo demasiado grande",
            f"El máximo son {TAMANO_MAXIMO // (1024 * 1024)} MB y el archivo "
            f"pesa {len(contenido) / (1024 * 1024):.1f} MB.",
            field="archivo",
        )

    fila = connection.execute(
        """
        INSERT INTO autorizacion_documento (
          id_autorizacion, version, nombre_archivo, tipo_mime, tamano_bytes,
          sha256, contenido, subido_por
        ) VALUES (%s, 0, %s, %s, %s, %s, %s, %s)
        RETURNING id_documento, version, nombre_archivo, tipo_mime,
                  tamano_bytes, sha256, subido_en
        """,
        (
            id_autorizacion, archivo.filename or "soporte",
            archivo.content_type, len(contenido),
            hashlib.sha256(contenido).hexdigest(), contenido, user.id_usuario,
        ),
    ).fetchone()
    return DocumentoOut(**fila, subido_por=user.nombre)


@router.get(
    "/autorizaciones/{id_autorizacion}/documentos/{version}/contenido",
    summary="Descargar una versión del soporte",
)
def descargar_documento(
    id_autorizacion: int,
    version: int,
    connection: Annotated[Connection, Depends(get_connection)],
    _user: Annotated[CurrentUser, Depends(get_current_user)],
) -> Response:
    fila = connection.execute(
        """
        SELECT nombre_archivo, tipo_mime, contenido
          FROM autorizacion_documento
         WHERE id_autorizacion = %s AND version = %s
        """,
        (id_autorizacion, version),
    ).fetchone()
    if fila is None:
        raise ProblemException(
            404, "REGISTRO_NO_EXISTE", "Documento inexistente",
            f"No existe la versión {version} del soporte.",
        )
    return Response(
        content=bytes(fila["contenido"]),
        media_type=fila["tipo_mime"],
        headers={
            "Content-Disposition":
                f'attachment; filename="{fila["nombre_archivo"]}"'
        },
    )


# ─── US-028/029 · Excepciones ───────────────────────────────────────────────

_COLUMNAS_EXC = """
    e.id_excepcion, e.codigo, e.id_frasco, e.id_investigador, e.cantidad_g,
    e.cantidad_registrada, e.unidad_registrada, e.curso, e.regla_infringida,
    e.motivo, e.estado, e.solicitado_en, e.resuelto_en, e.comentario,
    e.id_movimiento,
    i.nombre AS titular, ins.nombre_comercial,
    us.nombre AS solicitado_por, ur.nombre AS resuelto_por
"""

_DESDE_EXC = """
    FROM excepcion e
    JOIN investigador i   ON i.id_investigador = e.id_investigador
    JOIN frasco f         ON f.id_frasco = e.id_frasco
    JOIN lote l           ON l.id_lote = f.id_lote
    JOIN presentacion p   ON p.id_presentacion = l.id_presentacion
    JOIN insumo ins       ON ins.id_insumo = p.id_insumo
    LEFT JOIN usuario us  ON us.id_usuario = e.solicitado_por
    LEFT JOIN usuario ur  ON ur.id_usuario = e.resuelto_por
"""


@router.get(
    "/excepciones",
    response_model=Page[ExcepcionOut],
    summary="Excepciones pendientes y resueltas (US-029)",
)
def listar_excepciones(
    connection: Annotated[Connection, Depends(get_connection)],
    _user: Annotated[CurrentUser, Depends(get_current_user)],
    estado: Annotated[str | None, Query()] = "PENDIENTE",
    page: Annotated[int, Query(ge=1)] = 1,
    page_size: Annotated[int, Query(ge=1, le=100)] = 20,
) -> Page[ExcepcionOut]:
    where, params = ("", [])
    if estado and estado != "TODAS":
        where, params = ("WHERE e.estado = %s", [estado])
    total = connection.execute(
        f"SELECT count(*) AS total {_DESDE_EXC} {where}", params
    ).fetchone()["total"]
    filas = connection.execute(
        f"""SELECT {_COLUMNAS_EXC} {_DESDE_EXC} {where}
            ORDER BY e.solicitado_en DESC LIMIT %s OFFSET %s""",
        [*params, page_size, (page - 1) * page_size],
    ).fetchall()
    return Page[ExcepcionOut](
        items=[ExcepcionOut(**f) for f in filas],
        total=total, page=page, page_size=page_size,
    )


@router.post(
    "/excepciones",
    response_model=ExcepcionOut,
    status_code=status.HTTP_201_CREATED,
    summary="Solicitar una excepción tras un consumo bloqueado (US-028)",
)
def solicitar_excepcion(
    payload: ExcepcionCreate,
    connection: Annotated[Connection, Depends(get_connection)],
    user: Annotated[CurrentUser, Depends(get_current_user)],
) -> ExcepcionOut:
    """No mueve stock ni saldo: solo guarda el intento y espera decisión.

    La regla infringida se vuelve a calcular aquí en vez de aceptarla del
    cliente. Si alguien pudiera declarar qué regla incumplió, podría declarar
    una más benigna que la real.
    """
    frasco = connection.execute(
        """
        SELECT f.id_frasco, COALESCE(l.densidad, p.densidad) AS densidad,
               p.id_insumo
          FROM frasco f
          JOIN lote l         ON l.id_lote = f.id_lote
          JOIN presentacion p ON p.id_presentacion = l.id_presentacion
         WHERE f.id_frasco = %s
        """,
        (payload.id_frasco,),
    ).fetchone()
    if frasco is None:
        raise ProblemException(
            404, "FRASCO_NO_EXISTE", "Frasco inexistente",
            f"No existe el frasco '{payload.id_frasco}'.", field="id_frasco",
        )

    cantidad = Decimal(payload.cantidad)
    if payload.unidad in FACTOR_G:
        gramos = cantidad * FACTOR_G[payload.unidad]
    elif frasco["densidad"] is None:
        raise ProblemException(
            422, "DENSIDAD_REQUERIDA", "Densidad requerida",
            "Sin densidad no se puede convertir un volumen.", field="unidad",
        )
    else:
        gramos = cantidad * FACTOR_ML[payload.unidad] * Decimal(frasco["densidad"])
    gramos = gramos.quantize(Decimal("0.0001"))

    veredicto = connection.execute(
        "SELECT * FROM fn_autorizacion_para_consumo(%s, %s, %s, CURRENT_DATE)",
        (payload.id_investigador, payload.id_frasco, gramos),
    ).fetchone()
    regla = (veredicto or {}).get("motivo_rechazo")
    if regla is None:
        raise ProblemException(
            409, "REGLA_NEGOCIO", "No hace falta una excepción",
            "Ese consumo sí está amparado por una autorización vigente: "
            "regístrelo por la vía normal.",
        )

    fila = connection.execute(
        f"""
        INSERT INTO excepcion (
          codigo, id_frasco, id_investigador, cantidad_g, cantidad_registrada,
          unidad_registrada, curso, usuario_final, regla_infringida, motivo,
          solicitado_por
        ) VALUES (
          'EXC-' || to_char(now(), 'YYYYMMDD') || '-' ||
            lpad(nextval('excepcion_id_excepcion_seq')::text, 4, '0'),
          %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
        )
        RETURNING id_excepcion
        """,
        (
            payload.id_frasco, payload.id_investigador, gramos, cantidad,
            payload.unidad, payload.curso, payload.usuario_final, regla,
            payload.motivo.strip(), user.id_usuario,
        ),
    ).fetchone()
    return _obtener_excepcion(connection, fila["id_excepcion"])


def _obtener_excepcion(connection: Connection, id_excepcion: int) -> ExcepcionOut:
    fila = connection.execute(
        f"SELECT {_COLUMNAS_EXC} {_DESDE_EXC} WHERE e.id_excepcion = %s",
        (id_excepcion,),
    ).fetchone()
    if fila is None:
        raise ProblemException(
            404, "REGISTRO_NO_EXISTE", "Excepción inexistente",
            f"No existe la excepción {id_excepcion}.",
        )
    return ExcepcionOut(**fila)


@router.post(
    "/excepciones/{id_excepcion}/resolver",
    response_model=ExcepcionOut,
    summary="Aprobar o rechazar una excepción (US-029)",
)
def resolver_excepcion(
    id_excepcion: int,
    payload: ExcepcionResolver,
    connection: Annotated[Connection, Depends(get_connection)],
    user: Annotated[CurrentUser, Depends(require_roles(*ROLES_APRUEBA))],
) -> ExcepcionOut:
    """Aprobar ejecuta el consumo en el mismo acto, una sola vez.

    La unicidad no la impone este código sino la base: `excepcion.id_movimiento`
    es UNIQUE y solo se llena al ejecutar. Dos aprobaciones simultáneas no
    pueden producir dos consumos.
    """
    exc = connection.execute(
        "SELECT * FROM excepcion WHERE id_excepcion = %s FOR UPDATE",
        (id_excepcion,),
    ).fetchone()
    if exc is None:
        raise ProblemException(
            404, "REGISTRO_NO_EXISTE", "Excepción inexistente",
            f"No existe la excepción {id_excepcion}.",
        )
    if exc["estado"] != "PENDIENTE":
        raise ProblemException(
            409, "REGLA_NEGOCIO", "Excepción ya resuelta",
            f"La excepción {exc['codigo']} está en estado {exc['estado']} y no "
            "se puede volver a resolver.",
        )

    comentario = (payload.comentario or "").strip() or None
    if not payload.aprobar and not comentario:
        raise ProblemException(
            422, "MOTIVO_REQUERIDO", "Comentario requerido",
            "Rechazar una excepción exige decir por qué.", field="comentario",
        )

    if not payload.aprobar:
        connection.execute(
            """
            UPDATE excepcion
               SET estado = 'RECHAZADA', resuelto_por = %s, resuelto_en = now(),
                   comentario = %s
             WHERE id_excepcion = %s
            """,
            (user.id_usuario, comentario, id_excepcion),
        )
        return _obtener_excepcion(connection, id_excepcion)

    # Aprobar y ejecutar en el mismo acto: si el consumo falla (saldo
    # insuficiente, custodia ajena), la aprobación se revierte con él. Una
    # excepción aprobada que no se pudo ejecutar sería una mentira en el
    # expediente.
    movimiento = connection.execute(
        """
        INSERT INTO kardex (
          id_frasco, tipo_movimiento, motivo, cantidad_g, cantidad_registrada,
          unidad_registrada, id_investigador_origen, curso, usuario_final,
          registrado_por, saldo_resultante_g
        ) VALUES (%s, 'SALIDA', 'consumo_laboratorio', %s, %s, %s, %s, %s, %s,
                  %s, 0)
        RETURNING id_movimiento
        """,
        (
            exc["id_frasco"], exc["cantidad_g"], exc["cantidad_registrada"],
            exc["unidad_registrada"], exc["id_investigador"],
            exc["curso"] or "Consumo por excepción aprobada",
            exc["usuario_final"], user.id_usuario,
        ),
    ).fetchone()

    connection.execute(
        """
        UPDATE excepcion
           SET estado = 'EJECUTADA', resuelto_por = %s, resuelto_en = now(),
               comentario = %s, id_movimiento = %s
         WHERE id_excepcion = %s
        """,
        (user.id_usuario, comentario, movimiento["id_movimiento"], id_excepcion),
    )
    return _obtener_excepcion(connection, id_excepcion)
