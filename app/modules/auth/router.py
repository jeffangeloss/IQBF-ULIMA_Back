from datetime import datetime, timezone
from ipaddress import ip_address
from typing import Annotated
from uuid import uuid4

from fastapi import APIRouter, Depends, Request, status
from psycopg import Connection

from app.config import Settings, get_settings
from app.database import Database
from app.dependencies import (
    get_connection,
    get_current_user,
    get_database,
)
from app.errors import ProblemException
from app.modules.auth.schemas import CurrentUser, LoginRequest, TokenResponse
from app.security import create_access_token, verify_password


router = APIRouter(prefix="/api/auth", tags=["Autenticación"])


@router.post(
    "/login",
    response_model=TokenResponse,
    status_code=status.HTTP_200_OK,
    summary="Iniciar una sesión local",
)
def login(
    payload: LoginRequest,
    request: Request,
    connection: Annotated[Connection, Depends(get_connection)],
    database: Annotated[Database, Depends(get_database)],
    settings: Annotated[Settings, Depends(get_settings)],
) -> TokenResponse:
    row = connection.execute(
        """
        SELECT u.id_usuario, u.contrasena, u.estado, u.bloqueado_hasta,
               COALESCE(
                 array_agg(ur.codigo_rol ORDER BY ur.codigo_rol)
                   FILTER (WHERE ur.codigo_rol IS NOT NULL),
                 ARRAY[]::varchar[]
               ) AS roles
          FROM usuario u
          LEFT JOIN usuario_rol ur ON ur.id_usuario = u.id_usuario
         WHERE normalizar_busqueda(u.email) = normalizar_busqueda(%s)
         GROUP BY u.id_usuario
        """,
        (str(payload.email),),
    ).fetchone()

    invalid = row is None or not verify_password(
        payload.password, row["contrasena"] if row else ""
    )
    if invalid:
        # US-001 · Hasta ahora `intentos_fallidos` y `bloqueado_hasta` existían
        # en el esquema y el login los LEÍA, pero nada los escribía nunca: la
        # defensa contra adivinación era código muerto y se podían probar
        # contraseñas a 23 por segundo indefinidamente.
        #
        # El bloqueo es temporal y el contador se reinicia con el primer acceso
        # correcto, así que un tecleo torpe no deja fuera a nadie más de unos
        # minutos. No se distingue «cuenta inexistente» de «clave incorrecta»:
        # eso diría a un atacante qué correos existen.
        if row is not None:
            # El intento fallido tiene que SOBREVIVIR al rechazo. La conexión
            # de la petición va dentro de una transacción que se revierte al
            # lanzar el ProblemException: por eso el contador se anotaba y se
            # perdía, y el bloqueo no llegaba nunca. Se usa una conexión propia
            # del pool, que confirma por su cuenta.
            with database.connection_autocommit() as registro:
                registro.execute(
                    """
                    UPDATE usuario
                       SET intentos_fallidos = intentos_fallidos + 1,
                           bloqueado_hasta = CASE
                             WHEN intentos_fallidos + 1 >= %s
                               THEN now() + (%s || ' minutes')::interval
                             ELSE bloqueado_hasta
                           END,
                           actualizado_en = now()
                     WHERE id_usuario = %s
                    """,
                    (
                        settings.max_intentos_fallidos,
                        settings.bloqueo_minutos,
                        row["id_usuario"],
                    ),
                )
        raise ProblemException(
            401,
            "CREDENCIALES_INVALIDAS",
            "Credenciales inválidas",
            "El correo o la contraseña no son correctos.",
        )
    if row["estado"] != "ACTIVO":
        raise ProblemException(
            403,
            "CUENTA_INACTIVA",
            "Cuenta no disponible",
            "La cuenta está bloqueada o inactiva.",
        )
    # Un bloqueo es TEMPORAL: comparar contra NULL lo hacía permanente, y
    # ningún endpoint limpia la columna. Se compara contra el instante actual.
    if row["bloqueado_hasta"] is not None and row["bloqueado_hasta"] > datetime.now(
        timezone.utc
    ):
        raise ProblemException(
            403,
            "CUENTA_BLOQUEADA",
            "Cuenta bloqueada",
            "La cuenta tiene un bloqueo temporal.",
        )
    if not row["roles"]:
        raise ProblemException(
            403,
            "SIN_ROL",
            "Cuenta sin rol",
            "La cuenta no tiene permisos asignados.",
        )

    session_id = uuid4()
    token, expires_at = create_access_token(
        user_id=row["id_usuario"],
        session_id=session_id,
        roles=list(row["roles"]),
        settings=settings,
    )
    client_ip = None
    if request.client:
        try:
            client_ip = str(ip_address(request.client.host))
        except ValueError:
            # TestClient y algunos proxies usan un nombre simbólico.
            client_ip = None
    connection.execute(
        """
        INSERT INTO sesion (
          id_sesion, id_usuario, expira_en, ip_origen, agente_usuario
        ) VALUES (%s, %s, %s, %s, %s)
        """,
        (
            session_id,
            row["id_usuario"],
            expires_at,
            client_ip,
            request.headers.get("user-agent"),
        ),
    )
    connection.execute(
        """
        UPDATE usuario
           SET ultimo_acceso = now(), intentos_fallidos = 0,
               bloqueado_hasta = NULL, actualizado_en = now()
         WHERE id_usuario = %s
        """,
        (row["id_usuario"],),
    )
    return TokenResponse(access_token=token, expires_at=expires_at)


@router.post(
    "/logout",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Cerrar la sesión actual",
)
def logout(
    user: Annotated[CurrentUser, Depends(get_current_user)],
    connection: Annotated[Connection, Depends(get_connection)],
) -> None:
    connection.execute(
        """
        UPDATE sesion
           SET cerrada_en = now()
         WHERE id_sesion = %s AND id_usuario = %s
        """,
        (user.session_id, user.id_usuario),
    )


@router.get(
    "/me",
    response_model=CurrentUser,
    summary="Consultar la identidad y permisos de la sesión",
)
def me(
    user: Annotated[CurrentUser, Depends(get_current_user)],
) -> CurrentUser:
    return user
