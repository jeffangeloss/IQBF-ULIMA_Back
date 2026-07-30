import csv
from datetime import date
from io import StringIO
import json
from typing import Annotated, Any, Literal

from fastapi import APIRouter, Depends, Query, status
from fastapi.responses import Response
from psycopg import Connection, sql

from app.dependencies import get_connection, get_current_user, require_roles
from app.errors import ProblemException
from app.modules.auth.schemas import CurrentUser
from app.modules.catalogs.schemas import (
    CatalogCreate,
    CatalogItem,
    CatalogName,
    CatalogUpdate,
)


router = APIRouter(prefix="/api/catalogos", tags=["Catálogos"])
MAINTAINER_ROLES = ("RESPONSABLE_IQBF",)


CATALOGS: dict[str, dict[str, Any]] = {
    "establecimientos": {
        "table": "establecimiento",
        "id": "id_establecimiento",
        "code": "codigo",
        "name": "nombre",
        "state": "estado",
        "valid_from": "vigencia_desde",
        "valid_to": "vigencia_hasta",
        "metadata": "'{}'::jsonb",
        "write_fields": ["codigo", "nombre", "vigencia_desde"],
    },
    "carreras": {
        "table": "carrera",
        "id": "id_carrera",
        "code": "codigo",
        "name": "nombre",
        "state": "estado",
        "valid_from": "vigencia_desde",
        "valid_to": "vigencia_hasta",
        "metadata": "'{}'::jsonb",
        "write_fields": ["codigo", "nombre", "vigencia_desde"],
    },
    "laboratorios": {
        "table": "laboratorio",
        "id": "id_laboratorio",
        "code": "codigo",
        "name": "nombre",
        "state": "estado",
        "valid_from": "vigencia_desde",
        "valid_to": "vigencia_hasta",
        "metadata": (
            "jsonb_build_object("
            "'id_carrera', id_carrera, "
            "'id_establecimiento', id_establecimiento)"
        ),
        "write_fields": [
            "codigo",
            "nombre",
            "id_carrera",
            "id_establecimiento",
            "vigencia_desde",
        ],
    },
    "ubicaciones": {
        "table": "ubicacion",
        "id": "id_ubicacion",
        "code": "codigo",
        "name": "nombre",
        "state": "estado",
        "valid_from": "vigencia_desde",
        "valid_to": "vigencia_hasta",
        "metadata": (
            "jsonb_build_object("
            "'id_laboratorio', id_laboratorio, "
            "'id_establecimiento', id_establecimiento)"
        ),
        "write_fields": [
            "codigo",
            "nombre",
            "id_establecimiento",
            "id_laboratorio",
            "vigencia_desde",
        ],
    },
    "investigadores": {
        "table": "investigador",
        "id": "id_investigador",
        "code": "codigo_institucional",
        "name": "nombre",
        "state": "estado",
        "valid_from": "vigencia_desde",
        "valid_to": "vigencia_hasta",
        "metadata": (
            "jsonb_build_object("
            "'tipo', tipo, 'email', email, "
            "'id_carrera', id_carrera, 'id_laboratorio', id_laboratorio)"
        ),
        "write_fields": [
            "codigo_institucional",
            "nombre",
            "tipo",
            "email",
            "id_carrera",
            "id_laboratorio",
            "vigencia_desde",
        ],
    },
    "roles": {
        "table": "rol",
        "id": "codigo",
        "code": "codigo",
        "name": "nombre",
        "state": "estado",
        "valid_from": "NULL::date",
        "valid_to": "NULL::date",
        "metadata": "jsonb_build_object('descripcion', descripcion)",
        "write_fields": [],
    },
}


def _require_global_maintainer(user: CurrentUser) -> None:
    if not user.alcance_global:
        raise ProblemException(
            403,
            "ALCANCE_GLOBAL_REQUERIDO",
            "Alcance global requerido",
            "Los catálogos maestros solo pueden modificarse con alcance global.",
        )


def _ensure_active_reference(
    connection: Connection,
    *,
    table: str,
    id_column: str,
    item_id: int | None,
    field: str,
) -> None:
    if item_id is None:
        return
    query = sql.SQL(
        """
        SELECT EXISTS (
          SELECT 1 FROM {table}
           WHERE {id_column} = %s
             AND estado = 'ACTIVO'
             AND vigencia_desde <= CURRENT_DATE
             AND (vigencia_hasta IS NULL
                  OR vigencia_hasta >= CURRENT_DATE)
        ) AS valida
        """
    ).format(
        table=sql.Identifier(table),
        id_column=sql.Identifier(id_column),
    )
    if not connection.execute(query, (item_id,)).fetchone()["valida"]:
        raise ProblemException(
            422,
            "REFERENCIA_INVALIDA",
            "Referencia no vigente",
            f"El valor indicado en {field} no existe o no está vigente.",
            field=field,
        )


def _validate_catalog_references(
    connection: Connection,
    catalogo: CatalogName,
    values: dict[str, Any],
) -> None:
    references = {
        "id_establecimiento": (
            "establecimiento",
            "id_establecimiento",
        ),
        "id_carrera": ("carrera", "id_carrera"),
        "id_laboratorio": ("laboratorio", "id_laboratorio"),
    }
    for field, (table, id_column) in references.items():
        if field in values:
            _ensure_active_reference(
                connection,
                table=table,
                id_column=id_column,
                item_id=values[field],
                field=field,
            )
    if catalogo == "ubicaciones" and values.get("id_laboratorio"):
        belongs = connection.execute(
            """
            SELECT id_establecimiento
              FROM laboratorio
             WHERE id_laboratorio = %s
            """,
            (values["id_laboratorio"],),
        ).fetchone()
        if (
            belongs is not None
            and values.get("id_establecimiento") is not None
            and belongs["id_establecimiento"]
            != values["id_establecimiento"]
        ):
            raise ProblemException(
                422,
                "REFERENCIA_INVALIDA",
                "Laboratorio incompatible",
                "El laboratorio no pertenece al establecimiento indicado.",
                field="id_laboratorio",
            )


def _catalog_definition(
    catalog: CatalogName, *, writable: bool = False
) -> dict[str, Any]:
    definition = CATALOGS.get(catalog)
    if definition is None:
        raise ProblemException(
            404,
            "CATALOGO_NO_EXISTE",
            "Catálogo inexistente",
            f"El catálogo '{catalog}' no está disponible.",
        )
    if writable and not definition["write_fields"]:
        raise ProblemException(
            405,
            "CATALOGO_SOLO_LECTURA",
            "Catálogo de solo lectura",
            f"El catálogo '{catalog}' no se modifica por este endpoint.",
        )
    return definition


def _catalog_select(
    connection: Connection,
    definition: dict[str, Any],
    *,
    item_id: int | str,
) -> CatalogItem:
    query = sql.SQL(
        """
        SELECT {id}::text AS id, {code} AS codigo, {name} AS nombre,
               {state} AS estado,
               {valid_from} AS vigencia_desde,
               {valid_to} AS vigencia_hasta,
               {metadata} AS metadata
          FROM {table}
         WHERE {id} = %s
        """
    ).format(
        id=sql.Identifier(definition["id"]),
        code=sql.Identifier(definition["code"]),
        name=sql.Identifier(definition["name"]),
        state=sql.Identifier(definition["state"]),
        valid_from=sql.SQL(definition["valid_from"]),
        valid_to=sql.SQL(definition["valid_to"]),
        metadata=sql.SQL(definition["metadata"]),
        table=sql.Identifier(definition["table"]),
    )
    row = connection.execute(query, (item_id,)).fetchone()
    if row is None:
        raise ProblemException(
            404,
            "REGISTRO_NO_EXISTE",
            "Registro inexistente",
            "No existe el registro solicitado.",
        )
    return CatalogItem(**row)


@router.get(
    "/{catalogo}",
    response_model=list[CatalogItem],
    summary="Listar un catálogo controlado",
)
def list_catalog(
    catalogo: CatalogName,
    connection: Annotated[Connection, Depends(get_connection)],
    user: Annotated[CurrentUser, Depends(get_current_user)],
    q: Annotated[str | None, Query(max_length=120)] = None,
    estado: Annotated[
        Literal["ACTIVO", "INACTIVO", "TODOS"], Query()
    ] = "ACTIVO",
) -> list[CatalogItem]:
    definition = _catalog_definition(catalogo)

    where = []
    params: list[Any] = []
    if estado != "TODOS":
        where.append(sql.SQL("{} = %s").format(sql.Identifier(definition["state"])))
        params.append(estado)
        if estado == "ACTIVO" and catalogo != "roles":
            where.append(
                sql.SQL(
                    "{valid_from} <= CURRENT_DATE AND "
                    "({valid_to} IS NULL OR {valid_to} >= CURRENT_DATE)"
                ).format(
                    valid_from=sql.SQL(definition["valid_from"]),
                    valid_to=sql.SQL(definition["valid_to"]),
                )
            )
    if q:
        where.append(
            sql.SQL(
                "(normalizar_busqueda({name}) LIKE "
                "normalizar_busqueda(%s) OR "
                "normalizar_busqueda(COALESCE({code}, '')) LIKE "
                "normalizar_busqueda(%s))"
            ).format(
                name=sql.Identifier(definition["name"]),
                code=sql.Identifier(definition["code"]),
            )
        )
        pattern = f"%{q}%"
        params.extend([pattern, pattern])
    if not user.alcance_global:
        scope_conditions = {
            "establecimientos": """
              EXISTS (
                SELECT 1 FROM usuario_alcance ua
                 WHERE ua.id_usuario = %s
                   AND (
                     ua.id_establecimiento = establecimiento.id_establecimiento
                     OR ua.id_laboratorio IN (
                       SELECT l.id_laboratorio FROM laboratorio l
                        WHERE l.id_establecimiento =
                              establecimiento.id_establecimiento
                     )
                   )
              )
            """,
            "carreras": """
              EXISTS (
                SELECT 1
                  FROM laboratorio l
                  JOIN usuario_alcance ua
                    ON ua.id_usuario = %s
                   AND (
                     ua.id_laboratorio = l.id_laboratorio
                     OR ua.id_establecimiento = l.id_establecimiento
                   )
                 WHERE l.id_carrera = carrera.id_carrera
              )
            """,
            "laboratorios": """
              EXISTS (
                SELECT 1 FROM usuario_alcance ua
                 WHERE ua.id_usuario = %s
                   AND (
                     ua.id_laboratorio = laboratorio.id_laboratorio
                     OR ua.id_establecimiento =
                        laboratorio.id_establecimiento
                   )
              )
            """,
            "ubicaciones": """
              EXISTS (
                SELECT 1 FROM usuario_alcance ua
                 WHERE ua.id_usuario = %s
                   AND (
                     ua.id_laboratorio = ubicacion.id_laboratorio
                     OR ua.id_establecimiento = ubicacion.id_establecimiento
                   )
              )
            """,
            "investigadores": """
              EXISTS (
                SELECT 1 FROM usuario_alcance ua
                 WHERE ua.id_usuario = %s
                   AND (
                     ua.id_laboratorio = investigador.id_laboratorio
                     OR EXISTS (
                       SELECT 1 FROM laboratorio l
                        WHERE (
                          l.id_laboratorio = investigador.id_laboratorio
                          OR l.id_carrera = investigador.id_carrera
                        )
                          AND (
                            ua.id_laboratorio = l.id_laboratorio
                            OR ua.id_establecimiento =
                               l.id_establecimiento
                          )
                     )
                   )
              )
            """,
        }
        scope = scope_conditions.get(catalogo)
        if scope:
            where.append(sql.SQL(scope))
            params.append(user.id_usuario)

    query = sql.SQL(
        """
        SELECT {id}::text AS id, {code} AS codigo, {name} AS nombre,
               {state} AS estado,
               {valid_from} AS vigencia_desde,
               {valid_to} AS vigencia_hasta,
               {metadata} AS metadata
          FROM {table}
         {where}
         ORDER BY normalizar_busqueda({name})
        """
    ).format(
        id=sql.Identifier(definition["id"]),
        code=sql.Identifier(definition["code"]),
        name=sql.Identifier(definition["name"]),
        state=sql.Identifier(definition["state"]),
        valid_from=sql.SQL(definition["valid_from"]),
        valid_to=sql.SQL(definition["valid_to"]),
        metadata=sql.SQL(definition["metadata"]),
        table=sql.Identifier(definition["table"]),
        where=(
            sql.SQL("WHERE ") + sql.SQL(" AND ").join(where)
            if where
            else sql.SQL("")
        ),
    )
    rows = connection.execute(query, params).fetchall()
    return [CatalogItem(**row) for row in rows]


@router.post(
    "/{catalogo}",
    response_model=CatalogItem,
    status_code=status.HTTP_201_CREATED,
    summary="Crear un valor de catálogo",
)
def create_catalog_item(
    catalogo: CatalogName,
    payload: CatalogCreate,
    connection: Annotated[Connection, Depends(get_connection)],
    user: Annotated[
        CurrentUser, Depends(require_roles(*MAINTAINER_ROLES))
    ],
) -> CatalogItem:
    _require_global_maintainer(user)
    definition = _catalog_definition(catalogo, writable=True)
    raw = payload.model_dump(exclude_unset=True)
    if catalogo == "investigadores":
        raw["codigo_institucional"] = raw.pop("codigo")
        raw.setdefault("tipo", "PERSONA")
    allowed = definition["write_fields"]
    values = {key: raw[key] for key in allowed if key in raw}

    if catalogo == "laboratorios" and not values.get("id_establecimiento"):
        raise ProblemException(
            422,
            "ESTABLECIMIENTO_REQUERIDO",
            "Establecimiento requerido",
            "Un laboratorio debe pertenecer a un establecimiento.",
            field="id_establecimiento",
        )
    if catalogo == "ubicaciones" and not values.get("id_establecimiento"):
        raise ProblemException(
            422,
            "ESTABLECIMIENTO_REQUERIDO",
            "Establecimiento requerido",
            "Una ubicación debe pertenecer a un establecimiento.",
            field="id_establecimiento",
        )
    if catalogo == "investigadores" and not values.get(
        "codigo_institucional"
    ):
        raise ProblemException(
            422,
            "CODIGO_INSTITUCIONAL_REQUERIDO",
            "Código institucional requerido",
            "Una persona nueva debe tener identificador institucional.",
            field="codigo",
        )
    if catalogo == "investigadores" and not (
        values.get("id_carrera") or values.get("id_laboratorio")
    ):
        raise ProblemException(
            422,
            "ALCANCE_INVALIDO",
            "Asociación requerida",
            "Una persona o área nueva debe asociarse a una carrera "
            "o laboratorio.",
            field="id_laboratorio",
        )
    _validate_catalog_references(connection, catalogo, values)

    query = sql.SQL("INSERT INTO {table} ({fields}) VALUES ({values}) RETURNING {id}").format(
        table=sql.Identifier(definition["table"]),
        fields=sql.SQL(", ").join(sql.Identifier(key) for key in values),
        values=sql.SQL(", ").join(sql.Placeholder() for _ in values),
        id=sql.Identifier(definition["id"]),
    )
    row = connection.execute(query, list(values.values())).fetchone()
    return _catalog_select(connection, definition, item_id=row[definition["id"]])


@router.patch(
    "/{catalogo}/{item_id}",
    response_model=CatalogItem,
    summary="Editar o inactivar un valor de catálogo",
)
def update_catalog_item(
    catalogo: CatalogName,
    item_id: int,
    payload: CatalogUpdate,
    connection: Annotated[Connection, Depends(get_connection)],
    user: Annotated[
        CurrentUser, Depends(require_roles(*MAINTAINER_ROLES))
    ],
) -> CatalogItem:
    _require_global_maintainer(user)
    definition = _catalog_definition(catalogo, writable=True)
    _catalog_select(connection, definition, item_id=item_id)
    raw = payload.model_dump(exclude_unset=True)
    if catalogo == "investigadores" and "codigo" in raw:
        raw["codigo_institucional"] = raw.pop("codigo")
    allowed = [*definition["write_fields"], "estado", "vigencia_hasta"]
    values = {key: raw[key] for key in allowed if key in raw}
    if values.get("estado") == "INACTIVO":
        values.setdefault("vigencia_hasta", date.today())
    if catalogo in {"laboratorios", "ubicaciones"}:
        required = "id_establecimiento"
        if required in values and values[required] is None:
            raise ProblemException(
                422,
                "ESTABLECIMIENTO_REQUERIDO",
                "Establecimiento requerido",
                "El registro debe pertenecer a un establecimiento.",
                field=required,
            )
    if catalogo == "investigadores" and (
        "id_carrera" in values or "id_laboratorio" in values
    ):
        current = connection.execute(
            """
            SELECT id_carrera, id_laboratorio
              FROM investigador
             WHERE id_investigador = %s
            """,
            (item_id,),
        ).fetchone()
        final_career = values.get("id_carrera", current["id_carrera"])
        final_lab = values.get("id_laboratorio", current["id_laboratorio"])
        if final_career is None and final_lab is None:
            raise ProblemException(
                422,
                "ALCANCE_INVALIDO",
                "Asociación requerida",
                "Una persona o área debe conservar una carrera "
                "o laboratorio.",
                field="id_laboratorio",
            )
    _validate_catalog_references(connection, catalogo, values)
    if not values:
        return _catalog_select(connection, definition, item_id=item_id)
    assignments = [
        sql.SQL("{} = %s").format(sql.Identifier(key)) for key in values
    ]
    query = sql.SQL("UPDATE {table} SET {values} WHERE {id} = %s").format(
        table=sql.Identifier(definition["table"]),
        values=sql.SQL(", ").join(assignments),
        id=sql.Identifier(definition["id"]),
    )
    connection.execute(query, [*values.values(), item_id])
    return _catalog_select(connection, definition, item_id=item_id)


@router.get(
    "/export/{catalogo}.csv",
    response_class=Response,
    summary="Exportar un catálogo respetando el alcance del usuario",
)
def export_catalog(
    catalogo: CatalogName,
    connection: Annotated[Connection, Depends(get_connection)],
    user: Annotated[CurrentUser, Depends(get_current_user)],
    q: Annotated[str | None, Query(max_length=120)] = None,
    estado: Annotated[
        Literal["ACTIVO", "INACTIVO", "TODOS"], Query()
    ] = "ACTIVO",
) -> Response:
    items = list_catalog(
        catalogo=catalogo,
        connection=connection,
        user=user,
        q=q,
        estado=estado,
    )
    stream = StringIO(newline="")
    writer = csv.writer(stream)
    writer.writerow(
        [
            "id",
            "codigo",
            "nombre",
            "estado",
            "vigencia_desde",
            "vigencia_hasta",
            "metadata",
        ]
    )
    for item in items:
        writer.writerow(
            [
                item.id,
                item.codigo or "",
                item.nombre,
                item.estado,
                item.vigencia_desde.isoformat()
                if item.vigencia_desde
                else "",
                item.vigencia_hasta.isoformat()
                if item.vigencia_hasta
                else "",
                json.dumps(
                    item.metadata.model_dump(mode="json"),
                    ensure_ascii=False,
                    separators=(",", ":"),
                ),
            ]
        )
    return Response(
        content=stream.getvalue(),
        media_type="text/csv",
        headers={
            "Content-Disposition": (
                f'attachment; filename="{catalogo}-iqbf.csv"'
            )
        },
    )
