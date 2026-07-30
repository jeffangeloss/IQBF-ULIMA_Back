from datetime import date, datetime
from typing import Annotated, Literal

from pydantic import Field, StringConstraints, model_validator

from app.contracts import ApiModel, DecimalString


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
InsumoType = Literal["LIQUIDO", "SOLIDO"]
InsumoState = Literal["VIGENTE", "INACTIVO"]


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
