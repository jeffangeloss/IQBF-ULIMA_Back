"""Contratos de inventario físico, consumo y declaración.

Todo importe decimal viaja como cadena (`DecimalString`): un saldo de
`2952.1900` no puede pasar por un `number` de JavaScript sin arriesgar el
último dígito, y de ese dígito depende una declaración a SUNAT.
"""

from datetime import date, datetime
from typing import Literal

from pydantic import Field

from app.contracts import ApiModel, DecimalString


CondicionEnvase = Literal[
    "Sellado", "Abierto", "A la mitad", "Agotado", "Dañado", "Residuo"
]
EstadoCaducidad = Literal["VIGENTE", "POR_VENCER", "VENCIDO", "POR_CONFIRMAR"]
EstadoFrasco = Literal["EN_USO", "AGOTADO", "DADO_DE_BAJA"]
UnidadConsumo = Literal["g", "kg", "mL", "L"]


class FrascoResumen(ApiModel):
    """Una fila de la lista de inventario."""

    id_frasco: str
    id_insumo: str
    nombre_comercial: str
    id_presentacion: str
    codigo_bf_sunat: str | None
    concentracion: str | None
    numero_lote: str | None

    peso_neto_actual_g: DecimalString | None
    saldo_indeterminado: bool
    fraccion_llenado: DecimalString | None
    #: El nominal de la presentación no describe a este frasco: algún frasco
    #: suyo llegó a contener más de lo que la presentación dice que cabe.
    nominal_dudoso: bool
    volumen_actual_ml: DecimalString | None
    densidad_aplicable: DecimalString | None

    id_investigador: int | None
    custodio: str | None
    # El laboratorio del frasco manda; si no lo trae el rótulo, se hereda del
    # custodio. NULL es «sin asignar»: una pregunta abierta, no un dato falso.
    id_laboratorio: int | None
    laboratorio: str | None
    ubicacion: str | None
    posicion: str | None

    condicion_envase: CondicionEnvase | None
    estado_frasco: EstadoFrasco
    fecha_caducidad: date | None
    estado_caducidad: EstadoCaducidad
    dias_sin_movimiento: int | None
    alerta_prioritaria: str


class MovimientoOut(ApiModel):
    id_movimiento: int
    tipo_movimiento: str
    motivo: str
    cantidad_g: DecimalString
    cantidad_registrada: DecimalString | None
    unidad_registrada: str | None
    densidad_aplicada: DecimalString | None
    saldo_resultante_g: DecimalString
    peso_antes_g: DecimalString | None
    fecha_hora: datetime
    fecha_operacion: date
    registrado_por: str | None
    investigador: str | None
    curso: str | None


class FrascoDetalle(FrascoResumen):
    """La ficha completa, con el linaje del peso y su historial."""

    tipo: str
    capacidad: DecimalString
    unidad: str
    tipo_envase: str | None
    contenido_nominal_g: DecimalString | None
    grado_pureza: str | None
    fecha_ingreso: date | None

    peso_bruto_g: DecimalString | None
    tara_g: DecimalString | None
    peso_neto_inicial_g: DecimalString | None
    fuente_tara: str | None
    fecha_pesaje: datetime | None

    casillero: int | None
    nombre_puerta: str | None
    nivel: int | None
    precision_ubicacion: str | None

    observaciones: str | None
    movimientos: list[MovimientoOut] = Field(default_factory=list)


class SaldoInvestigador(ApiModel):
    """US-09 — «mis insumos y cuánto me queda»."""

    id_investigador: int
    custodio: str
    frascos: int
    frascos_vencidos: int
    frascos_indeterminados: int
    saldo_kg: DecimalString


class LineaDeclaracion(ApiModel):
    """US-21 — una línea del reporte agregado por código SUNAT."""

    codigo_bf_sunat: str
    id_insumo: str
    nombre_comercial: str
    tipo: str
    frascos: int
    frascos_indeterminados: int
    saldo_kg: DecimalString | None
    saldo_vencido_kg: DecimalString | None


class Declaracion(ApiModel):
    lineas: list[LineaDeclaracion]
    total_kg: DecimalString
    frascos: int
    frascos_indeterminados: int
    advertencia: str | None = None


class ConsumoCreate(ApiModel):
    """US-05 — el registro que tiene que caber en segundos.

    `cantidad` va en la unidad en que el operario la midió. El backend congela
    en el movimiento la unidad y la densidad aplicada para que una corrección
    posterior de la densidad no reinterprete el histórico (US-20).
    """

    id_frasco: str = Field(max_length=40)
    cantidad: DecimalString = Field(gt=0)
    unidad: UnidadConsumo
    id_investigador: int
    curso: str | None = Field(default=None, max_length=120)
    usuario_final: str | None = Field(default=None, max_length=160)
    fecha_operacion: date | None = None


class ConsumoPorPesada(ApiModel):
    """US-05 registrado como lo hace el laboratorio: dos pesadas del frasco.

    Es la forma de sus libros «CONTROL DE REACTIVOS»: el operario pone el
    frasco en la balanza antes y despues de servir, y el consumo se DERIVA de
    la resta. No se teclea una cantidad estimada, se mide.

    `bruto_antes_g` tiene que cuadrar con `tara + saldo`. Si no cuadra, hubo
    uso sin registrar: el servidor lo rechaza en vez de dejar que esa
    diferencia se disuelva dentro del consumo. Con `ajustar_diferencia` se
    regulariza primero, con su propio movimiento auditable.
    """

    id_frasco: str = Field(max_length=40)
    bruto_antes_g: DecimalString = Field(gt=0)
    bruto_despues_g: DecimalString = Field(ge=0)
    id_investigador: int
    curso: str | None = Field(default=None, max_length=120)
    usuario_final: str | None = Field(default=None, max_length=160)
    fecha_operacion: date | None = None
    ajustar_diferencia: bool = False


class ConsumoOut(ApiModel):
    id_movimiento: int
    id_frasco: str
    cantidad_g: DecimalString
    cantidad_kg: DecimalString
    unidad_registrada: str
    densidad_aplicada: DecimalString | None
    saldo_antes_g: DecimalString
    saldo_despues_g: DecimalString
    fecha_hora: datetime
    bruto_antes_g: DecimalString | None = None
    bruto_despues_g: DecimalString | None = None
    #: Movimiento de `ajuste_inventario` creado antes del consumo, si la
    #: pesada revelo una diferencia y se pidio regularizarla.
    id_ajuste: int | None = None
    ajuste_g: DecimalString | None = None


class ResumenPanel(ApiModel):
    """Las cifras de cabecera del tablero."""

    frascos: int
    frascos_con_saldo: int
    saldo_total_kg: DecimalString
    frascos_vencidos: int
    frascos_por_vencer: int
    frascos_indeterminados: int
    frascos_dormidos: int
    investigadores: int
    codigos_sunat: int
