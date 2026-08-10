# Sprint 2 — Inventario físico, consumo y declaración

Fecha de corte: 7 de agosto de 2026.

Lo que convierte el sistema en un inventario real: frascos con saldo, consumo
que descuenta, y la consolidación que se declara. Todos los ítems son issues
del repositorio `jeffangeloss/IQBF-ULIMA_Back`, enlazados al GitHub Project 2.

| Ítem | Issue | Estado del Project | Spec |
|---|---:|---|---|
| US-018 | [#18](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/18) | Hecho | [Inventario con filtros](US-018-inventario-filtros.md) |
| US-019 | [#19](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/19) | En curso | Ficha y kardex — falta exportar |
| US-021 | [#21](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/21) | En revisión | [Carga del censo](CARGA-CENSO.md) |
| US-022 | [#22](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/22) | En curso | [Carga del censo](CARGA-CENSO.md) |
| US-030 | [#30](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/30) | En curso | [Consumo](US-030-consumo.md) |
| US-033 | [#33](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/33) | Hecho | [Consumo](US-030-consumo.md) |
| US-034 | [#34](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/34) | En curso | [Consumo](US-030-consumo.md) |
| US-036 | [#36](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/36) | Hecho | [Consumo](US-030-consumo.md) |
| US-050 | [#50](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/50) | En curso | [Declaración SUNAT](US-050-declaracion-sunat.md) |

## Las cuatro reglas que atraviesan el sprint

**1 · El saldo solo se mueve por el kardex.** Un `UPDATE` directo sobre
`frasco.peso_neto_actual_g` lo rechaza PostgreSQL (`SALDO_SOLO_VIA_KARDEX`), y
el kardex es inmutable (`KARDEX_INMUTABLE`). Las reglas no viven en la
aplicación: viven en la base, así que un `INSERT` a mano con `psql` choca
contra la misma barrera que ve el operario en pantalla.

**2 · La unidad canónica es el gramo.** Se convierte a kilos solo al declarar.
Comparar litros contra kilos es como se pierde una declaración.

**3 · Saldo `NULL` no es saldo cero.** Es *indeterminado* —falta la tara— y la
base **impide moverlo**. Un cero afirmaría que no queda nada; «no se sabe» es
la verdad, y la declaración advierte de que su total es un mínimo.

**4 · Los decimales viajan como cadena.** El backend serializa `NUMERIC` como
texto (`"2952.2200"`). Un `float` de JavaScript arriesga el último dígito, y de
ese dígito depende una declaración.

## Migraciones

- `004_inventario_sprint2.sql` — ubicación estructurada, condición del envase
  como lista cerrada de seis, saldo indeterminado, kardex con unidad y densidad
  congeladas, vistas `v_inventario_v4`, `v_alertas_v4`, `v_declaracion_sunat`.
- `005_busqueda_laboratorio.sql` — `insumo_alias` (27 alias), catálogo de
  laboratorios, `fn_frasco_coincide`, `v_saldo_laboratorio`.
- `006_consumo_por_pesada.sql` — motivos `merma` e `inventario` con sus
  restricciones, y las dos lecturas de balanza guardadas como evidencia.
- `007_llenado_no_miente.sql` — el porcentaje de llenado no se calcula contra
  un nominal que el propio frasco desmiente.

## Pruebas

`tests/test_inventario_sprint2.py` — 19 pruebas contra un PostgreSQL real.
