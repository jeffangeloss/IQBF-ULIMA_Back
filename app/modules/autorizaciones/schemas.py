"""Contratos de autorizaciones de uso y excepciones — épica E4.

La cantidad autorizada viaja siempre en la unidad canónica (gramos) además de
en la que tecleó el responsable. Comparar litros contra kilos es como se
pierde una declaración.
"""

from datetime import date, datetime
from typing import Literal

from pydantic import Field

from app.contracts import ApiModel, DecimalString


UnidadCantidad = Literal["g", "kg", "mL", "L"]
EstadoRegistro = Literal["BORRADOR", "VIGENTE", "REVOCADA"]
EstadoEfectivo = Literal[
    "BORRADOR", "VIGENTE", "POR_VENCER", "AGOTADA", "VENCIDA", "REVOCADA",
    "FUTURA",
]
EstadoExcepcion = Literal[
    "PENDIENTE", "APROBADA", "RECHAZADA", "EJECUTADA", "CADUCADA"
]
ReglaInfringida = Literal[
    "SIN_AUTORIZACION", "SALDO_AUTORIZADO_INSUFICIENTE", "AUTORIZACION_NO_VIGENTE"
]


class AutorizacionCreate(ApiModel):
    """US-023. Cuánto puede consumir un titular, de qué, y hasta cuándo."""

    codigo: str = Field(max_length=30, min_length=1)
    id_investigador: int
    id_insumo: str = Field(max_length=20)
    #: NULL vale para cualquier presentación del insumo.
    id_presentacion: str | None = Field(default=None, max_length=30)
    id_establecimiento: int
    id_laboratorio: int | None = None
    cantidad: DecimalString = Field(gt=0)
    unidad: UnidadCantidad
    vigencia_desde: date | None = None
    vigencia_hasta: date | None = None
    observaciones: str | None = None


class AutorizacionUpdate(ApiModel):
    """Solo en BORRADOR. Una vigente se amplía o se revoca, no se edita."""

    cantidad: DecimalString | None = Field(default=None, gt=0)
    unidad: UnidadCantidad | None = None
    id_presentacion: str | None = Field(default=None, max_length=30)
    id_laboratorio: int | None = None
    vigencia_desde: date | None = None
    vigencia_hasta: date | None = None
    observaciones: str | None = None
    estado: EstadoRegistro | None = None
    #: Obligatorio al revocar: una autorización no se anula sin decir por qué.
    motivo_revocacion: str | None = None


class DocumentoOut(ApiModel):
    id_documento: int
    version: int
    nombre_archivo: str
    tipo_mime: str
    tamano_bytes: int
    sha256: str
    subido_por: str | None
    subido_en: datetime


class AutorizacionOut(ApiModel):
    id_autorizacion: int
    codigo: str
    id_investigador: int
    titular: str
    id_insumo: str
    nombre_comercial: str
    id_presentacion: str | None
    id_establecimiento: int
    id_laboratorio: int | None
    laboratorio: str | None

    cantidad_autorizada_g: DecimalString
    cantidad_registrada: DecimalString | None
    unidad_registrada: str | None
    #: Derivado del kardex en cada consulta: no hay columna que quede rancia.
    consumido_g: DecimalString
    disponible_g: DecimalString
    disponible_kg: DecimalString

    vigencia_desde: date
    vigencia_hasta: date | None
    estado_registro: EstadoRegistro
    #: Combina el registro con el reloj y el consumo. Es el que se enseña.
    estado_efectivo: EstadoEfectivo
    motivo_revocacion: str | None
    observaciones: str | None
    documentos: int


class ExcepcionCreate(ApiModel):
    """US-028. El intento que la regla rechazó, conservado entero."""

    id_frasco: str = Field(max_length=40)
    id_investigador: int
    cantidad: DecimalString = Field(gt=0)
    unidad: UnidadCantidad
    #: Por qué debería permitirse. Sin esto no hay solicitud.
    motivo: str = Field(min_length=10)
    curso: str | None = Field(default=None, max_length=120)
    usuario_final: str | None = Field(default=None, max_length=160)


class ExcepcionResolver(ApiModel):
    """US-029. Aprobar o rechazar. Rechazar exige comentario."""

    aprobar: bool
    comentario: str | None = None


class ExcepcionOut(ApiModel):
    id_excepcion: int
    codigo: str
    id_frasco: str
    nombre_comercial: str | None = None
    id_investigador: int
    titular: str | None = None
    cantidad_g: DecimalString
    cantidad_registrada: DecimalString | None
    unidad_registrada: str | None
    curso: str | None
    regla_infringida: str
    motivo: str
    estado: EstadoExcepcion
    solicitado_por: str | None
    solicitado_en: datetime
    resuelto_por: str | None
    resuelto_en: datetime | None
    comentario: str | None
    id_movimiento: int | None
