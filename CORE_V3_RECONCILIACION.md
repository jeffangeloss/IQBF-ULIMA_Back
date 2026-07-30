# Reconciliación de ENTREGA_BD_CORE_V3_2026-07-24 2

Fecha: 27 de julio de 2026.

## Contenido inspeccionado

La carpeta no contiene un archivo Excel. Contiene SQL consolidado, documento
maestro DOCX/PDF, modelo Markdown, checksums y archivos de demostración. Todos
los SHA-256 publicados en la entrega coincidieron.

El SQL fue restaurado en una base temporal aislada y se verificaron sus
restricciones, conteos y vistas antes de reconciliarlo con `iqbf_mvp`.

## Conteos Core V3 verificados

- 22 insumos: 12 líquidos y 10 sólidos.
- 64 presentaciones.
- 110 lotes.
- 187 frascos.
- 205 movimientos con efecto.
- 182 frascos con saldo positivo.
- 61 frascos vencidos al 27 de julio de 2026.
- 172 frascos en Docimasia o sin asignar.
- 3 frascos líquidos con densidad pendiente.
- 0 huérfanos, saldos negativos, sobrecapacidad o violaciones de densidad.

## Diferencias reconciliadas

- Se recuperó `insumo.densidad_variable`.
- Se recuperó `lote.numero_factura`.
- HCl `IQF0102` y HNO3 `IQF0106` usan densidad variable por lote.
- Se restauraron 24 densidades de lote verificadas por clave técnica y
  presentación.
- Las versiones interpretadas anteriormente en presentación no se borraron:
  quedaron cerradas como historia.
- Se añadieron las vistas `v_inventario_core`, `v_alertas_core` y
  `v_panel_core_sprint1`.
- `investigador` se conserva como entidad canónica extendida para los actores
  del Core; no se creó una tabla duplicada.
- `NULL` y el laboratorio explícito Docimasia se muestran como
  `DOCIMASIA / SIN ASIGNAR`.

`iqbf_mvp` conserva además el movimiento histórico ID 183 sin efecto. Por eso
el panel distingue 206 movimientos registrados de 205 movimientos efectivos;
no se eliminó evidencia.

## Pendientes de calidad de datos

- Tres lotes HNO3 siguen sin densidad; se muestran como alerta y las altas
  nuevas ya no permiten omitirla.
- Los 110 lotes históricos no tienen proveedor/factura/procedencia enlazados.
- La revisión de vencidos y asignaciones corresponde al trabajo operativo de
  sprints posteriores; no se inventaron datos para cerrarla.

## Respaldo previo

`respaldo_bd_2026-07-27_pre_core_v3_reconcile/iqbf_mvp_pre_core_v3_reconcile.dump`

SHA-256:

`8cb44665bc221ef95d6a3c51c29970c0ca226e3e2d672cf6c9ae209441b852f7`
