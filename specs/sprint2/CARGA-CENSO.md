# Carga del censo físico — US-021, US-022, EN-010

- Issues: [#21](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/21),
  [#22](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/22),
  [#63](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/63)
- Estado del Project: En revisión / En curso

## De dónde salen los datos, y cuál manda

Hay **tres** fuentes, y el orden de confianza no es obvio. Conviene tenerlo
escrito porque de él dependen los kilos que se declaran.

| Fuente | Qué es | Fidelidad |
|---|---|---|
| **ALL.DATA** | Fichas «CONTROL DE REACTIVOS» de `IQBF Y PRODUCE/ALL.DATA/`: 219 fichas, 811 movimientos por doble pesada | **La que manda.** Es lo que el laboratorio usa a diario |
| **Evidencia fotográfica** | Columnas `… (etiqueta)` del censo + peso de la balanza RADWAG | Medición directa de lo que se ve en el frasco |
| **Censo (columnas originales)** | Lo que trajo el archivo antes del trabajo de campo | Derivada: su columna `Tara (kg)` **está copiada de ALL.DATA** |

**Decisión del laboratorio (2026-08-07): para la tara manda ALL.DATA.**

Y una advertencia que no conviene perder: la hoja `OBS` de ALL.DATA documenta
que obtiene la tara *calculándola* — `tara = bruto − (volumen × densidad)`, y
se cumple exacta en 86 de 90 fichas. **Una tara calculada no es una medición.**
Ocho frascos tienen la etiqueta manuscrita discrepando (hallazgo H-24); se
cargan con la de ALL.DATA, como se decidió, y siguen en la lista de pesar
vacíos. La única forma de zanjarlo es la balanza.

El libro vigente es el que lee el cargador, y está escrito a mano en
`carga_censo_v4.py`:

    /Users/…/Desktop/IQF_Censo/outputs/censo-iqbf-20260805/
        Cimiento_Censo_IQBF_v5_2026-08-06.xlsx

**No vive en el repositorio a propósito.** Es el inventario de un laboratorio
fiscalizado —con posiciones de almacén, custodios y cantidades— y ambos
repositorios son públicos. `bd/` está en `.gitignore` por la misma razón: el
SQL generado tampoco se versiona.

## El pre-flight

`_CENSO_PIPELINE/preflight_carga.py` revisa cada fila antes de emitir SQL. Solo
se consideran las filas **`¿Existe? = Sí`**: ningún frasco fantasma.

**Lo que bloquea** es lo que impide identificar o pesar el frasco:

| | Qué comprueba |
|---|---|
| C1 | Neto negativo. Un frasco no contiene una cantidad negativa |
| C2 | El código SUNAT tiene 6 dígitos. `0000122` y `000122` son dos grupos distintos en la consolidación: parten la declaración |
| C3 | El segmento medio del código interno coincide con el código SUNAT |
| C4 | Están el código, el insumo, la presentación, la pesada y su fecha |
| C8 | El número de lote no es una fecha |
| C9 | El código identifica al frasco: `IQF####-presentación-frasco` |
| C10 | El insumo no aparece con dos estados físicos |

**Lo que solo avisa** son los huecos que el modelo sabe sostener: código SUNAT,
caducidad, fecha de ingreso, densidad, lote, ubicación, condición del envase.
El frasco entra **marcado** y la aplicación lo pinta como alerta
(`SIN_CODIGO_SUNAT`, `DENSIDAD_PENDIENTE`, `POR_CONFIRMAR`, `SIN_CUSTODIO`).

> **Por qué cambió esto el 2026-08-07.** El pre-flight se escribió cuando la
> base no tenía dónde poner un hueco y no había pantalla que lo enseñara, así
> que cualquier campo vacío bloqueaba. Ahora sí las hay. Un frasco al que le
> falta un dato no es un frasco inventado: esconderlo del inventario es peor
> que enseñarlo marcado.

### La comprobación que se retiró, y por qué

C1 comparaba el neto derivado contra la columna `Peso neto físico (g)` del
censo. Se comprobó que **esa columna se calculó con los valores viejos de la
observación** y no se recalculó al corregirse la tara: en las 11 filas donde
discrepaba, el neto declarado es **exactamente** `bruto − tara` de la
observación, al céntimo. Bloqueaba por estar rancia, no por mentir.

El cargador nunca la lee —deriva el neto de `bruto − tara`— y el SQL termina
con una guarda que **aborta la transacción entera** si algún saldo no cuadra
con esa resta. La comprobación sobraba.

## Decisiones declaradas en el cargador

Tres tablas explícitas, por la misma razón que existe `ALIAS_CUSTODIO`: una
fusión o un desempate no debe deducirse leyendo código.

- **`ALIAS_CUSTODIO`** — «Prof. Yacono» y «Juan Carlos Yacono» son la misma
  persona. Sin esto se crearían dos custodios y *«cuánto le queda a Yacono»*
  daría una cifra partida en dos, que es justo lo que US-004 existe para
  evitar.
- **`ESTADO_INSUMO`** — `IQF0708` cubre sosa en disolución (1 L) y sosa sólida
  (1 kg): un código para dos productos. El modelo guarda un estado por insumo,
  así que se declara cuál manda y el otro se aparta. **Los 11 frascos de sosa
  sólida necesitan su propio código IQF; lo decide el laboratorio.**
- **`EQUIVALENTES_DESTINO`** — la base de producción escribe «PONCE» y el censo
  «Silvia Ponce». Sin esta tabla la carga crearía un segundo investigador.

El **tipo del insumo lo dice la unidad del envase**: `1 Kg` es sólido, `2.5 L`
es líquido. Estaba fijo en `LIQUIDO` mientras la carga solo llevaba ácidos; al
ampliarla, PostgreSQL lo rechazó con razón — «un sólido no debe tener densidad
en PRESENTACION».

El **laboratorio de cada custodio** se deduce de sus propios frascos cuando
todos coinciden. Si ninguno lo dice, se le adscribe el almacén y queda escrito
`-- PROVISIONAL … CONFIRMAR` en el SQL: es dónde está el producto, no dónde
trabaja la persona.

## Resultado (2026-08-07)

    102 filas evaluadas · 57 cargadas · 45 apartadas

| Lo que queda fuera | Filas |
|---|---|
| El código no identifica el frasco (`SIN-CODIGO-nn`, o sin segmento) | 24 |
| Falta un campo imprescindible | 12 |
| Un código, dos estados físicos (la sosa sólida) | 11 |
| Código SUNAT de 7 dígitos | 6 |
| Código interno en conflicto con el SUNAT | 5 |
| El lote es una fecha | 1 |

De las 24 primeras, **20 son los etanoles y metanoles sin alta en `Insumos` ni
código SUNAT**, que ya figuran en los hallazgos del censo. Ninguna de las 45 se
resuelve programando: se resuelven rotulando el frasco o volviendo a la foto.

## Cómo se ejecuta

```bash
cd IQBF-ULIMA_Back
PYTHONPATH=~/Desktop/IQF_Censo/_CENSO_PIPELINE \
  ../.venv/bin/python carga_censo_v4.py --salida bd/carga_censo_liquidos.sql
psql "$IQBF_DATABASE_URL" -v ON_ERROR_STOP=1 -f bd/carga_censo_liquidos.sql
```

Contra una base que ya tiene sus propios maestros, añadir `--reusar-maestros`.

El SQL es **idempotente** y va en **una sola transacción**: si algo no cuadra,
no entra nada. Conviene respaldar antes de todos modos.

## Evidencia

- Local `iqbf_firme` al 2026-08-07: **57 frascos · 75,96 kg · 0 indeterminados
  · 32 códigos SUNAT · 70,06 kg declarables**, con 19 vencidos, 3 sin código
  SUNAT y 2 sin custodio marcados como alerta.
- Procedencia de la tara de los 57: 38 de la etiqueta fotografiada, **15
  corroboradas contra la ficha de ALL.DATA**, 1 del pesaje confirmado por el
  laboratorio, 3 sin evidencia.
- Discrepancias documentadas en `DISCREPANCIAS_FOTO_VS_ALL_DATA.md` y en los
  hallazgos H-24 a H-27 de `HALLAZGOS_Y_MEDIDAS_IQBF.docx`.

## Lo que falta

1. **Producción sigue con los 18 frascos del 2026-08-06.** La carga no se pudo
   ejecutar desde la red de la universidad: el saludo TLS contra el puerto 5432
   de Render se corta (`errno=54`), con cualquier `sslmode` y también a través
   de `render psql`. El servidor responde al protocolo —con `sslmode=allow`
   contesta *«SSL/TLS required»*—, así que no es la lista blanca de IP: es un
   intermediario de red. Se ejecuta desde la red donde ya funcionó el
   2026-08-06.
2. **Los sólidos, más allá de los 8 cargados.** El censo declara 71 filas para
   40 plazas rotuladas; el barrido sigue abierto.
3. **Seis custodios con adscripción provisional**, pendientes de confirmar.
