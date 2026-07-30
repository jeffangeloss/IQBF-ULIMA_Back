from datetime import datetime
from typing import Annotated

from pydantic import (
    EmailStr,
    Field,
    StringConstraints,
    field_validator,
    model_validator,
)

from app.contracts import ApiModel
from app.modules.auth.schemas import RoleCode, UserState


Code = Annotated[
    str,
    StringConstraints(
        strip_whitespace=True,
        min_length=1,
        max_length=40,
        pattern=r"^[A-Za-z0-9._-]+$",
    ),
]


class UserCreate(ApiModel):
    codigo_institucional: Code
    nombre: str = Field(min_length=2, max_length=120)
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)
    roles: list[RoleCode] = Field(min_length=1)
    alcance_global: bool = False
    establecimientos: list[int] = Field(default_factory=list)
    laboratorios: list[int] = Field(default_factory=list)

    @field_validator("roles")
    @classmethod
    def unique_roles(cls, value: list[str]) -> list[str]:
        return list(dict.fromkeys(value))

    @model_validator(mode="after")
    def validate_scope(self) -> "UserCreate":
        has_scopes = bool(self.establecimientos or self.laboratorios)
        if self.alcance_global and has_scopes:
            raise ValueError(
                "Una cuenta global no debe mezclar alcances específicos."
            )
        if not self.alcance_global and not has_scopes:
            raise ValueError(
                "Una cuenta no global requiere al menos un establecimiento "
                "o laboratorio."
            )
        return self


class UserUpdate(ApiModel):
    nombre: str | None = Field(default=None, min_length=2, max_length=120)
    estado: UserState | None = None
    roles: list[RoleCode] | None = None
    alcance_global: bool | None = None
    establecimientos: list[int] | None = None
    laboratorios: list[int] | None = None

    @field_validator("roles")
    @classmethod
    def unique_updated_roles(
        cls, value: list[str] | None
    ) -> list[str] | None:
        return list(dict.fromkeys(value)) if value is not None else None

    @model_validator(mode="after")
    def reject_explicit_nulls(self) -> "UserUpdate":
        required_when_supplied = {
            "nombre",
            "estado",
            "roles",
            "alcance_global",
            "establecimientos",
            "laboratorios",
        }
        invalid = [
            field
            for field in required_when_supplied & self.model_fields_set
            if getattr(self, field) is None
        ]
        if invalid:
            raise ValueError(
                f"Los campos enviados no aceptan null: {', '.join(invalid)}."
            )
        return self


class UserOut(ApiModel):
    id_usuario: int
    codigo_institucional: str | None
    nombre: str
    email: str
    estado: UserState
    alcance_global: bool
    roles: list[RoleCode]
    establecimientos: list[int]
    laboratorios: list[int]
    ultimo_acceso: datetime | None
