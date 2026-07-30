from datetime import UTC, datetime, timedelta
from typing import Any
from uuid import UUID, uuid4

import bcrypt
import jwt
from pwdlib import PasswordHash

from app.config import Settings
from app.errors import ProblemException


_argon2 = PasswordHash.recommended()


def hash_password(password: str) -> str:
    return _argon2.hash(password)


def verify_password(password: str, password_hash: str) -> bool:
    try:
        if password_hash.startswith(("$2a$", "$2b$", "$2y$")):
            return bcrypt.checkpw(
                password.encode("utf-8"), password_hash.encode("utf-8")
            )
        return _argon2.verify(password, password_hash)
    except (ValueError, TypeError):
        return False


def create_access_token(
    *,
    user_id: int,
    session_id: UUID,
    roles: list[str],
    settings: Settings,
) -> tuple[str, datetime]:
    now = datetime.now(UTC)
    expires_at = now + timedelta(minutes=settings.access_token_minutes)
    payload: dict[str, Any] = {
        "sub": str(user_id),
        "sid": str(session_id),
        "jti": str(uuid4()),
        "roles": roles,
        "iat": now,
        "nbf": now,
        "exp": expires_at,
        "iss": "iqbf-ulima-api",
        "aud": "iqbf-ulima-front",
    }
    token = jwt.encode(
        payload,
        settings.jwt_secret.get_secret_value(),
        algorithm=settings.jwt_algorithm,
    )
    return token, expires_at


def decode_access_token(token: str, settings: Settings) -> dict[str, Any]:
    try:
        return jwt.decode(
            token,
            settings.jwt_secret.get_secret_value(),
            algorithms=[settings.jwt_algorithm],
            audience="iqbf-ulima-front",
            issuer="iqbf-ulima-api",
        )
    except jwt.ExpiredSignatureError as error:
        raise ProblemException(
            401,
            "SESION_EXPIRADA",
            "Sesión expirada",
            "Inicie sesión nuevamente.",
        ) from error
    except jwt.PyJWTError as error:
        raise ProblemException(
            401,
            "TOKEN_INVALIDO",
            "Token inválido",
            "La credencial de acceso no es válida.",
        ) from error
