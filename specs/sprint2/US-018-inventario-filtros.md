# US-018 — Inventario con filtros

- Issue: [IQBF-ULIMA_Back #18](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/18)
- Prioridad: P0
- Estado del Project: Hecho

## Historia

Como operador, quiero consultar el inventario con filtros para ubicar
rápidamente un frasco.

## Criterios verificados

- [x] Busca por ID, insumo, códigos, lote y custodio en un solo campo.
- [x] Filtra por estado del frasco, laboratorio, ubicación y caducidad.
- [x] Pagina y ordena por seis criterios.
- [x] Muestra saldo y unidad sin mezclar presentaciones: todo en gramos.

## Contrato

`GET /api/frascos` acepta `q`, `laboratorio`, `custodio`, `insumo`,
`estado_caducidad`, `ubicacion`, `estado_frasco`, `orden`, `solo_con_saldo`,
`page`, `page_size`.

Órdenes: `alerta`, `insumo`, `saldo`, `caducidad`, `ubicacion`, `custodio`.

## Dos decisiones que se ven en la pantalla

**`ubicacion=-1` y `laboratorio=-1` listan lo que NO tiene asignación.** «Sin
asignar» es una pregunta abierta —13 de los 19 frascos del primer censo no
decían su laboratorio— y se enseña en vez de esconderse.

**`q` viaja por los alias del insumo.** El censo trae seis grafías para el
etanol: *Ethanol*, *Alcohol Etílico Absoluto*, *Ethanol absolute for analysis*,
*Etanol*, *Etanolo*. Un profesor que pide «etanol» tiene que encontrarlo diga
lo que diga el rótulo. 27 alias sembrados en `005_busqueda_laboratorio.sql`.

## Evidencia

- `tests/test_inventario_sprint2.py::test_us018_filtros_y_orden_del_inventario`
- `tests/test_inventario_sprint2.py::test_us010_busqueda_encuentra_por_alias_del_insumo`
- `tests/test_inventario_sprint2.py::test_saldo_sin_tara_es_indeterminado_y_no_se_puede_mover`
