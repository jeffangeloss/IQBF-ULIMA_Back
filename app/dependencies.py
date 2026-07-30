from collections.abc import Callable, Iterator
from typing import Annotated
from uuid import UUID

from fastapi import Depends, Request
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from psycopg import Connection

from app.config import Settings, get_settings
from app.database import Database
from app.errors import ProblemException
from app.modules.auth.schemas import CurrentUser
from app.security import decode_access_token


bearer_scheme = HTTPBearer(auto_error=False)


def get_database(request: Request) -> Database:
    return request.app.state.database


def get_connection(
    request: Request,
    database: Annotated[Database, Depends(get_database)],
) -> Iterator[Connection]:
    with database.connection() as connection:
        request_id = str(request.state.request_id)
        connection.execute(
            "SELECT set_config('iqbf.request_id', %s, true)", (request_id,)
        )
        yield connection


def get_current_user(
    credentials: Annotated[
        HTTPAuthorizationCredentials | None, Depends(bearer_scheme)
    ],
    connection: Annotated[Connection, Depends(get_connection)],
    settings: Annotated[Settings, Depends(get_settings)],
) -> CurrentUser:
    if credentials is None or credentials.scheme.lower() != "bearer":
        raise ProblemException(
            401,
            "NO_AUTENTICADO",
            "Autenticación requerida",
            "Debe iniciar sesión para acceder.",
        )

    payload = decode_access_token(credentials.credentials, settings)
    try:
        user_id = int(payload["sub"])
        session_id = UUID(payload["sid"])
    except (KeyError, TypeError, ValueError) as error:
        raise ProblemException(
            401,
            "TOKEN_INVALIDO",
            "Token inválido",
            "La credencial no contiene una identidad válida.",
        ) from error

    row = connection.execute(
        """
        SELECT u.id_usuario, u.codigo_institucional, u.nombre, u.email,
               u.estado, u.alcance_global,
               COALESCE(
                 array_agg(ur.codigo_rol ORDER BY ur.codigo_rol)
                   FILTER (WHERE ur.codigo_rol IS NOT NULL),
                 ARRAY[]::varchar[]
               ) AS roles
          FROM usuario u
          JOIN sesion s ON s.id_usuario = u.id_usuario
          LEFT JOIN usuario_rol ur ON ur.id_usuario = u.id_usuario
         WHERE u.id_usuario = %s
           AND s.id_sesion = %s
           AND s.revocada_en IS NULL
           AND s.cerrada_en IS NULL
           AND s.expira_en > now()
         GROUP BY u.id_usuario
        """,
        (user_id, session_id),
    ).fetchone()

    if row is None or row["estado"] != "ACTIVO":
        raise ProblemException(
            401,
            "SESION_INVALIDA",
            "Sesión inválida",
            "La sesión fue cerrada, revocada o la cuenta no está activa.",
        )

    connection.execute(
        "SELECT set_config('iqbf.actor_id', %s, true)", (str(user_id),)
    )
    return CurrentUser(**row, session_id=session_id)


def require_roles(*allowed_roles: str) -> Callable[..., CurrentUser]:
    def dependency(
        user: Annotated[CurrentUser, Depends(get_current_user)],
    ) -> CurrentUser:
        if not set(user.roles).intersection(allowed_roles):
            raise ProblemException(
                403,
                "PERMISO_DENEGADO",
                "Permiso denegado",
                "Su rol no permite realizar esta acción.",
            )
        return user

    return dependency
