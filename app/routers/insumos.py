from datetime import date
from typing import Annotated, Any, Literal

from fastapi import APIRouter, Depends, Query, status
from psycopg import Connection, sql

from app.dependencies import get_connection, get_current_user, require_roles
from app.errors import ProblemException
from app.schemas import (
    CurrentUser,
    DensidadCreate,
    DensidadOut,
    InsumoCreate,
    InsumoOut,
    InsumoState,
    InsumoType,
    InsumoUpdate,
    Page,
    PresentacionCreate,
    PresentacionOut,
    PresentacionSummary,
    PresentacionUpdate,
)


router = APIRouter(prefix="/api", tags=["Insumos y presentaciones"])
MAINTAINER_ROLES = ("RESPONSABLE_IQBF",)


def _require_global_maintainer(user: CurrentUser) -> None:
    if not user.alcance_global:
        raise ProblemException(
            403,
            "ALCANCE_GLOBAL_REQUERIDO",
            "Alcance global requerido",
            "Los maestros de insumos solo pueden modificarse "
            "con alcance global.",
        )


def _validate_presentation_policy(
    *,
    insumo: InsumoOut,
    unidad: str,
    densidad: Any,
    equivalencia_g: Any,
    require_equivalence: bool = False,
) -> None:
    allowed_units = (
        {"mL", "L"} if insumo.tipo == "LIQUIDO" else {"g", "kg"}
    )
    if unidad not in allowed_units:
        raise ProblemException(
            422,
            "REGLA_NEGOCIO",
            "Unidad incompatible",
            f"La unidad {unidad} no es compatible con un insumo "
            f"{insumo.tipo.lower()}.",
            field="unidad",
        )
    if insumo.tipo == "SOLIDO" and densidad is not None:
        raise ProblemException(
            422,
            "REGLA_NEGOCIO",
            "Densidad no aplicable",
            "Un insumo sólido no registra densidad en la presentación.",
            field="densidad",
        )
    if insumo.densidad_variable and densidad is not None:
        raise ProblemException(
            422,
            "REGLA_NEGOCIO",
            "Densidad en lote requerida",
            "Este insumo tiene densidad variable; regístrela en el lote.",
            field="densidad",
        )
    if (
        insumo.tipo == "LIQUIDO"
        and not insumo.densidad_variable
        and densidad is None
    ):
        raise ProblemException(
            422,
            "DENSIDAD_REQUERIDA",
            "Densidad requerida",
            "Un líquido de densidad fija requiere densidad "
            "en la presentación.",
            field="densidad",
        )
    if require_equivalence and equivalencia_g is None:
        raise ProblemException(
            422,
            "REGLA_NEGOCIO",
            "Equivalencia requerida",
            "Una presentación nueva requiere su equivalencia en gramos.",
            field="equivalencia_g",
        )


def _get_insumo(connection: Connection, id_insumo: str) -> InsumoOut:
    row = connection.execute(
        """
        SELECT i.id_insumo, i.nombre_comercial, i.tipo, i.unidad_base,
               i.densidad_variable, i.estado, i.creado_en, i.actualizado_en,
               count(p.id_presentacion)::integer AS cantidad_presentaciones,
               i.densidad_variable AS admite_densidad_lote
          FROM insumo i
          LEFT JOIN presentacion p ON p.id_insumo = i.id_insumo
         WHERE i.id_insumo = %s
         GROUP BY i.id_insumo
        """,
        (id_insumo,),
    ).fetchone()
    if row is None:
        raise ProblemException(
            404,
            "INSUMO_NO_EXISTE",
            "Insumo inexistente",
            f"No existe el insumo '{id_insumo}'.",
        )
    return InsumoOut(
        **row,
        presentaciones=_list_presentation_summaries(connection, id_insumo),
    )


def _presentation_query() -> str:
    return """
        SELECT p.id_presentacion, p.id_insumo, p.codigo_bf_sunat,
               p.codigo_presentacion, p.concentracion, p.capacidad, p.unidad,
               p.tipo_envase, p.equivalencia_g,
               COALESCE(d.valor, p.densidad) AS densidad_actual,
               p.estado, p.vigencia_desde, p.vigencia_hasta
          FROM presentacion p
          LEFT JOIN LATERAL (
            SELECT dv.valor
              FROM densidad_vigencia dv
             WHERE dv.id_presentacion = p.id_presentacion
               AND dv.vigencia_desde <= CURRENT_DATE
               AND (dv.vigencia_hasta IS NULL
                    OR dv.vigencia_hasta >= CURRENT_DATE)
             ORDER BY dv.vigencia_desde DESC
             LIMIT 1
          ) d ON true
    """


def _list_presentation_summaries(
    connection: Connection, id_insumo: str
) -> list[PresentacionSummary]:
    rows = connection.execute(
        _presentation_query()
        + """
          WHERE p.id_insumo = %s
            AND p.estado = 'VIGENTE'
          ORDER BY p.capacidad, p.unidad, p.id_presentacion
        """,
        (id_insumo,),
    ).fetchall()
    return [PresentacionSummary(**row) for row in rows]


def _get_presentation(
    connection: Connection, id_presentacion: str
) -> PresentacionOut:
    row = connection.execute(
        _presentation_query() + " WHERE p.id_presentacion = %s",
        (id_presentacion,),
    ).fetchone()
    if row is None:
        raise ProblemException(
            404,
            "PRESENTACION_NO_EXISTE",
            "Presentación inexistente",
            f"No existe la presentación '{id_presentacion}'.",
        )
    return PresentacionOut(**row)


@router.get(
    "/insumos",
    response_model=Page[InsumoOut],
    summary="Buscar insumos",
)
def list_insumos(
    connection: Annotated[Connection, Depends(get_connection)],
    _user: Annotated[CurrentUser, Depends(get_current_user)],
    q: Annotated[str | None, Query(max_length=120)] = None,
    estado: Annotated[
        InsumoState | Literal["TODOS"], Query()
    ] = "VIGENTE",
    tipo: Annotated[InsumoType | None, Query()] = None,
    page: Annotated[int, Query(ge=1)] = 1,
    page_size: Annotated[int, Query(ge=1, le=100)] = 20,
) -> Page[InsumoOut]:
    conditions = []
    params: list[Any] = []
    if q:
        conditions.append(
            """
            (normalizar_busqueda(i.id_insumo) LIKE normalizar_busqueda(%s)
             OR normalizar_busqueda(i.nombre_comercial)
                LIKE normalizar_busqueda(%s)
             OR EXISTS (
                 SELECT 1
                   FROM presentacion px
                  WHERE px.id_insumo = i.id_insumo
                    AND (
                      normalizar_busqueda(COALESCE(px.codigo_bf_sunat, ''))
                        LIKE normalizar_busqueda(%s)
                      OR normalizar_busqueda(
                           COALESCE(px.codigo_presentacion, '')
                         ) LIKE normalizar_busqueda(%s)
                    )
             ))
            """
        )
        pattern = f"%{q}%"
        params.extend([pattern, pattern, pattern, pattern])
    if estado != "TODOS":
        conditions.append("i.estado = %s")
        params.append(estado)
    if tipo:
        conditions.append("i.tipo = %s")
        params.append(tipo)

    where = "WHERE " + " AND ".join(conditions) if conditions else ""
    total = connection.execute(
        f"SELECT count(*) AS total FROM insumo i {where}", params
    ).fetchone()["total"]
    rows = connection.execute(
        f"""
        SELECT i.id_insumo, i.nombre_comercial, i.tipo, i.unidad_base,
               i.densidad_variable, i.estado, i.creado_en, i.actualizado_en,
               count(p.id_presentacion)::integer AS cantidad_presentaciones,
               i.densidad_variable AS admite_densidad_lote
          FROM insumo i
          LEFT JOIN presentacion p ON p.id_insumo = i.id_insumo
          {where}
         GROUP BY i.id_insumo
         ORDER BY normalizar_busqueda(i.nombre_comercial)
         LIMIT %s OFFSET %s
        """,
        [*params, page_size, (page - 1) * page_size],
    ).fetchall()
    return Page[InsumoOut](
        items=[
            InsumoOut(
                **row,
                presentaciones=_list_presentation_summaries(
                    connection, row["id_insumo"]
                ),
            )
            for row in rows
        ],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.post(
    "/insumos",
    response_model=InsumoOut,
    status_code=status.HTTP_201_CREATED,
    summary="Crear un insumo",
)
def create_insumo(
    payload: InsumoCreate,
    connection: Annotated[Connection, Depends(get_connection)],
    user: Annotated[
        CurrentUser, Depends(require_roles(*MAINTAINER_ROLES))
    ],
) -> InsumoOut:
    _require_global_maintainer(user)
    connection.execute(
        """
        INSERT INTO insumo (
          id_insumo, nombre_comercial, tipo, unidad_base,
          densidad_variable, estado
        ) VALUES (%s, %s, %s, %s, %s, 'VIGENTE')
        """,
        (
            payload.id_insumo,
            payload.nombre_comercial,
            payload.tipo,
            payload.unidad_base,
            payload.densidad_variable,
        ),
    )
    return _get_insumo(connection, payload.id_insumo)


@router.get(
    "/insumos/{id_insumo}",
    response_model=InsumoOut,
    summary="Consultar un insumo",
)
def get_insumo(
    id_insumo: str,
    connection: Annotated[Connection, Depends(get_connection)],
    _user: Annotated[CurrentUser, Depends(get_current_user)],
) -> InsumoOut:
    return _get_insumo(connection, id_insumo)


@router.patch(
    "/insumos/{id_insumo}",
    response_model=InsumoOut,
    summary="Editar o inactivar un insumo",
)
def update_insumo(
    id_insumo: str,
    payload: InsumoUpdate,
    connection: Annotated[Connection, Depends(get_connection)],
    user: Annotated[
        CurrentUser, Depends(require_roles(*MAINTAINER_ROLES))
    ],
) -> InsumoOut:
    _require_global_maintainer(user)
    current = _get_insumo(connection, id_insumo)
    changes = payload.model_dump(exclude_unset=True)
    motivo = changes.pop("motivo", None)
    if not changes:
        return current
    if "estado" in changes and changes["estado"] != current.estado:
        if not motivo:
            raise ProblemException(
                422,
                "MOTIVO_REQUERIDO",
                "Motivo requerido",
                "Indique el motivo del cambio de estado del insumo.",
                field="motivo",
            )
        connection.execute(
            "SELECT set_config('iqbf.change_reason', %s, true)", (motivo,)
        )
    final_type = changes.get("tipo", current.tipo)
    final_variable = changes.get(
        "densidad_variable", current.densidad_variable
    )
    if final_variable and final_type != "LIQUIDO":
        raise ProblemException(
            422,
            "REGLA_NEGOCIO",
            "Política de densidad inválida",
            "Solo un insumo líquido puede tener densidad variable.",
            field="densidad_variable",
        )
    if (
        final_type != current.tipo
        or final_variable != current.densidad_variable
    ):
        incompatible = connection.execute(
            """
            SELECT count(*) AS total
              FROM presentacion p
             WHERE p.id_insumo = %s
               AND (
                 (%s = 'SOLIDO' AND p.unidad NOT IN ('g', 'kg'))
                 OR (%s = 'LIQUIDO' AND p.unidad NOT IN ('mL', 'L'))
                 OR (%s AND p.densidad IS NOT NULL)
                 OR (%s = 'LIQUIDO' AND NOT %s AND p.densidad IS NULL)
               )
            """,
            (
                id_insumo,
                final_type,
                final_type,
                final_variable,
                final_type,
                final_variable,
            ),
        ).fetchone()["total"]
        if incompatible:
            raise ProblemException(
                409,
                "REGLA_NEGOCIO",
                "Presentaciones incompatibles",
                "No puede cambiar el tipo o la política de densidad mientras "
                "existan presentaciones incompatibles.",
            )
    assignments = [
        sql.SQL("{} = %s").format(sql.Identifier(field)) for field in changes
    ]
    assignments.append(sql.SQL("actualizado_en = now()"))
    query = sql.SQL("UPDATE insumo SET {} WHERE id_insumo = %s").format(
        sql.SQL(", ").join(assignments)
    )
    result = connection.execute(query, [*changes.values(), id_insumo])
    if result.rowcount == 0:
        _get_insumo(connection, id_insumo)
    return _get_insumo(connection, id_insumo)


@router.get(
    "/insumos/{id_insumo}/presentaciones",
    response_model=list[PresentacionOut],
    summary="Listar las presentaciones de un insumo",
)
def list_presentations(
    id_insumo: str,
    connection: Annotated[Connection, Depends(get_connection)],
    _user: Annotated[CurrentUser, Depends(get_current_user)],
    incluir_inactivas: bool = False,
) -> list[PresentacionOut]:
    _get_insumo(connection, id_insumo)
    condition = "" if incluir_inactivas else " AND p.estado = 'VIGENTE'"
    rows = connection.execute(
        _presentation_query()
        + f"""
          WHERE p.id_insumo = %s {condition}
          ORDER BY p.capacidad, p.unidad, p.id_presentacion
        """,
        (id_insumo,),
    ).fetchall()
    return [PresentacionOut(**row) for row in rows]


@router.post(
    "/presentaciones",
    response_model=PresentacionOut,
    status_code=status.HTTP_201_CREATED,
    summary="Crear una presentación",
)
def create_presentation(
    payload: PresentacionCreate,
    connection: Annotated[Connection, Depends(get_connection)],
    user: Annotated[CurrentUser, Depends(require_roles(*MAINTAINER_ROLES))],
) -> PresentacionOut:
    _require_global_maintainer(user)
    insumo = _get_insumo(connection, payload.id_insumo)
    if insumo.estado != "VIGENTE":
        raise ProblemException(
            409,
            "INSUMO_INACTIVO",
            "Insumo inactivo",
            "No se pueden crear presentaciones para un insumo inactivo.",
        )
    _validate_presentation_policy(
        insumo=insumo,
        unidad=payload.unidad,
        densidad=payload.densidad,
        equivalencia_g=payload.equivalencia_g,
        require_equivalence=True,
    )
    connection.execute(
        """
        INSERT INTO presentacion (
          id_presentacion, id_insumo, codigo_bf_sunat,
          codigo_presentacion, concentracion, capacidad, unidad,
          tipo_envase, peso_neto_kg, equivalencia_g, densidad,
          vigencia_desde, estado
        ) VALUES (
          %s, %s, %s, %s, %s, %s, %s, %s,
          CASE WHEN %s IS NULL THEN NULL ELSE %s / 1000 END,
          %s, %s, %s, 'VIGENTE'
        )
        """,
        (
            payload.id_presentacion,
            payload.id_insumo,
            payload.codigo_bf_sunat,
            payload.codigo_presentacion,
            payload.concentracion,
            payload.capacidad,
            payload.unidad,
            payload.tipo_envase,
            payload.equivalencia_g,
            payload.equivalencia_g,
            payload.equivalencia_g,
            payload.densidad,
            payload.vigencia_desde,
        ),
    )
    if payload.densidad is not None:
        connection.execute(
            """
            INSERT INTO densidad_vigencia (
              id_presentacion, valor, fuente, vigencia_desde, creado_por
            ) VALUES (%s, %s, 'ALTA_PRESENTACION', %s, %s)
            """,
            (
                payload.id_presentacion,
                payload.densidad,
                payload.vigencia_desde,
                user.id_usuario,
            ),
        )
    return _get_presentation(connection, payload.id_presentacion)


@router.get(
    "/presentaciones/{id_presentacion}",
    response_model=PresentacionOut,
    summary="Consultar una presentación",
)
def get_presentation(
    id_presentacion: str,
    connection: Annotated[Connection, Depends(get_connection)],
    _user: Annotated[CurrentUser, Depends(get_current_user)],
) -> PresentacionOut:
    return _get_presentation(connection, id_presentacion)


@router.patch(
    "/presentaciones/{id_presentacion}",
    response_model=PresentacionOut,
    summary="Editar o inactivar una presentación",
)
def update_presentation(
    id_presentacion: str,
    payload: PresentacionUpdate,
    connection: Annotated[Connection, Depends(get_connection)],
    user: Annotated[
        CurrentUser, Depends(require_roles(*MAINTAINER_ROLES))
    ],
) -> PresentacionOut:
    _require_global_maintainer(user)
    current = _get_presentation(connection, id_presentacion)
    insumo = _get_insumo(connection, current.id_insumo)
    changes = payload.model_dump(exclude_unset=True)
    motivo = changes.pop("motivo", None)
    if not changes:
        return current
    if "estado" in changes and changes["estado"] != current.estado:
        if not motivo:
            raise ProblemException(
                422,
                "MOTIVO_REQUERIDO",
                "Motivo requerido",
                "Indique el motivo del cambio de estado de la presentación.",
                field="motivo",
            )
        connection.execute(
            "SELECT set_config('iqbf.change_reason', %s, true)", (motivo,)
        )
    _validate_presentation_policy(
        insumo=insumo,
        unidad=changes.get("unidad", current.unidad),
        densidad=current.densidad_actual,
        equivalencia_g=changes.get(
            "equivalencia_g", current.equivalencia_g
        ),
    )
    assignments = [
        sql.SQL("{} = %s").format(sql.Identifier(field)) for field in changes
    ]
    if "equivalencia_g" in changes:
        assignments.append(sql.SQL("peso_neto_kg = %s / 1000"))
        values = [*changes.values(), changes["equivalencia_g"]]
    else:
        values = list(changes.values())
    assignments.append(sql.SQL("actualizado_en = now()"))
    query = sql.SQL(
        "UPDATE presentacion SET {} WHERE id_presentacion = %s"
    ).format(sql.SQL(", ").join(assignments))
    result = connection.execute(query, [*values, id_presentacion])
    if result.rowcount == 0:
        _get_presentation(connection, id_presentacion)
    return _get_presentation(connection, id_presentacion)


@router.get(
    "/presentaciones/{id_presentacion}/densidades",
    response_model=list[DensidadOut],
    summary="Consultar el historial de densidades",
)
def list_densities(
    id_presentacion: str,
    connection: Annotated[Connection, Depends(get_connection)],
    _user: Annotated[CurrentUser, Depends(get_current_user)],
) -> list[DensidadOut]:
    _get_presentation(connection, id_presentacion)
    rows = connection.execute(
        """
        SELECT id_densidad, id_presentacion, valor, unidad, fuente,
               vigencia_desde, vigencia_hasta, creado_por, creado_en
          FROM densidad_vigencia
         WHERE id_presentacion = %s
         ORDER BY vigencia_desde DESC, id_densidad DESC
        """,
        (id_presentacion,),
    ).fetchall()
    return [DensidadOut(**row) for row in rows]


@router.post(
    "/presentaciones/{id_presentacion}/densidades",
    response_model=DensidadOut,
    status_code=status.HTTP_201_CREATED,
    summary="Versionar la densidad de una presentación",
)
def create_density(
    id_presentacion: str,
    payload: DensidadCreate,
    connection: Annotated[Connection, Depends(get_connection)],
    user: Annotated[CurrentUser, Depends(require_roles(*MAINTAINER_ROLES))],
) -> DensidadOut:
    _require_global_maintainer(user)
    presentation = _get_presentation(connection, id_presentacion)
    insumo = _get_insumo(connection, presentation.id_insumo)
    if presentation.estado != "VIGENTE" or insumo.estado != "VIGENTE":
        raise ProblemException(
            409,
            "INSUMO_INACTIVO",
            "Maestro inactivo",
            "No se pueden registrar densidades en un maestro inactivo.",
        )
    if insumo.tipo != "LIQUIDO" or insumo.densidad_variable:
        raise ProblemException(
            422,
            "REGLA_NEGOCIO",
            "Densidad no aplicable",
            "La densidad versionada en presentación solo aplica a "
            "líquidos de densidad fija; para densidad variable use el lote.",
        )
    if (
        payload.vigencia_hasta is not None
        and payload.vigencia_hasta < payload.vigencia_desde
    ):
        raise ProblemException(
            422,
            "VIGENCIA_INVALIDA",
            "Vigencia inválida",
            "La fecha final no puede ser anterior a la fecha inicial.",
            field="vigencia_hasta",
        )
    open_version = connection.execute(
        """
        SELECT id_densidad, vigencia_desde
          FROM densidad_vigencia
         WHERE id_presentacion = %s
           AND vigencia_hasta IS NULL
         ORDER BY vigencia_desde DESC, id_densidad DESC
         LIMIT 1
        """,
        (id_presentacion,),
    ).fetchone()
    if open_version is not None:
        if open_version["vigencia_desde"] >= payload.vigencia_desde:
            raise ProblemException(
                409,
                "VIGENCIA_SOLAPADA",
                "Vigencia solapada",
                "La nueva versión debe iniciar después de "
                "la versión abierta actual.",
                field="vigencia_desde",
            )
        connection.execute(
            """
            UPDATE densidad_vigencia
               SET vigencia_hasta = %s::date - 1
             WHERE id_densidad = %s
            """,
            (payload.vigencia_desde, open_version["id_densidad"]),
        )
    row = connection.execute(
        """
        INSERT INTO densidad_vigencia (
          id_presentacion, valor, unidad, fuente,
          vigencia_desde, vigencia_hasta, creado_por
        ) VALUES (%s, %s, %s, %s, %s, %s, %s)
        RETURNING id_densidad, id_presentacion, valor, unidad, fuente,
                  vigencia_desde, vigencia_hasta, creado_por, creado_en
        """,
        (
            id_presentacion,
            payload.valor,
            payload.unidad,
            payload.fuente,
            payload.vigencia_desde,
            payload.vigencia_hasta,
            user.id_usuario,
        ),
    ).fetchone()
    if payload.vigencia_desde <= date.today() and (
        payload.vigencia_hasta is None
        or payload.vigencia_hasta >= date.today()
    ):
        connection.execute(
            """
            UPDATE presentacion
               SET densidad = %s, actualizado_en = now()
             WHERE id_presentacion = %s
            """,
            (payload.valor, id_presentacion),
        )
    return DensidadOut(**row)
