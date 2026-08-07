"""Contratos HTTP compartidos por más de un módulo.

Los contratos propios de cada capacidad viven junto a su módulo. Este archivo
contiene solo infraestructura transversal: modelos base, paginación, salud y
RFC 9457/problem+json.
"""

from decimal import Decimal
from typing import Annotated, Generic, Literal, TypeVar

from pydantic import (
    BaseModel,
    ConfigDict,
    PlainSerializer,
    WithJsonSchema,
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
    "SALDO_INDETERMINADO",
    "CUSTODIA_AJENA",
    "PESADA_NO_CUADRA",
    "FRASCO_NO_EXISTE",
    "INVESTIGADOR_NO_EXISTE",
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
