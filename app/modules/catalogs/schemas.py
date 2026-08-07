from datetime import date
from typing import Annotated, Literal

from pydantic import (
    EmailStr,
    Field,
    StringConstraints,
    model_validator,
)

from app.contracts import ApiModel


CatalogCode = Annotated[
    str,
    StringConstraints(
        strip_whitespace=True,
        min_length=1,
        max_length=30,
        pattern=r"^[A-Za-z0-9._-]+$",
    ),
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


class CatalogMetadata(ApiModel):
    id_establecimiento: int | None = None
    id_carrera: int | None = None
    id_laboratorio: int | None = None
    tipo: Literal["PERSONA", "AREA"] | None = None
    email: str | None = None
    descripcion: str | None = None
    #: Solo en establecimientos. US-027: si es `False`, las autorizaciones se
    #: registran y se consultan pero ningún consumo se bloquea por ellas.
    exige_autorizacion: bool | None = None


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
            for field in {"codigo", "nombre", "estado"}
            & self.model_fields_set
            if getattr(self, field) is None
        ]
        if invalid:
            raise ValueError(
                f"Los campos enviados no aceptan null: {', '.join(invalid)}."
            )
        return self
