# US-050 — Consolidación por código SUNAT

- Issue: [IQBF-ULIMA_Back #50](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/50)
- Estado del Project: En curso

`GET /api/declaracion/sunat` agrupa por código SUNAT y devuelve kilos, con la
columna «del cual vencido».

## Lo que la historia no pedía y el censo exigió

**La declaración avisa de lo que no está sumado.** Los frascos con saldo
indeterminado —sin tara— se cuentan aparte y el total se presenta como
**mínimo**, no como cifra cerrada. Una consolidación que se callara esos
frascos declararía de menos sin que nadie lo supiera.

**El código SUNAT tiene seis dígitos, y eso se comprueba.** `0000122` y
`000122` son dos grupos distintos en la consolidación: un cero de más parte una
partida en dos.

## Lo que falta para cerrarla

- **Consolida el estado actual, no un periodo.** Sin cierre diario ni mensual
  (US-047, US-049) no existe el concepto de periodo cerrado, así que no se
  puede pedir «lo de julio».
- **Consolida saldos, no operaciones.** El acumulado de entradas y salidas del
  periodo no se calcula.
- **No se exporta** (US-051): se ve en pantalla y no se puede presentar.

## Evidencia

- `tests/test_inventario_sprint2.py::test_us021_declaracion_avisa_de_lo_que_no_esta_sumado`
- `tests/test_inventario_sprint2.py::test_codigo_sunat_numerico_debe_tener_seis_digitos`
