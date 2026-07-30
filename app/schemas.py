from datetime import date, datetime
from decimal import Decimal
from typing import Annotated, Generic, Literal, TypeVar
from uuid import UUID

from pydantic import (
    BaseModel,
    ConfigDict,
    EmailStr,
    Field,
    PlainSerializer,
    StringConstraints,
    WithJsonSchema,
    field_validator,
    model_validator,
)


DecimalString = Annotated[
    Decimal,
    PlainSerializer(lambda value: format(value, "f"), return_type=str),
    WithJsonSchema(
        {
            "type": "string",
            "pattern": r"^-?\d+(\.\d+)?$",
            "example": "1250.0000",
        }
    ),
]
Code = Annotated[
    str,
    StringConstraints(
        strip_whitespace=True,
        min_length=1,
        max_length=40,
        pattern=r"^[A-Za-z0-9._-]+$",
    ),
]
CatalogCode = Annotated[
    str,
    StringConstraints(
        strip_whitespace=True,
        min_length=1,
        max_length=30,
        pattern=r"^[A-Za-z0-9._-]+$",
    ),
]
InsumoCode = Annotated[
    str,
    StringConstraints(
        strip_whitespace=True,
        min_length=1,
        max_length=20,
        pattern=r"^[A-Za-z0-9._-]+$",
    ),
]
PresentationCode = Annotated[
    str,
    StringConstraints(
        strip_whitespace=True,
        min_length=1,
        max_length=30,
        pattern=r"^[A-Za-z0-9._-]+$",
    ),
]
RoleCode = Literal[
    "RESPONSABLE_IQBF",
    "OPERADOR_DOCIMASIA",
    "DOCENTE_INVESTIGADOR",
    "APROBADOR",
    "AUDITOR",
    "ADMIN_TECNICO",
]
CatalogName = Literal[
    "establecimientos",
    "carreras",
    "laboratorios",
    "ubicaciones",
    "investigadores",
    "roles",
]
CatalogState = Literal["ACTIVO", "INACTIVO"]
InsumoType = Literal["LIQUIDO", "SOLIDO"]
InsumoState = Literal["VIGENTE", "INACTIVO"]
UserState = Literal["ACTIVO", "BLOQUEADO", "INACTIVO"]
ProblemCode = Literal[
    "VALIDACION",
    "ERROR_INTERNO",
    "ERROR_BASE_DATOS",
    "REGISTRO_DUPLICADO",
    "REFERENCIA_INVALIDA",
    "REGLA_NEGOCIO",
    "SALDO_INSUFICIENTE",
    "KARDEX_INMUTABLE",
    "SALDO_SOLO_VIA_KARDEX",
    "DENSIDAD_REQUERIDA",
    "VIGENCIA_SOLAPADA",
    "SESION_EXPIRADA",
    "TOKEN_INVALIDO",
    "NO_AUTENTICADO",
    "SESION_INVALIDA",
    "CREDENCIALES_INVALIDAS",
    "CUENTA_INACTIVA",
    "CUENTA_BLOQUEADA",
    "SIN_ROL",
    "PERMISO_DENEGADO",
    "CATALOGO_NO_EXISTE",
    "CATALOGO_SOLO_LECTURA",
    "REGISTRO_NO_EXISTE",
    "ESTABLECIMIENTO_REQUERIDO",
    "CODIGO_INSTITUCIONAL_REQUERIDO",
    "INSUMO_NO_EXISTE",
    "PRESENTACION_NO_EXISTE",
    "VIGENCIA_INVALIDA",
    "USUARIO_NO_EXISTE",
    "ROL_REQUERIDO",
    "ROL_INVALIDO",
    "ALCANCE_INVALIDO",
    "ALCANCE_GLOBAL_REQUERIDO",
    "MOTIVO_REQUERIDO",
    "DENSIDAD_LOTE_REQUERIDA",
    "INSUMO_INACTIVO",
]


class ApiModel(BaseModel):
    model_config = ConfigDict(
        from_attributes=True,
        str_strip_whitespace=True,
        json_encoders={Decimal: lambda value: format(value, "f")},
    )


class ProblemFieldError(ApiModel):
    field: str
    message: str
    type: str


class Problem(ApiModel):
    type: str
    title: str
    status: int
    detail: str
    instance: str
    code: ProblemCode
    request_id: str
    field: str | None = None
    errors: list[ProblemFieldError] | None = None


class Health(ApiModel):
    status: Literal["ok"]
    database: Literal["ok"]
    version: str


T = TypeVar("T")


class Page(ApiModel, Generic[T]):
    items: list[T]
    total: int
    page: int
    page_size: int


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


class CatalogMetadata(ApiModel):
    id_establecimiento: int | None = None
    id_carrera: int | None = None
    id_laboratorio: int | None = None
    tipo: Literal["PERSONA", "AREA"] | None = None
    email: str | None = None
    descripcion: str | None = None


class CatalogItem(ApiModel):
    id: str
    codigo: str | None
    nombre: str
    estado: CatalogState
    vigencia_desde: date | None = None
    vigencia_hasta: date | None = None
    metadata: CatalogMetadata = Field(default_factory=CatalogMetadata)


class CatalogCreate(ApiModel):
    codigo: CatalogCode
    nombre: str = Field(min_length=2, max_length=160)
    vigencia_desde: date = Field(default_factory=date.today)
    id_establecimiento: int | None = None
    id_carrera: int | None = None
    id_laboratorio: int | None = None
    tipo: Literal["PERSONA", "AREA"] | None = None
    email: EmailStr | None = None


class CatalogUpdate(ApiModel):
    codigo: CatalogCode | None = None
    nombre: str | None = Field(default=None, min_length=2, max_length=160)
    estado: Literal["ACTIVO", "INACTIVO"] | None = None
    vigencia_hasta: date | None = None
    id_establecimiento: int | None = None
    id_carrera: int | None = None
    id_laboratorio: int | None = None
    tipo: Literal["PERSONA", "AREA"] | None = None
    email: EmailStr | None = None

    @model_validator(mode="after")
    def reject_required_nulls(self) -> "CatalogUpdate":
        invalid = [
            field
            for field in {"codigo", "nombre", "estado"} & self.model_fields_set
            if getattr(self, field) is None
        ]
        if invalid:
            raise ValueError(
                f"Los campos enviados no aceptan null: {', '.join(invalid)}."
            )
        return self


class InsumoCreate(ApiModel):
    id_insumo: InsumoCode
    nombre_comercial: str = Field(min_length=2, max_length=160)
    tipo: InsumoType
    unidad_base: Literal["g"] = "g"
    densidad_variable: bool = False

    @model_validator(mode="after")
    def validate_density_policy(self) -> "InsumoCreate":
        if self.densidad_variable and self.tipo != "LIQUIDO":
            raise ValueError(
                "Solo un insumo líquido puede tener densidad variable."
            )
        return self


class InsumoUpdate(ApiModel):
    nombre_comercial: str | None = Field(
        default=None, min_length=2, max_length=160
    )
    tipo: InsumoType | None = None
    estado: InsumoState | None = None
    densidad_variable: bool | None = None
    motivo: str | None = Field(default=None, min_length=3, max_length=500)

    @model_validator(mode="after")
    def reject_required_nulls(self) -> "InsumoUpdate":
        invalid = [
            field
            for field in {
                "nombre_comercial",
                "tipo",
                "estado",
                "densidad_variable",
            }
            & self.model_fields_set
            if getattr(self, field) is None
        ]
        if invalid:
            raise ValueError(
                f"Los campos enviados no aceptan null: {', '.join(invalid)}."
            )
        return self


class PresentacionSummary(ApiModel):
    id_presentacion: str
    codigo_bf_sunat: str | None
    codigo_presentacion: str | None
    concentracion: str | None
    capacidad: DecimalString
    unidad: Literal["mL", "L", "g", "kg"]
    tipo_envase: str | None
    equivalencia_g: DecimalString | None
    densidad_actual: DecimalString | None
    estado: InsumoState


class InsumoOut(ApiModel):
    id_insumo: str
    nombre_comercial: str
    tipo: InsumoType
    unidad_base: str
    densidad_variable: bool
    estado: InsumoState
    cantidad_presentaciones: int
    presentaciones: list[PresentacionSummary]
    admite_densidad_lote: bool
    creado_en: datetime
    actualizado_en: datetime


class PresentacionCreate(ApiModel):
    id_presentacion: PresentationCode
    id_insumo: InsumoCode
    codigo_bf_sunat: str | None = Field(default=None, max_length=20)
    codigo_presentacion: str | None = Field(default=None, max_length=20)
    concentracion: str | None = Field(default=None, max_length=40)
    capacidad: DecimalString = Field(gt=0)
    unidad: Literal["mL", "L", "g", "kg"]
    tipo_envase: str | None = Field(default=None, max_length=40)
    equivalencia_g: DecimalString | None = Field(default=None, gt=0)
    densidad: DecimalString | None = Field(default=None, gt=0)
    vigencia_desde: date = Field(default_factory=date.today)


class PresentacionUpdate(ApiModel):
    codigo_bf_sunat: str | None = Field(default=None, max_length=20)
    codigo_presentacion: str | None = Field(default=None, max_length=20)
    concentracion: str | None = Field(default=None, max_length=40)
    capacidad: DecimalString | None = Field(default=None, gt=0)
    unidad: Literal["mL", "L", "g", "kg"] | None = None
    tipo_envase: str | None = Field(default=None, max_length=40)
    equivalencia_g: DecimalString | None = Field(default=None, gt=0)
    estado: InsumoState | None = None
    vigencia_hasta: date | None = None
    motivo: str | None = Field(default=None, min_length=3, max_length=500)

    @model_validator(mode="after")
    def reject_required_nulls(self) -> "PresentacionUpdate":
        invalid = [
            field
            for field in {"capacidad", "unidad", "estado"}
            & self.model_fields_set
            if getattr(self, field) is None
        ]
        if invalid:
            raise ValueError(
                f"Los campos enviados no aceptan null: {', '.join(invalid)}."
            )
        return self


class PresentacionOut(PresentacionSummary):
    id_insumo: str
    vigencia_desde: date
    vigencia_hasta: date | None


class DensidadCreate(ApiModel):
    valor: DecimalString = Field(gt=0)
    unidad: Literal["g/mL"] = "g/mL"
    fuente: str = Field(min_length=3, max_length=500)
    vigencia_desde: date
    vigencia_hasta: date | None = None


class DensidadOut(ApiModel):
    id_densidad: int
    id_presentacion: str
    valor: DecimalString
    unidad: str
    fuente: str
    vigencia_desde: date
    vigencia_hasta: date | None
    creado_por: int | None
    creado_en: datetime
