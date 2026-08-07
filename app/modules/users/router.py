from typing import Annotated, Any

from fastapi import APIRouter, Depends, Query, status
from psycopg import Connection, sql

from app.dependencies import get_connection, require_roles
from app.errors import ProblemException
from app.contracts import Page
from app.modules.auth.schemas import CurrentUser
from app.modules.users.schemas import UserCreate, UserOut, UserUpdate
from app.security import hash_password


router = APIRouter(prefix="/api/usuarios", tags=["Usuarios y roles"])
ACCOUNT_READ_ROLES = ("ADMIN_TECNICO", "RESPONSABLE_IQBF")


def _require_global_actor(actor: CurrentUser) -> None:
    if not actor.alcance_global:
        raise ProblemException(
            403,
            "ALCANCE_GLOBAL_REQUERIDO",
            "Alcance global requerido",
            "La administración de cuentas requiere alcance global.",
        )


def _require_actor_role(actor: CurrentUser, role: str, detail: str) -> None:
    if role not in actor.roles:
        raise ProblemException(
            403,
            "PERMISO_DENEGADO",
            "Permiso denegado",
            detail,
        )


def _validate_scopes(
    connection: Connection,
    *,
    global_scope: bool,
    establishments: list[int],
    laboratories: list[int],
) -> None:
    if global_scope and (establishments or laboratories):
        raise ProblemException(
            422,
            "ALCANCE_INVALIDO",
            "Alcance inválido",
            "Una cuenta global no debe mezclar alcances específicos.",
            field="alcance_global",
        )
    if not global_scope and not (establishments or laboratories):
        raise ProblemException(
            422,
            "ALCANCE_INVALIDO",
            "Alcance inválido",
            "Una cuenta no global requiere al menos un establecimiento "
            "o laboratorio.",
            field="laboratorios",
        )
    if establishments:
        valid = connection.execute(
            """
            SELECT id_establecimiento
              FROM establecimiento
             WHERE id_establecimiento = ANY(%s)
               AND estado = 'ACTIVO'
               AND vigencia_desde <= CURRENT_DATE
               AND (vigencia_hasta IS NULL
                    OR vigencia_hasta >= CURRENT_DATE)
            """,
            (establishments,),
        ).fetchall()
        if {row["id_establecimiento"] for row in valid} != set(
            establishments
        ):
            raise ProblemException(
                422,
                "ALCANCE_INVALIDO",
                "Establecimiento inválido",
                "Uno o más establecimientos no existen o no están vigentes.",
                field="establecimientos",
            )
    if laboratories:
        valid = connection.execute(
            """
            SELECT id_laboratorio
              FROM laboratorio
             WHERE id_laboratorio = ANY(%s)
               AND estado = 'ACTIVO'
               AND vigencia_desde <= CURRENT_DATE
               AND (vigencia_hasta IS NULL
                    OR vigencia_hasta >= CURRENT_DATE)
            """,
            (laboratories,),
        ).fetchall()
        if {row["id_laboratorio"] for row in valid} != set(laboratories):
            raise ProblemException(
                422,
                "ALCANCE_INVALIDO",
                "Laboratorio inválido",
                "Uno o más laboratorios no existen o no están vigentes.",
                field="laboratorios",
            )


def _get_user(connection: Connection, user_id: int) -> UserOut:
    row = connection.execute(
        """
        SELECT u.id_usuario, u.codigo_institucional, u.nombre, u.email,
               u.estado, u.alcance_global, u.ultimo_acceso,
               COALESCE(
                 array_agg(DISTINCT ur.codigo_rol)
                   FILTER (WHERE ur.codigo_rol IS NOT NULL),
                 ARRAY[]::varchar[]
               ) AS roles,
               COALESCE(
                 array_agg(DISTINCT ua.id_establecimiento)
                   FILTER (WHERE ua.id_establecimiento IS NOT NULL),
                 ARRAY[]::integer[]
               ) AS establecimientos,
               COALESCE(
                 array_agg(DISTINCT ua.id_laboratorio)
                   FILTER (WHERE ua.id_laboratorio IS NOT NULL),
                 ARRAY[]::integer[]
               ) AS laboratorios
          FROM usuario u
          LEFT JOIN usuario_rol ur ON ur.id_usuario = u.id_usuario
          LEFT JOIN usuario_alcance ua ON ua.id_usuario = u.id_usuario
         WHERE u.id_usuario = %s
         GROUP BY u.id_usuario
        """,
        (user_id,),
    ).fetchone()
    if row is None:
        raise ProblemException(
            404,
            "USUARIO_NO_EXISTE",
            "Usuario inexistente",
            f"No existe el usuario {user_id}.",
        )
    return UserOut(**row)


def _replace_roles(
    connection: Connection,
    user_id: int,
    roles: list[str],
    actor_id: int,
) -> None:
    if not roles:
        raise ProblemException(
            422,
            "ROL_REQUERIDO",
            "Rol requerido",
            "Una cuenta activa debe tener al menos un rol.",
            field="roles",
        )
    valid = connection.execute(
        "SELECT codigo FROM rol WHERE codigo = ANY(%s) AND estado = 'ACTIVO'",
        (roles,),
    ).fetchall()
    if {row["codigo"] for row in valid} != set(roles):
        raise ProblemException(
            422,
            "ROL_INVALIDO",
            "Rol inválido",
            "Uno o más roles no existen o están inactivos.",
            field="roles",
        )
    connection.execute(
        "DELETE FROM usuario_rol WHERE id_usuario = %s", (user_id,)
    )
    with connection.cursor() as cursor:
        cursor.executemany(
            """
            INSERT INTO usuario_rol (id_usuario, codigo_rol, asignado_por)
            VALUES (%s, %s, %s)
            """,
            [(user_id, role, actor_id) for role in roles],
        )


def _replace_scopes(
    connection: Connection,
    user_id: int,
    establishments: list[int],
    laboratories: list[int],
    actor_id: int,
) -> None:
    connection.execute(
        "DELETE FROM usuario_alcance WHERE id_usuario = %s", (user_id,)
    )
    if establishments:
        with connection.cursor() as cursor:
            cursor.executemany(
                """
                INSERT INTO usuario_alcance (
                  id_usuario, id_establecimiento, asignado_por
                ) VALUES (%s, %s, %s)
                """,
                [(user_id, item, actor_id) for item in establishments],
            )
    if laboratories:
        with connection.cursor() as cursor:
            cursor.executemany(
                """
                INSERT INTO usuario_alcance (
                  id_usuario, id_laboratorio, asignado_por
                ) VALUES (%s, %s, %s)
                """,
                [(user_id, item, actor_id) for item in laboratories],
            )


@router.get("", response_model=Page[UserOut], summary="Listar cuentas")
def list_users(
    connection: Annotated[Connection, Depends(get_connection)],
    actor: Annotated[
        CurrentUser, Depends(require_roles(*ACCOUNT_READ_ROLES))
    ],
    q: Annotated[str | None, Query(max_length=120)] = None,
    estado: Annotated[str | None, Query(max_length=20)] = None,
    page: Annotated[int, Query(ge=1)] = 1,
    page_size: Annotated[int, Query(ge=1, le=100)] = 20,
) -> Page[UserOut]:
    _require_global_actor(actor)
    conditions: list[str] = []
    params: list[Any] = []
    if q:
        conditions.append(
            """
            (normalizar_busqueda(u.nombre) LIKE normalizar_busqueda(%s)
             OR normalizar_busqueda(u.email) LIKE normalizar_busqueda(%s)
             OR normalizar_busqueda(COALESCE(u.codigo_institucional, ''))
                LIKE normalizar_busqueda(%s))
            """
        )
        pattern = f"%{q}%"
        params.extend([pattern, pattern, pattern])
    if estado:
        conditions.append("u.estado = %s")
        params.append(estado)
    where = "WHERE " + " AND ".join(conditions) if conditions else ""
    total = connection.execute(
        f"SELECT count(*) AS total FROM usuario u {where}", params
    ).fetchone()["total"]
    ids = connection.execute(
        f"""
        SELECT u.id_usuario
          FROM usuario u
          {where}
         ORDER BY normalizar_busqueda(u.nombre)
         LIMIT %s OFFSET %s
        """,
        [*params, page_size, (page - 1) * page_size],
    ).fetchall()
    return Page[UserOut](
        items=[_get_user(connection, row["id_usuario"]) for row in ids],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.post(
    "",
    response_model=UserOut,
    status_code=status.HTTP_201_CREATED,
    summary="Crear una cuenta y asignar sus roles",
)
def create_user(
    payload: UserCreate,
    connection: Annotated[Connection, Depends(get_connection)],
    actor: Annotated[
        CurrentUser, Depends(require_roles("ADMIN_TECNICO"))
    ],
) -> UserOut:
    _require_global_actor(actor)
    _validate_scopes(
        connection,
        global_scope=payload.alcance_global,
        establishments=payload.establecimientos,
        laboratories=payload.laboratorios,
    )
    legacy_role = (
        "ADMIN"
        if "ADMIN_TECNICO" in payload.roles
        else "DOCIMASIA"
    )
    row = connection.execute(
        """
        INSERT INTO usuario (
          codigo_institucional, nombre, email, contrasena,
          rol, estado, alcance_global
        ) VALUES (%s, %s, %s, %s, %s, 'ACTIVO', %s)
        RETURNING id_usuario
        """,
        (
            payload.codigo_institucional,
            payload.nombre,
            str(payload.email),
            hash_password(payload.password),
            legacy_role,
            payload.alcance_global,
        ),
    ).fetchone()
    _replace_roles(connection, row["id_usuario"], payload.roles, actor.id_usuario)
    _replace_scopes(
        connection,
        row["id_usuario"],
        payload.establecimientos,
        payload.laboratorios,
        actor.id_usuario,
    )
    return _get_user(connection, row["id_usuario"])


@router.get(
    "/{user_id}",
    response_model=UserOut,
    summary="Consultar una cuenta",
)
def get_user(
    user_id: int,
    connection: Annotated[Connection, Depends(get_connection)],
    actor: Annotated[
        CurrentUser, Depends(require_roles(*ACCOUNT_READ_ROLES))
    ],
) -> UserOut:
    _require_global_actor(actor)
    return _get_user(connection, user_id)


@router.patch(
    "/{user_id}",
    response_model=UserOut,
    summary="Cambiar estado, roles o alcance de una cuenta",
)
def update_user(
    user_id: int,
    payload: UserUpdate,
    connection: Annotated[Connection, Depends(get_connection)],
    actor: Annotated[
        CurrentUser, Depends(require_roles(*ACCOUNT_READ_ROLES))
    ],
) -> UserOut:
    _require_global_actor(actor)
    current = _get_user(connection, user_id)
    if payload.roles is not None:
        _require_actor_role(
            actor,
            "RESPONSABLE_IQBF",
            "Solo el responsable IQBF puede cambiar los roles.",
        )
    account_fields_changed = any(
        value is not None
        for value in (
            payload.nombre,
            payload.estado,
            payload.alcance_global,
            payload.establecimientos,
            payload.laboratorios,
        )
    )
    if account_fields_changed:
        _require_actor_role(
            actor,
            "ADMIN_TECNICO",
            "Solo el administrador técnico puede cambiar la cuenta "
            "o sus alcances.",
        )

    final_global = (
        payload.alcance_global
        if payload.alcance_global is not None
        else current.alcance_global
    )
    final_establishments = (
        payload.establecimientos
        if payload.establecimientos is not None
        else current.establecimientos
    )
    final_laboratories = (
        payload.laboratorios
        if payload.laboratorios is not None
        else current.laboratorios
    )
    # El alcance solo se revalida cuando el alcance CAMBIA. Antes bastaba con
    # tocar `estado` para que se revalidaran los alcances ya existentes, y una
    # cuenta cuyo laboratorio dejó de estar vigente no se podía bloquear ni
    # desactivar: 422 ALCANCE_INVALIDO y la cuenta seguía entrando. Cortar el
    # acceso de una cuenta no puede depender de la vigencia de su laboratorio.
    scope_changed = any(
        value is not None
        for value in (
            payload.alcance_global,
            payload.establecimientos,
            payload.laboratorios,
        )
    )
    if scope_changed:
        _validate_scopes(
            connection,
            global_scope=final_global,
            establishments=final_establishments,
            laboratories=final_laboratories,
        )
    values = payload.model_dump(
        exclude_unset=True,
        exclude={"roles", "establecimientos", "laboratorios"},
    )
    if values:
        assignments = [
            sql.SQL("{} = %s").format(sql.Identifier(field))
            for field in values
        ]
        assignments.append(sql.SQL("actualizado_en = now()"))
        connection.execute(
            sql.SQL("UPDATE usuario SET {} WHERE id_usuario = %s").format(
                sql.SQL(", ").join(assignments)
            ),
            [*values.values(), user_id],
        )
    if payload.roles is not None:
        _replace_roles(
            connection, user_id, payload.roles, actor.id_usuario
        )
    if (
        payload.establecimientos is not None
        or payload.laboratorios is not None
    ):
        current = _get_user(connection, user_id)
        _replace_scopes(
            connection,
            user_id,
            final_establishments,
            final_laboratories,
            actor.id_usuario,
        )
    if payload.estado in {"BLOQUEADO", "INACTIVO"}:
        connection.execute(
            """
            UPDATE sesion
               SET revocada_en = now()
             WHERE id_usuario = %s
               AND revocada_en IS NULL
               AND cerrada_en IS NULL
            """,
            (user_id,),
        )
    return _get_user(connection, user_id)
