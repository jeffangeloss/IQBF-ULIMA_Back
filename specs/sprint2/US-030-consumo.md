# US-030, US-033, US-034, US-036 — Consumo y sus barreras

- Issues: [#30](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/30),
  [#33](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/33),
  [#34](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/34),
  [#36](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/36)

## Dos caminos, y el orden importa

```
POST /api/movimientos/consumo-por-pesada    ← el que usa el laboratorio
POST /api/movimientos/consumo               ← cuando se sirve con pipeta
POST /api/movimientos/inventario            ← confirmar el saldo sin moverlo
```

**«Por pesada» va primero a propósito.** Es como trabajan en sus libros CONTROL
DE REACTIVOS: el frasco entero se pone en la balanza antes y después de servir,
y el consumo es la resta. Es una **medida**, no una estimación, y además se
puede contrastar contra el saldo que el sistema creía tener.

De ahí salió una comprobación que no estaba en la historia: si la primera
pesada no coincide con `tara + saldo`, el servidor rechaza con
`PESADA_NO_CUADRA` (409). Significa que salió producto sin registrarse.
Reenviar con `ajustar_diferencia: true` lo regulariza **con un movimiento de
ajuste propio, anterior al consumo**: el descuadre queda escrito, no absorbido.

`POST /api/movimientos/inventario` cubre las filas «INV.» de sus libros: se
pesa y se confirma, con cantidad 0 y sin mover saldo.

## Las barreras, todas en PostgreSQL

| Código | Cuándo | Historia |
|---|---|---|
| `SALDO_INSUFICIENTE` | Se pide más de lo que hay | US-033 |
| `CUSTODIA_AJENA` | El frasco es de otro custodio | US-034 |
| `SALDO_INDETERMINADO` | El frasco no tiene tara | — |
| `AUTORIZACION_INSUFICIENTE` | Sin cupo autorizado | US-027 |
| `PESADA_NO_CUADRA` | La balanza desmiente el saldo | US-030 |
| `DENSIDAD_REQUERIDA` | Volumen sin densidad | US-036 |

Un `INSERT` a mano con `psql` choca contra las mismas reglas: no se pueden
rodear saltándose la aplicación, que es la única forma de que valgan en un
sistema fiscalizado.

**El fallo que encontró la prueba de US-033 merece contarse.** El disparador
`BEFORE ROW` leía un saldo rancio *dentro de una misma sentencia*: dos SALIDAS
de 3.000 g en un solo `INSERT` sobre un frasco de 2.950 g se aceptaban las dos
y el kardex quedaba sumando negativo. Ningún endpoint lo dispara —la API
inserta fila a fila— pero la corrección de datos por SQL directo sí, y es justo
donde más falta hace la red.

## US-036 · La conversión se congela

La densidad usada queda escrita en el movimiento junto con su procedencia. Si
mañana se corrige la del lote, el consumo de ayer sigue diciendo con qué número
se calculó. Guardar «1,18» sin decir si venía de la etiqueta del fabricante o
de una tabla de referencia deja la declaración sin defensa.

## Lo que falta

- La pantalla suelta «Registrar consumo» sigue siendo el mockup de Figma. El
  consumo real se hace desde el frasco, en Inventario.
- No hay comprobante de la operación (US-038).
- **No hay transferencia de custodia** (US-020): el bloqueo de US-034 es
  correcto pero no tiene válvula legítima.

## Evidencia

- `tests/test_inventario_sprint2.py`: `test_us005_us020_consumo_descuenta_y_congela_la_densidad`,
  `test_us012_no_se_puede_consumir_mas_que_el_saldo`,
  `test_us013_no_se_puede_consumir_del_frasco_ajeno`,
  `test_un_insert_multifila_no_puede_dejar_saldo_negativo`,
  `test_consumo_por_pesada_deriva_el_consumo_de_la_balanza`,
  `test_pesada_que_no_cuadra_se_rechaza`,
  `test_la_diferencia_se_regulariza_como_movimiento_propio`,
  `test_inventario_confirma_el_saldo_sin_moverlo`,
  `test_us036_el_movimiento_dice_de_donde_salio_el_factor`
