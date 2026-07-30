from datetime import datetime
from typing import Literal
from uuid import UUID

from pydantic import EmailStr, Field

from app.contracts import ApiModel


RoleCode = Literal[
    "RESPONSABLE_IQBF",
    "OPERADOR_DOCIMASIA",
    "DOCENTE_INVESTIGADOR",
    "APROBADOR",
    "AUDITOR",
    "ADMIN_TECNICO",
]
UserState = Literal["ACTIVO", "BLOQUEADO", "INACTIVO"]


class LoginRequest(ApiModel):
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)


class TokenResponse(ApiModel):
    access_token: str
    token_type: Literal["bearer"] = "bearer"
    expires_at: datetime


class CurrentUser(ApiModel):
    id_usuario: int
    codigo_institucional: str | None
    nombre: str
    email: str
    estado: UserState
    alcance_global: bool
    roles: list[RoleCode]
    session_id: UUID
