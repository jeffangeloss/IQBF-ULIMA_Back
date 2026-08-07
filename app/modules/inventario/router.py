"""Inventario físico, consumo y declaración — US-05, US-09, US-10, US-11,
US-12, US-13, US-19, US-20 y US-21.

Tres decisiones que conviene no deshacer:

1. **La búsqueda la resuelve PostgreSQL**, no el cliente. `fn_frasco_coincide`
   mira nombre, alias, código interno, código SUNAT, presentación y lote. Es lo
   que permite que «etanol» encuentre los frascos rotulados «Ethanol».

2. **Las reglas de negocio viven en la base**, no aquí. El saldo negativo, la
   custodia ajena y el saldo indeterminado los rechazan triggers; este módulo
   se limita a traducir el error de PostgreSQL a `problem+json`. Un `INSERT`
   manual con psql choca contra las mismas reglas.

3. **El saldo nunca se escribe**: solo lo mueve el kardex (`fn_frasco_guardia`).
   Aquí no hay ni un UPDATE sobre `frasco.peso_neto_actual_g`.
"""

from decimal import Decimal, InvalidOperation
from typing import Annotated, Any, Literal

from fastapi import APIRouter, Depends, Query, status
from psycopg import Connection

from app.contracts import Page
from app.dependencies import get_connection, get_current_user
from app.errors import ProblemException
from app.modules.auth.schemas import CurrentUser
from app.modules.inventario.schemas import (
    ConsumoCreate,
    ConsumoOut,
    ConsumoPorPesada,
    Declaracion,
    FrascoDetalle,
    FrascoResumen,
    LineaDeclaracion,
    MovimientoOut,
    ResumenPanel,
    SaldoInvestigador,
)


router = APIRouter(prefix="/api", tags=["Inventario y consumo"])

# Un litro de agua pesa 1000 g; el resto depende de la densidad del líquido.
FACTOR_A_GRAMOS = {"g": Decimal(1), "kg": Decimal(1000)}
FACTOR_A_ML = {"mL": Decimal(1), "L": Decimal(1000)}

_COLUMNAS_RESUMEN = """
    v.id_frasco, v.id_insumo, v.nombre_comercial, v.id_presentacion,
    v.codigo_bf_sunat, v.concentracion, v.numero_lote,
    v.peso_neto_actual_g, v.saldo_indeterminado, v.fraccion_llenado,
    v.nominal_dudoso,
    v.volumen_actual_ml, v.densidad_aplicable,
    v.id_investigador, v.custodio, v.id_laboratorio, v.laboratorio,
    v.ubicacion, v.posicion,
    v.condicion_envase, v.estado_frasco, v.fecha_caducidad,
    v.estado_caducidad, v.dias_sin_movimiento, v.alerta_prioritaria
"""


#: Órdenes que el usuario puede elegir. Se traducen aquí y no se interpolan
#: desde la petición: un ORDER BY que venga del cliente es una inyección.
ORDENES = {
    "alerta": "v.alerta_prioritaria, v.nombre_comercial, v.id_frasco",
    "insumo": "v.nombre_comercial, v.id_frasco",
    "saldo": "v.peso_neto_actual_g DESC NULLS LAST, v.id_frasco",
    "caducidad": "v.fecha_caducidad NULLS LAST, v.id_frasco",
    "ubicacion": "v.casillero, v.nivel, v.posicion, v.id_frasco",
    "custodio": "v.custodio NULLS LAST, v.id_frasco",
}


def _filtros(
    q: str | None,
    laboratorio: int | None,
    custodio: int | None,
    insumo: str | None,
    estado_caducidad: str | None,
    solo_con_saldo: bool,
    ubicacion: int | None = None,
    estado_frasco: str | None = None,
) -> tuple[str, list[Any]]:
    # Por defecto las bajas no se listan, pero se pueden pedir: un frasco dado
    # de baja sigue existiendo en el historial y hay que poder mirarlo.
    condiciones: list[str] = []
    if estado_frasco:
        condiciones.append("v.estado_frasco = %s")
    else:
        condiciones.append("v.estado_frasco <> 'DADO_DE_BAJA'")
    params: list[Any] = []

    if estado_frasco:
        params.append(estado_frasco)
    if q:
        # El custodio entra en la caja de texto: «lo de Ponce» es una búsqueda
        # tan legítima como «HCl».
        condiciones.append(
            "(fn_frasco_coincide(v.id_frasco, v.id_insumo, v.nombre_comercial,"
            " v.codigo_bf_sunat, v.id_presentacion, v.numero_lote, %s)"
            " OR normalizar_busqueda(COALESCE(v.custodio, ''))"
            "    LIKE '%%' || normalizar_busqueda(%s) || '%%')"
        )
        params.extend([q, q])
    if laboratorio is not None:
        # -1 es «sin laboratorio asignado»: una pregunta abierta que hay que
        # poder listar, no un valor que se pueda esconder.
        if laboratorio == -1:
            condiciones.append("v.id_laboratorio IS NULL")
        else:
            condiciones.append("v.id_laboratorio = %s")
            params.append(laboratorio)
    if custodio is not None:
        condiciones.append("v.id_investigador = %s")
        params.append(custodio)
    if insumo:
        condiciones.append("v.id_insumo = %s")
        params.append(insumo)
    if estado_caducidad:
        condiciones.append("v.estado_caducidad = %s")
        params.append(estado_caducidad)
    if ubicacion is not None:
        if ubicacion == -1:
            condiciones.append("v.id_ubicacion IS NULL")
        else:
            condiciones.append("v.id_ubicacion = %s")
            params.append(ubicacion)
    if solo_con_saldo:
        condiciones.append("v.peso_neto_actual_g > 0")

    return "WHERE " + " AND ".join(condiciones), params


@router.get(
    "/frascos",
    response_model=Page[FrascoResumen],
    summary="Buscar frascos por nombre, código, laboratorio o custodio",
)
def list_frascos(
    connection: Annotated[Connection, Depends(get_connection)],
    _user: Annotated[CurrentUser, Depends(get_current_user)],
    q: Annotated[str | None, Query(max_length=120)] = None,
    laboratorio: Annotated[int | None, Query()] = None,
    custodio: Annotated[int | None, Query()] = None,
    insumo: Annotated[str | None, Query(max_length=20)] = None,
    estado_caducidad: Annotated[
        Literal["VIGENTE", "POR_VENCER", "VENCIDO", "POR_CONFIRMAR"] | None,
        Query(),
    ] = None,
    ubicacion: Annotated[int | None, Query()] = None,
    estado_frasco: Annotated[
        Literal["EN_USO", "AGOTADO", "DADO_DE_BAJA"] | None, Query()
    ] = None,
    orden: Annotated[
        Literal["alerta", "insumo", "saldo", "caducidad", "ubicacion", "custodio"],
        Query(),
    ] = "alerta",
    solo_con_saldo: Annotated[bool, Query()] = False,
    page: Annotated[int, Query(ge=1)] = 1,
    page_size: Annotated[int, Query(ge=1, le=100)] = 20,
) -> Page[FrascoResumen]:
    """Responde la pregunta que llega de viva voz al laboratorio.

    «Dame el etanol del laboratorio de alimentos» es
    `?q=etanol&laboratorio=<id>`: `q` viaja por los alias del insumo, así que
    encuentra también los frascos rotulados «Ethanol» o «Alcohol etílico».
    """
    where, params = _filtros(
        q, laboratorio, custodio, insumo, estado_caducidad, solo_con_saldo,
        ubicacion, estado_frasco,
    )
    total = connection.execute(
        f"SELECT count(*) AS total FROM v_alertas_v4 v {where}", params
    ).fetchone()["total"]
    rows = connection.execute(
        f"""
        SELECT {_COLUMNAS_RESUMEN}
          FROM v_alertas_v4 v
          {where}
         ORDER BY {ORDENES[orden]}
         LIMIT %s OFFSET %s
        """,
        [*params, page_size, (page - 1) * page_size],
    ).fetchall()
    return Page[FrascoResumen](
        items=[FrascoResumen(**row) for row in rows],
        total=total,
        page=page,
        page_size=page_size,
    )


def _movimientos(connection: Connection, id_frasco: str) -> list[MovimientoOut]:
    rows = connection.execute(
        """
        SELECT k.id_movimiento, k.tipo_movimiento, k.motivo, k.cantidad_g,
               k.cantidad_registrada, k.unidad_registrada, k.densidad_aplicada,
               k.fuente_densidad, k.formula_conversion, k.origen_cantidad,
               k.saldo_despues_g AS saldo_resultante_g,
               k.saldo_antes_g AS peso_antes_g, k.fecha_hora,
               k.fecha_operacion, k.curso, k.registrado_por, k.investigador
          FROM v_kardex_detalle k
         WHERE k.id_frasco = %s
         ORDER BY k.fecha_hora DESC, k.id_movimiento DESC
        """,
        (id_frasco,),
    ).fetchall()
    return [MovimientoOut(**row) for row in rows]


@router.get(
    "/frascos/{id_frasco}",
    response_model=FrascoDetalle,
    summary="Ficha de un frasco con su historial",
)
def get_frasco(
    id_frasco: str,
    connection: Annotated[Connection, Depends(get_connection)],
    _user: Annotated[CurrentUser, Depends(get_current_user)],
) -> FrascoDetalle:
    row = connection.execute(
        f"""
        SELECT {_COLUMNAS_RESUMEN},
               v.tipo, v.capacidad, v.unidad, v.tipo_envase,
               v.contenido_nominal_g, v.grado_pureza, v.fecha_ingreso,
               v.peso_bruto_g, v.tara_g, v.peso_neto_inicial_g,
               v.fuente_tara, v.fecha_pesaje,
               v.casillero, v.nombre_puerta, v.nivel, v.precision_ubicacion,
               v.observaciones
          FROM v_alertas_v4 v
         WHERE v.id_frasco = %s
        """,
        (id_frasco,),
    ).fetchone()
    if row is None:
        raise ProblemException(
            404,
            "FRASCO_NO_EXISTE",
            "Frasco inexistente",
            f"No existe el frasco '{id_frasco}'.",
        )
    return FrascoDetalle(**row, movimientos=_movimientos(connection, id_frasco))


@router.get(
    "/inventario/panel",
    response_model=ResumenPanel,
    summary="Cifras de cabecera del inventario",
)
def panel(
    connection: Annotated[Connection, Depends(get_connection)],
    _user: Annotated[CurrentUser, Depends(get_current_user)],
) -> ResumenPanel:
    row = connection.execute(
        """
        SELECT count(*)::integer AS frascos,
               count(*) FILTER (WHERE peso_neto_actual_g > 0)::integer
                 AS frascos_con_saldo,
               COALESCE(round(sum(peso_neto_actual_g) / 1000.0, 4), 0)
                 AS saldo_total_kg,
               count(*) FILTER (WHERE estado_caducidad = 'VENCIDO')::integer
                 AS frascos_vencidos,
               count(*) FILTER (WHERE estado_caducidad = 'POR_VENCER')::integer
                 AS frascos_por_vencer,
               count(*) FILTER (WHERE saldo_indeterminado)::integer
                 AS frascos_indeterminados,
               count(*) FILTER (WHERE dias_sin_movimiento >= 730)::integer
                 AS frascos_dormidos,
               count(DISTINCT id_investigador)::integer AS investigadores,
               count(DISTINCT codigo_bf_sunat)::integer AS codigos_sunat
          FROM v_inventario_v4
         WHERE estado_frasco <> 'DADO_DE_BAJA'
        """
    ).fetchone()
    return ResumenPanel(**row)


@router.get(
    "/inventario/saldo-investigador",
    response_model=list[SaldoInvestigador],
    summary="Saldo por custodio (US-09)",
)
def saldo_por_investigador(
    connection: Annotated[Connection, Depends(get_connection)],
    _user: Annotated[CurrentUser, Depends(get_current_user)],
    con_frascos: Annotated[bool, Query()] = True,
) -> list[SaldoInvestigador]:
    rows = connection.execute(
        f"""
        SELECT id_investigador, custodio, frascos::integer,
               frascos_vencidos::integer, frascos_indeterminados::integer,
               saldo_kg
          FROM v_saldo_investigador_v4
         {'WHERE frascos > 0' if con_frascos else ''}
         ORDER BY saldo_kg DESC, custodio
        """
    ).fetchall()
    return [SaldoInvestigador(**row) for row in rows]


@router.get(
    "/inventario/saldo-laboratorio",
    summary="Stock por laboratorio e insumo (US-11)",
)
def saldo_por_laboratorio(
    connection: Annotated[Connection, Depends(get_connection)],
    _user: Annotated[CurrentUser, Depends(get_current_user)],
    laboratorio: Annotated[int | None, Query()] = None,
) -> list[dict[str, Any]]:
    where, params = ("WHERE id_laboratorio = %s", [laboratorio]) \
        if laboratorio is not None else ("", [])
    rows = connection.execute(
        f"""
        SELECT id_laboratorio, laboratorio, id_insumo, nombre_comercial,
               frascos::integer, frascos_vencidos::integer,
               saldo_kg::text AS saldo_kg
          FROM v_saldo_laboratorio
          {where}
         ORDER BY laboratorio, nombre_comercial
        """,
        params,
    ).fetchall()
    return [dict(row) for row in rows]


@router.get(
    "/declaracion/sunat",
    response_model=Declaracion,
    summary="Rollup por código de presentación SUNAT (US-21)",
)
def declaracion_sunat(
    connection: Annotated[Connection, Depends(get_connection)],
    _user: Annotated[CurrentUser, Depends(get_current_user)],
) -> Declaracion:
    rows = connection.execute(
        """
        SELECT codigo_bf_sunat, id_insumo, nombre_comercial, tipo,
               frascos::integer, frascos_indeterminados::integer,
               saldo_kg, saldo_vencido_kg
          FROM v_declaracion_sunat
         ORDER BY codigo_bf_sunat
        """
    ).fetchall()
    lineas = [LineaDeclaracion(**row) for row in rows]
    indeterminados = sum(linea.frascos_indeterminados for linea in lineas)
    advertencia = None
    if indeterminados:
        # No se declara un total redondo cuando se sabe que está incompleto.
        advertencia = (
            f"{indeterminados} frasco(s) no están sumados por falta de tara: "
            "el total es un mínimo, no el inventario completo."
        )
    return Declaracion(
        lineas=lineas,
        total_kg=sum((linea.saldo_kg or Decimal(0) for linea in lineas),
                     Decimal(0)),
        frascos=sum(linea.frascos for linea in lineas),
        frascos_indeterminados=indeterminados,
        advertencia=advertencia,
    )



def _verificar_autorizacion(
    connection: Connection,
    id_frasco: str,
    id_investigador: int,
    cantidad_g: Decimal,
    fecha: Any = None,
) -> None:
    """US-027 · Ningún consumo por encima de lo autorizado.

    El control lo enciende el establecimiento (`exige_autorizacion`), no el
    programa. Nace apagado: encenderlo con cero autorizaciones cargadas dejaría
    al laboratorio sin poder registrar nada, y un control que obliga a
    saltárselo el primer día no es un control — es un estorbo que enseña a
    ignorarlo.

    Cuando está encendido, el motivo exacto se devuelve y se muestra: no es lo
    mismo «no tiene autorización» que «se le acabó», y la salida es distinta.
    """
    # El establecimiento del frasco se busca por su ubicación, y si no la tiene,
    # por el laboratorio del frasco o el de su custodio. Si aun así no se
    # resuelve, se aplica la política de CUALQUIER establecimiento que la
    # exija: un frasco sin ubicación no puede ser la puerta de atrás del
    # control. Fallar en abierto aquí sería peor que no tener control, porque
    # nadie se enteraría.
    exige = connection.execute(
        """
        SELECT COALESCE(
                 (SELECT e.exige_autorizacion
                    FROM frasco f
                    LEFT JOIN ubicacion u    ON u.id_ubicacion = f.id_ubicacion
                    LEFT JOIN investigador i ON i.id_investigador = f.id_investigador
                    LEFT JOIN laboratorio lab
                           ON lab.id_laboratorio = COALESCE(f.id_laboratorio_actual,
                                                            i.id_laboratorio)
                    JOIN establecimiento e
                      ON e.id_establecimiento = COALESCE(u.id_establecimiento,
                                                         lab.id_establecimiento)
                   WHERE f.id_frasco = %s),
                 (SELECT bool_or(exige_autorizacion) FROM establecimiento),
                 FALSE
               ) AS exige
        """,
        (id_frasco,),
    ).fetchone()
    if not (exige and exige["exige"]):
        return

    veredicto = connection.execute(
        "SELECT * FROM fn_autorizacion_para_consumo(%s, %s, %s, COALESCE(%s, CURRENT_DATE))",
        (id_investigador, id_frasco, cantidad_g, fecha),
    ).fetchone()
    motivo = (veredicto or {}).get("motivo_rechazo")
    if motivo is None:
        return

    detalle = {
        "SIN_AUTORIZACION":
            "No hay ninguna autorización de uso para este investigador y este "
            "insumo. Solicite una excepción si el consumo debe hacerse igual.",
        "AUTORIZACION_NO_VIGENTE":
            "La autorización existe pero no está vigente en esta fecha "
            "(en borrador, revocada o fuera de plazo).",
        "SALDO_AUTORIZADO_INSUFICIENTE":
            "La autorización no tiene saldo suficiente: quedan "
            f"{(veredicto or {}).get('disponible_g')} g autorizados.",
    }[motivo]
    raise ProblemException(
        409, "AUTORIZACION_INSUFICIENTE", "Consumo no autorizado", detalle,
        field="id_investigador",
    )


@router.post(
    "/movimientos/consumo",
    response_model=ConsumoOut,
    status_code=status.HTTP_201_CREATED,
    summary="Registrar un consumo (US-05, US-12, US-13, US-20)",
)
def registrar_consumo(
    payload: ConsumoCreate,
    connection: Annotated[Connection, Depends(get_connection)],
    user: Annotated[CurrentUser, Depends(get_current_user)],
) -> ConsumoOut:
    """Descuenta del frasco y deja el rastro.

    La conversión a gramos se hace aquí y **se congela** en el movimiento junto
    con la densidad usada: si mañana se corrige la densidad del lote, este
    consumo seguirá diciendo con qué número se calculó (US-20).
    """
    frasco = connection.execute(
        """
        SELECT f.id_frasco, f.peso_neto_actual_g, f.id_investigador,
               i.tipo, COALESCE(l.densidad, p.densidad) AS densidad
          FROM frasco f
          JOIN lote l         ON l.id_lote = f.id_lote
          JOIN presentacion p ON p.id_presentacion = l.id_presentacion
          JOIN insumo i       ON i.id_insumo = p.id_insumo
         WHERE f.id_frasco = %s
        """,
        (payload.id_frasco,),
    ).fetchone()
    if frasco is None:
        raise ProblemException(
            404,
            "FRASCO_NO_EXISTE",
            "Frasco inexistente",
            f"No existe el frasco '{payload.id_frasco}'.",
            field="id_frasco",
        )

    existe_investigador = connection.execute(
        "SELECT 1 FROM investigador WHERE id_investigador = %s AND estado = 'ACTIVO'",
        (payload.id_investigador,),
    ).fetchone()
    if existe_investigador is None:
        raise ProblemException(
            422,
            "INVESTIGADOR_NO_EXISTE",
            "Investigador inexistente",
            "El investigador indicado no existe o está inactivo.",
            field="id_investigador",
        )

    densidad = frasco["densidad"]
    unidad = payload.unidad
    cantidad = Decimal(payload.cantidad)

    if unidad in FACTOR_A_GRAMOS:
        cantidad_g = cantidad * FACTOR_A_GRAMOS[unidad]
    else:
        if densidad is None:
            raise ProblemException(
                422,
                "DENSIDAD_REQUERIDA",
                "Densidad requerida",
                f"El frasco '{payload.id_frasco}' no tiene densidad: registre "
                "el consumo en gramos o complete la densidad del lote.",
                field="unidad",
            )
        cantidad_g = cantidad * FACTOR_A_ML[unidad] * Decimal(densidad)

    # `quantize` lanza InvalidOperation si el número no cabe en el contexto
    # decimal, y eso salía como 500 «Error de base de datos» — un mensaje falso,
    # porque la base ni se toca. Un pegado mal hecho en la demo no puede acabar
    # en un error de servidor.
    try:
        cantidad_g = cantidad_g.quantize(Decimal("0.0001"))
    except (InvalidOperation, OverflowError) as error:
        raise ProblemException(
            422,
            "VALIDACION",
            "Cantidad fuera de rango",
            f"La cantidad indicada no es un peso registrable en este frasco. "
            f"El saldo actual es {frasco['peso_neto_actual_g']} g.",
            field="cantidad",
        ) from error

    # 14 enteros y 4 decimales es el ancho de kardex.cantidad_g: por encima, la
    # base rechazaría con un error de tipo que el operario no puede interpretar.
    if cantidad_g >= Decimal("10") ** 10:
        raise ProblemException(
            422,
            "VALIDACION",
            "Cantidad fuera de rango",
            "La cantidad excede el máximo registrable (10 000 000 000 g).",
            field="cantidad",
        )

    if cantidad_g <= 0:
        raise ProblemException(
            422,
            "VALIDACION",
            "Cantidad inválida",
            "La cantidad convertida a gramos debe ser mayor que cero.",
            field="cantidad",
        )

    _verificar_autorizacion(
        connection, payload.id_frasco, payload.id_investigador, cantidad_g,
        payload.fecha_operacion,
    )

    # El saldo lo mueve el trigger; aquí solo se inserta el hecho. Saldo
    # insuficiente (US-12), custodia ajena (US-13) y saldo indeterminado los
    # rechaza PostgreSQL y `_map_database_error` los traduce.
    row = connection.execute(
        """
        INSERT INTO kardex (
          id_frasco, tipo_movimiento, motivo, cantidad_g,
          cantidad_registrada, unidad_registrada, densidad_aplicada,
          id_investigador_origen, id_investigador_destinatario,
          fecha_operacion, curso, usuario_final,
          registrado_por, saldo_resultante_g
        ) VALUES (
          %s, 'SALIDA', 'consumo_laboratorio', %s,
          %s, %s, %s,
          %s, NULL,
          COALESCE(%s, CURRENT_DATE), %s, %s,
          %s, 0
        )
        RETURNING id_movimiento, id_frasco, cantidad_g, cantidad_kg,
                  unidad_registrada, densidad_aplicada, peso_antes_g,
                  saldo_resultante_g, fecha_hora
        """,
        (
            payload.id_frasco,
            cantidad_g,
            cantidad,
            unidad,
            densidad,
            payload.id_investigador,
            payload.fecha_operacion,
            payload.curso,
            payload.usuario_final,
            user.id_usuario,
        ),
    ).fetchone()

    return ConsumoOut(
        id_movimiento=row["id_movimiento"],
        id_frasco=row["id_frasco"],
        cantidad_g=row["cantidad_g"],
        cantidad_kg=row["cantidad_kg"],
        unidad_registrada=row["unidad_registrada"],
        densidad_aplicada=row["densidad_aplicada"],
        saldo_antes_g=row["peso_antes_g"],
        saldo_despues_g=row["saldo_resultante_g"],
        fecha_hora=row["fecha_hora"],
    )


@router.post(
    "/movimientos/consumo-por-pesada",
    response_model=ConsumoOut,
    status_code=status.HTTP_201_CREATED,
    summary="Registrar un consumo por doble pesada (US-05, US-12, US-13)",
)
def registrar_consumo_por_pesada(
    payload: ConsumoPorPesada,
    connection: Annotated[Connection, Depends(get_connection)],
    user: Annotated[CurrentUser, Depends(get_current_user)],
) -> ConsumoOut:
    """El consumo se deriva de la balanza, no se teclea.

    Es como registra el laboratorio en sus libros «CONTROL DE REACTIVOS»: se
    pesa el frasco entero antes y después de servir. La resta es el consumo, y
    la evidencia queda guardada — no una cifra que alguien estimó.

    A cambio, el registro se puede comprobar: `bruto_antes_g` tiene que
    coincidir con `tara + saldo`. Cuando no coincide es que salió producto sin
    registrarse, y el trigger lo rechaza. Con `ajustar_diferencia` esa
    diferencia entra **como un movimiento propio** de `ajuste_inventario`
    antes del consumo, en vez de disolverse dentro de él: quien audite verá
    los dos hechos por separado, que es lo que ocurrió.
    """
    frasco = connection.execute(
        """
        SELECT f.tara_g, f.peso_neto_actual_g, f.id_investigador
          FROM frasco f
         WHERE f.id_frasco = %s
        """,
        (payload.id_frasco,),
    ).fetchone()
    if frasco is None:
        raise ProblemException(
            404, "FRASCO_NO_EXISTE", "Frasco inexistente",
            f"No existe el frasco '{payload.id_frasco}'.", field="id_frasco",
        )
    if frasco["peso_neto_actual_g"] is None:
        raise ProblemException(
            409, "SALDO_INDETERMINADO", "Saldo indeterminado",
            f"El frasco '{payload.id_frasco}' no tiene tara: su saldo es "
            "indeterminado y no se puede mover.",
        )

    bruto_antes = Decimal(payload.bruto_antes_g)
    bruto_despues = Decimal(payload.bruto_despues_g)
    consumo = (bruto_antes - bruto_despues).quantize(Decimal("0.0001"))

    if consumo <= 0:
        raise ProblemException(
            422, "VALIDACION", "La segunda pesada no es menor",
            f"La balanza marca {bruto_despues} g después y {bruto_antes} g "
            "antes: no hubo consumo. Si el frasco solo se verificó, use un "
            "movimiento de inventario.",
            field="bruto_despues_g",
        )

    tara = frasco["tara_g"]
    saldo = frasco["peso_neto_actual_g"]
    id_ajuste: int | None = None
    ajuste_g: Decimal | None = None

    # La diferencia entre lo que marca la balanza y lo que el sistema cree que
    # hay es producto que salió sin registrarse. No se absorbe en el consumo.
    if tara is not None:
        descuadre = (bruto_antes - (tara + saldo)).quantize(Decimal("0.0001"))
        if abs(descuadre) > Decimal("0.05"):
            if not payload.ajustar_diferencia:
                raise ProblemException(
                    409, "PESADA_NO_CUADRA", "La pesada no cuadra",
                    f"La balanza marca {bruto_antes} g y debería marcar "
                    f"{tara + saldo} g (tara {tara} + saldo {saldo}). "
                    f"Diferencia de {descuadre} g: hubo uso sin registrar. "
                    "Confirme el ajuste para regularizarlo antes del consumo.",
                    field="bruto_antes_g",
                )
            fila_ajuste = connection.execute(
                """
                INSERT INTO kardex (
                  id_frasco, tipo_movimiento, motivo, cantidad_g,
                  id_investigador_origen, fecha_operacion, curso,
                  registrado_por, saldo_resultante_g
                ) VALUES (
                  %s, %s, 'ajuste_inventario', %s,
                  %s, COALESCE(%s, CURRENT_DATE), %s,
                  %s, 0
                )
                RETURNING id_movimiento, cantidad_g
                """,
                (
                    payload.id_frasco,
                    "ENTRADA" if descuadre > 0 else "SALIDA",
                    abs(descuadre),
                    payload.id_investigador,
                    payload.fecha_operacion,
                    "Regularización: diferencia detectada al pesar",
                    user.id_usuario,
                ),
            ).fetchone()
            id_ajuste = fila_ajuste["id_movimiento"]
            ajuste_g = descuadre

    _verificar_autorizacion(
        connection, payload.id_frasco, payload.id_investigador, consumo,
        payload.fecha_operacion,
    )

    fila = connection.execute(
        """
        INSERT INTO kardex (
          id_frasco, tipo_movimiento, motivo, cantidad_g,
          cantidad_registrada, unidad_registrada,
          bruto_antes_g, bruto_despues_g,
          id_investigador_origen, fecha_operacion, curso, usuario_final,
          registrado_por, saldo_resultante_g
        ) VALUES (
          %s, 'SALIDA', 'consumo_laboratorio', %s,
          %s, 'g',
          %s, %s,
          %s, COALESCE(%s, CURRENT_DATE), %s, %s,
          %s, 0
        )
        RETURNING id_movimiento, id_frasco, cantidad_g, cantidad_kg,
                  unidad_registrada, densidad_aplicada, peso_antes_g,
                  saldo_resultante_g, fecha_hora, bruto_antes_g, bruto_despues_g
        """,
        (
            payload.id_frasco, consumo, consumo,
            bruto_antes, bruto_despues,
            payload.id_investigador, payload.fecha_operacion,
            payload.curso, payload.usuario_final, user.id_usuario,
        ),
    ).fetchone()

    return ConsumoOut(
        id_movimiento=fila["id_movimiento"],
        id_frasco=fila["id_frasco"],
        cantidad_g=fila["cantidad_g"],
        cantidad_kg=fila["cantidad_kg"],
        unidad_registrada=fila["unidad_registrada"],
        densidad_aplicada=fila["densidad_aplicada"],
        saldo_antes_g=fila["peso_antes_g"],
        saldo_despues_g=fila["saldo_resultante_g"],
        fecha_hora=fila["fecha_hora"],
        bruto_antes_g=fila["bruto_antes_g"],
        bruto_despues_g=fila["bruto_despues_g"],
        id_ajuste=id_ajuste,
        ajuste_g=ajuste_g,
    )


@router.post(
    "/movimientos/inventario",
    response_model=MovimientoOut,
    status_code=status.HTTP_201_CREATED,
    summary="Registrar una pesada de verificación sin mover saldo",
)
def registrar_inventario(
    payload: ConsumoPorPesada,
    connection: Annotated[Connection, Depends(get_connection)],
    user: Annotated[CurrentUser, Depends(get_current_user)],
) -> MovimientoOut:
    """Las filas «INV.» de sus libros: se pesa y se confirma, no se consume.

    Deja constancia de que alguien miró el frasco ese día. Si la pesada no
    cuadra, el trigger la rechaza: entonces lo que corresponde es un ajuste,
    no una verificación.
    """
    fila = connection.execute(
        """
        INSERT INTO kardex (
          id_frasco, tipo_movimiento, motivo, cantidad_g,
          bruto_antes_g, bruto_despues_g,
          id_investigador_origen, fecha_operacion, curso,
          registrado_por, saldo_resultante_g
        ) VALUES (
          %s, 'AJUSTE', 'inventario', 0,
          %s, %s,
          %s, COALESCE(%s, CURRENT_DATE), %s,
          %s, 0
        )
        RETURNING id_movimiento, tipo_movimiento, motivo, cantidad_g,
                  cantidad_registrada, unidad_registrada, densidad_aplicada,
                  saldo_resultante_g, peso_antes_g, fecha_hora, fecha_operacion,
                  curso
        """,
        (
            payload.id_frasco,
            payload.bruto_antes_g, payload.bruto_antes_g,
            payload.id_investigador, payload.fecha_operacion,
            payload.curso or "Verificación de inventario",
            user.id_usuario,
        ),
    ).fetchone()
    return MovimientoOut(
        **fila,
        registrado_por=user.nombre,
        investigador=None,
    )
