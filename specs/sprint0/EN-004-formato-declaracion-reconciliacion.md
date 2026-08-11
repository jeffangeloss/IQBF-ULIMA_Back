# EN-004 — Formato de declaración y reconciliación

Issue: [IQBF-ULIMA_Front #4](https://github.com/jeffangeloss/IQBF-ULIMA_Front/issues/4)

Sprint: S0 — 15 al 28 de julio de 2026

Estado técnico: **Implementado · pendiente de aprobación del Responsable IQBF**

## Estado de la implementación

El endpoint `GET /api/inventario/reportes/rm04` (`app/modules/inventario/reportes_rm04.py`)
exporta el libro del periodo con cuatro hojas:

- `RDO` — la plantilla oficial que se presenta a SUNAT. Su estructura se
  cotejó celda por celda contra el archivo real
  `09.RM04 Setiembre 2025 SUNAT.xlsx`: las 19 columnas y las 25 celdas
  combinadas de la cabecera coinciden 1:1. `tests/test_reportes_rm04.py`
  fija esa forma para que un cambio de formato tenga que ser deliberado.
- `CONTROL`, `MOVIMIENTOS` y `RECONCILIACION` — el contrato interno descrito
  más abajo, como sustento de auditoría de lo declarado en `RDO`.

Lo que **no** está cerrado: la aprobación del Responsable IQBF sobre formato,
códigos, columnas, unidades y redondeo. Hasta que exista esa constancia, el
libro se emite con `estado = BORRADOR` en la hoja `CONTROL`.

Diferencia conocida frente al histórico: la plantilla de setiembre de 2025
trae la columna de verificación `I * J = K` descuadrada en varias filas (por
ejemplo la 6 y la 22, donde `Cant. KG` supera el neto de un envase lleno).
El generador calcula esa columna en vez de copiarla, así que el descuadre
histórico no se arrastra.

## Periodo histórico seleccionado

- Periodo: **junio de 2026**.
- Fuentes locales identificadas:
  - `6.RM04 JUNIO 2026 SUNAT.xlsx`
  - `6.2026 IQBF LÍQUIDOS.xlsx`
  - `6.2026 IQBF SÓLIDOS.xlsx`
  - `6.2026 Justificación de consumo IQBF.xlsx`
- Tratamiento: solo lectura, sin subir datos personales u operativos al
  repositorio.

## Contrato propuesto del consolidado

### Hoja `CONTROL`

| Columna | Tipo | Regla |
|---|---|---|
| `periodo` | `AAAA-MM` | Periodo declarado |
| `establecimiento_codigo` | texto | Conservar ceros iniciales |
| `tipo_reporte` | texto | RM04 u otro código aprobado |
| `version` | entero | Inicia en 1; una corrección crea otra versión |
| `generado_en` | fecha-hora | America/Lima, ISO 8601 |
| `generado_por` | texto | Código institucional, no contraseña |
| `request_id` | UUID | Correlación técnica |
| `hash_contenido` | texto | Integridad de la versión exportada |
| `estado` | texto | BORRADOR, VALIDADO o CERRADO |

### Hoja `MOVIMIENTOS`

| Columna | Tipo | Fuente/regla |
|---|---|---|
| `folio` | texto | Folio inmutable de la operación |
| `fecha_operacion` | fecha-hora | Hecho efectivo en America/Lima |
| `tipo_operacion` | catálogo | INGRESO, CONSUMO, EGRESO, AJUSTE o REVERSIÓN |
| `motivo_codigo` | texto | Catálogo aprobado; no sustituir por texto libre |
| `insumo_codigo` | texto | Maestro de insumos |
| `insumo_nombre` | texto | Descripción vigente/congelada para el reporte |
| `codigo_sunat` | texto | Presentación; conservar ceros iniciales |
| `presentacion_codigo` | texto | Maestro de presentaciones |
| `estado_fisico` | texto | LÍQUIDO o SÓLIDO |
| `lote_codigo` | texto | Lote de origen |
| `frasco_codigo` | texto | Unidad física |
| `unidad_origen` | texto | g, kg, mL o L |
| `cantidad_origen` | decimal | Sin formateo de miles |
| `densidad_g_ml` | decimal(10,6) | Instantánea aplicada; nulo solo si no corresponde |
| `cantidad_g` | decimal(14,4) | Equivalencia canónica |
| `cantidad_kg_exportada` | decimal | `cantidad_g / 1000`, redondeo final provisional |
| `saldo_resultante_g` | decimal(14,4) | Saldo del frasco |
| `origen` | texto | Ubicación/custodia de origen |
| `destino` | texto | Ubicación/custodia de destino si aplica |
| `responsable_codigo` | texto | Identidad institucional |
| `documento_soporte` | texto | Tipo/número o referencia segura |
| `folio_referencia` | texto | Original en corrección/reversión |
| `justificacion` | texto | Obligatoria en consumo, ajuste y reversión |

### Hoja `RECONCILIACION`

| Columna | Regla |
|---|---|
| `clave_agrupacion` | Periodo + establecimiento + código SUNAT + presentación |
| `saldo_inicial_g` | Saldo cerrado del periodo anterior |
| `entradas_g` | Suma de movimientos efectivos de entrada |
| `salidas_g` | Suma de movimientos efectivos de salida |
| `ajustes_g` | Suma algebraica de ajustes/reversiones |
| `saldo_teorico_g` | inicial + entradas - salidas + ajustes |
| `saldo_fisico_g` | Conteo registrado para cierre |
| `diferencia_g` | físico - teórico |
| `estado` | CONFORME, JUSTIFICADA o PENDIENTE |
| `justificacion_diferencia` | Obligatoria si diferencia ≠ 0 |

## Unidades y redondeo propuestos

- Cálculo interno: gramos y `NUMERIC`, sin redondeos intermedios.
- Densidad: seis decimales en `g/mL`.
- Movimiento y saldo: cuatro decimales en `g`.
- Exportación provisional de masa: kilogramos con seis decimales,
  `ROUND_HALF_UP`, aplicada una sola vez al producir el archivo.
- Códigos y folios se exportan como texto para conservar ceros iniciales.
- Celdas sin dato permanecen vacías/nulas; no se reemplazan por cero salvo que
  el cero sea una observación real.

La unidad y escala final deben compararse con la plantilla oficial y ser
aprobadas. Si la plantilla exige otra escala, se documentará como versión del
contrato y se agregará una prueba de regresión.

## Reglas de reconciliación

1. El periodo se filtra por `fecha_operacion` efectiva, en America/Lima.
2. Solo movimientos confirmados con efecto participan en totales.
3. Todo folio es único; reversión y corrección referencian el original.
4. El total por insumo/presentación debe poder reconstruirse desde el kardex.
5. No se aceptan saldos negativos, códigos huérfanos ni densidad faltante en
   conversiones de líquidos.
6. La suma del detalle debe coincidir exactamente con `RECONCILIACION` antes
   del redondeo de presentación.
7. Cada diferencia física se clasifica y justifica; nunca se elimina una fila
   para forzar el cuadre.
8. Cerrar genera una versión inmutable con hash y actor.

## Diferencias esperadas frente al histórico

- Los libros históricos separan líquidos y sólidos; el modelo canónico los
  unifica mediante `estado_fisico` y unidades explícitas.
- El sistema separa operación, movimiento y frasco; una fila histórica podría
  agrupar varios hechos y requerir desagregación.
- Las densidades quedan congeladas por movimiento; el histórico puede usar
  una densidad general o no registrarla.
- El sistema distingue movimiento registrado de movimiento con efecto.
- Las correcciones son asientos compensatorios y nuevas versiones, no
  sobrescritura de celdas.
- Los valores faltantes permanecen marcados como tales y generan una
  incidencia de reconciliación.

## Protocolo para desbloquear

1. Abrir las cuatro fuentes de junio de 2026 con el motor de Excel habilitado.
2. Inventariar hojas, columnas, fórmulas, formatos, celdas combinadas, unidades
   y códigos.
3. Mapear cada columna histórica al contrato propuesto y registrar brechas.
4. Reconciliar por lo menos un periodo completo contra los totales históricos.
5. Ejecutar una revisión de datos sensibles antes de adjuntar evidencia.
6. Obtener en el issue la aprobación del Responsable IQBF sobre formato,
   códigos, columnas, unidades y redondeo.
7. Versionar el contrato y automatizar una prueba con datos anonimizados.

## Criterios de aceptación

- [ ] El Responsable IQBF aprobó formato, códigos, columnas, unidades y
  redondeo.
- [x] La hoja `RDO` se comparó contra la plantilla oficial y coincide en las
  19 columnas y en las 25 celdas combinadas de la cabecera, con prueba de
  regresión que lo fija.
- [x] Se seleccionó por lo menos un periodo histórico real para reconciliar.
- [x] Las diferencias esperadas y el protocolo de conciliación están
  documentados.
