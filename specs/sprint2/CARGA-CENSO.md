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
| C9 | El código identifica al frasco (ver más abajo: dos y tres segmentos) |
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

### El código de dos segmentos NO es un error

`IQF0102-115-99` se lee: insumo `IQF0102`, **código SUNAT `000115`**, frasco 99.
El segmento del medio *es* el código SUNAT — ese es el invariante que comprueba
C3.

Pero el etanol y el metanol se escriben con dos: `IQF0304-15`. Durante un rato
esto pareció un código malformado. **No lo es, y ALL.DATA lo demuestra:**

| Segmentos | Con código SUNAT | Sin código SUNAT |
|---|---|---|
| 3 | **159** | 0 |
| 2 | 0 | **50** |

Correlación perfecta sobre las 209 fichas con código IQF, sin una sola
excepción. Y los únicos insumos con dos segmentos son `IQF0304` (etanol) e
`IQF0308` (metanol).

La explicación es el propio invariante: **sin código SUNAT no hay segmento del
medio que poner.** A estas dos sustancias nunca se les asignó, porque se venían
manejando como NO fiscalizadas — ese es el error de rotulación «IQNF» que el
laboratorio ya confirmó en los hallazgos del censo.

**Decisión (2026-08-07): se cargan tal como los maneja el laboratorio.**
Tratar su convención como un defecto dejaría fuera del inventario todo el
etanol y todo el metanol —19 frascos, 24,7 kg—, que es peor que tenerlos
marcados. Entran sin código SUNAT, la aplicación los rotula «Sin código SUNAT»
y la declaración ya cuenta aparte lo que no puede sumar.

Su presentación se nombra por la capacidad —`IQF0304-2-5L`— con el mismo
criterio que usa el maestro de producción (`IQF0102-000069-0-5L`: insumo,
código y capacidad), porque no hay código SUNAT que poner en medio.

**Lo que sigue bloqueando es `SIN-CODIGO-nn`**, que es otra cosa: ahí el envase
no está rotulado y el código es un provisional del censo. Cargarlo inventaría
un identificador que no existe en el armario.

### Reutilizar maestros cuando no hay código SUNAT

`--reusar-maestros` resuelve la presentación del destino **buscándola por su
código SUNAT**. Sin código, esa búsqueda nunca casa: los frascos se caían
enteros con «su presentación no existe en esta base».

Ahora, **lo que no tiene código SUNAT se crea**, porque no hay contrapartida
que reutilizar — el destino identifica sus presentaciones justamente por ese
código. Y **dónde vive la densidad se le pregunta a la base destino** en vez de
suponerlo:

```sql
CASE WHEN i.densidad_variable OR i.tipo = 'SOLIDO' THEN NULL
     ELSE <densidad> END::numeric
```

Producción marca `IQF0102` como densidad variable y el censo no; suponerlo
chocaba con `fn_validar_densidad_presentacion_core` en un sentido o en el otro.

Y la decisión de qué rama tomar se apoya en el código SUNAT **de la
presentación**, no en el de la fila del censo: una misma presentación puede
traerlo en una fila y faltarle en otra, y las dos tienen que resolverse igual o
el lote apunta a una presentación que no existe.

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
- **`CODIGO_CORREGIDO`** — solo entran correcciones con evidencia
  **independiente del censo**. Hoy hay una: `IQF0303-44 → IQF0308-44`, con tres
  confirmaciones — el rótulo del frasco lo dice, ALL.DATA tiene esa ficha y no
  tiene ninguna `IQF0303`, y su tara (1418,41 g) coincide **al céntimo** con la
  del censo. La capacidad sale de su neto inicial en ALL.DATA
  (4578,41 − 1418,41 = 3160 g = 4 L × 0,79). Se corrige declarándolo, nunca en
  silencio, y el cargador lo imprime al ejecutarse.

El **tipo del insumo lo dice la unidad del envase**: `1 Kg` es sólido, `2.5 L`
es líquido. Estaba fijo en `LIQUIDO` mientras la carga solo llevaba ácidos; al
ampliarla, PostgreSQL lo rechazó con razón — «un sólido no debe tener densidad
en PRESENTACION».

El **laboratorio de cada custodio** se deduce de sus propios frascos cuando
todos coinciden. Si ninguno lo dice, se le adscribe el almacén y queda escrito
`-- PROVISIONAL … CONFIRMAR` en el SQL: es dónde está el producto, no dónde
trabaja la persona.

## Resultado (2026-08-07)

    199 filas con código · 102 con «¿Existe? = Sí» · 77 cargadas · 25 apartadas

Las otras 97 no son un fallo: 46 tienen `¿Existe? = No` —el frasco no se
encontró— y **51 están en blanco porque el barrido de sólidos sigue abierto**.

| Lo que queda fuera | Filas |
|---|---|
| Un código, dos estados físicos (la sosa sólida) | 11 |
| Código SUNAT de 7 dígitos (`0000122` → ¿`000122`?) | 6 |
| Código interno en conflicto con el SUNAT | 5 |
| El envase no está rotulado (`SIN-CODIGO-nn`) | 4 |
| Falta un campo imprescindible | 1 |
| El lote es una fecha | 1 |

**Ninguna se resuelve programando:** se resuelven rotulando el frasco, volviendo
a la foto o asignando un código.

### Estado de las dos bases

| | Local `iqbf_firme` | Producción `iqbf-db` |
|---|---|---|
| Frascos | **77** | **75** |
| Saldo | 101,46 kg | 101,17 kg |
| Indeterminados | 0 | 0 |
| Declaración | 32 códigos | 31 códigos · 70,59 kg |

Producción tiene dos menos: `IQF0708-141-01` y `IQF0408-04-05`, cuya
presentación no existe en su maestro. Y su declaración es menor que el saldo
porque los 19 frascos sin código SUNAT se cuentan aparte — que es exactamente
lo que debe pasar.

Alertas en producción: 18 vencidos, **22 sin código SUNAT** (etanol y metanol),
9 con la presentación desajustada, 2 sin custodio, 24 limpios.

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

- **Producción al 2026-08-07: 75 frascos · 101,17 kg · 0 indeterminados**, de
  18 frascos y 33,42 kg esa misma mañana. Etanol `IQF0304` con 12 frascos
  (14,696 kg) y metanol `IQF0308` con 7 (9,983 kg).
- Local `iqbf_firme`: 77 frascos · 101,46 kg · 32 códigos SUNAT.
- Procedencia de la tara: la mayoría de la etiqueta fotografiada, **15
  corroboradas contra la ficha de ALL.DATA**, 1 del pesaje confirmado por el
  laboratorio.
- Discrepancias documentadas en `DISCREPANCIAS_FOTO_VS_ALL_DATA.md` y en los
  hallazgos H-24 a H-27 de `HALLAZGOS_Y_MEDIDAS_IQBF.docx`.
- Respaldos previos a cada carga en `respaldo_produccion_2026-08-07/`.

## Lo que falta

1. **Cuatro decisiones del laboratorio**, por orden de cuánto desbloquean:
   - Un **código IQF propio para la sosa sólida** → 11 frascos.
   - Confirmar los **6 códigos SUNAT de siete dígitos** → 6.
   - Verificar los **5 códigos internos en conflicto** con su SUNAT → 5.
   - **Rotular los 4 envases sin código** → 4.
2. **`IQF1413-1` (DILUT-IT) no se puede cargar con lo que hay.** ALL.DATA no
   tiene ficha suya, el censo no trae presentación ni capacidad, y no tiene
   tara: pesa 63,61 g y no hay de dónde sacar el resto. No es un criterio del
   cargador — el dato no existe en ninguna fuente.
3. **Dos presentaciones que faltan en producción** (`IQF0708-141`,
   `IQF0408-04`), que dejan fuera un frasco cada una.
4. **Los sólidos.** 51 filas del censo están sin marcar `¿Existe?`: el barrido
   sigue abierto y declara 71 filas para 40 plazas rotuladas.
5. **Seis custodios con adscripción provisional**, pendientes de confirmar.

### Nota de red

La carga a producción exige llegar al puerto 5432 de Render. Desde la red de la
universidad (`200.11.63.10`) **el saludo TLS se corta** (`errno=54`) con
cualquier `sslmode` y también a través de `render psql`; no es la lista blanca
—con `sslmode=allow` el servidor contesta *«SSL/TLS required»*, o sea que el
protocolo llega—, es un intermediario de red. Desde otra red funciona, añadiendo
la IP a la lista blanca de `iqbf-db` y **retirándola al terminar**. El flag
`--ip-allow-list` REEMPLAZA la lista: hay que pasar todas las entradas juntas.
