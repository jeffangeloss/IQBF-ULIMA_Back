# EN-002 — Diccionario y reglas de cálculo

Issue: [IQBF-ULIMA_Front #2](https://github.com/jeffangeloss/IQBF-ULIMA_Front/issues/2)

Sprint: S0 — 15 al 28 de julio de 2026

Estado técnico: **En revisión**

## Unidades canónicas

- Masa: **gramo (`g`)**.
- Volumen: **mililitro (`mL`)**.
- Densidad: **gramo por mililitro (`g/mL`)**.
- Zona horaria de negocio: **America/Lima**.

La unidad original siempre se conserva para auditoría. La unidad canónica se
usa para saldos, límites y consolidación.

## Diccionario del dominio

| Concepto | Definición canónica | Identidad y reglas |
|---|---|---|
| Insumo | Sustancia controlada con identidad química/funcional estable | Tiene código interno y nombre únicos. No contiene tamaño de envase ni lote |
| Presentación | Forma comercial de un insumo con capacidad, unidad y propiedades de control | Pertenece a un insumo; contiene código SUNAT cuando corresponda, concentración, estado físico y densidad por defecto |
| Lote | Partida de una presentación recibida bajo condiciones comunes | Puede sobrescribir la densidad de la presentación cuando existe medición específica |
| Frasco | Unidad física individual inventariada y custodiada | Tiene identificador/QR único, lote, capacidad inicial, saldo actual, estado, ubicación y custodio |
| Operación | Hecho de negocio que agrupa intención, motivo, actores, documentos y uno o más movimientos | Su confirmación asigna folio y genera efectos inmutables |
| Movimiento | Variación cuantitativa de un frasco | Es entrada, salida o transferencia; conserva cantidad original, equivalencia canónica y saldo resultante |
| Autorización | Decisión registrada que habilita una operación sujeta a control | Incluye solicitante, decisor, regla, vigencia, estado y fundamento |
| Saldo | Cantidad canónica disponible de un frasco después del último movimiento efectivo | Se expresa en `g`, no puede ser negativo y se deriva del kardex |
| Densidad | Relación masa/volumen aplicada a una sustancia líquida en una vigencia determinada | Se expresa en `g/mL`; se toma primero del lote y luego de la presentación; se congela en el movimiento |
| Equivalencia | Cantidad de masa canónica calculada desde la unidad original | Se expresa en `g` y queda almacenada en el movimiento |
| Folio | Identificador de negocio único, inmutable y legible asignado al confirmar una operación | No se reutiliza ni se confunde con la clave interna de base de datos |
| Justificación | Explicación y evidencia que vincula una solicitud con una actividad autorizada | Es obligatoria en consumo, ajuste, excepción, reversión y corrección |
| Cierre | Sello versionado de un periodo reconciliado | Impide alterar hechos del periodo y conserva totales, diferencias y responsable |

Formato objetivo del folio:
`IQBF-<AAAAMMDD>-<secuencia de 8 dígitos>`. La base debe garantizar unicidad;
la secuencia no vuelve a empezar aunque una operación sea anulada.

## Reglas de conversión

Se utilizan valores decimales exactos; no se emplea punto flotante binario.

```text
masa_g = masa_kg × 1000
volumen_mL = volumen_L × 1000
masa_g_líquido = volumen_mL × densidad_g_por_mL
volumen_mL = masa_g ÷ densidad_g_por_mL
```

Para sólidos, el saldo se calcula directamente en masa. Para líquidos, la
densidad es obligatoria cuando el dato de origen es volumen. Una densidad
menor o igual a cero es inválida.

Precedencia de densidad:

1. Medición vigente del lote.
2. Densidad vigente de la presentación.
3. Sin valor: bloquear la operación y solicitar regularización; nunca asumir
   densidad `1`.

## Saldo y efecto

```text
signo(ENTRADA) = +1
signo(SALIDA) = -1
signo(TRANSFERENCIA_INTERNA) = 0 sobre el total institucional

saldo_nuevo_g = saldo_anterior_g + signo × equivalencia_g
```

Una transferencia entre frascos o custodias debe generar los asientos
enlazados necesarios para preservar el saldo de cada unidad física. El
movimiento se rechaza si produce saldo negativo o supera la capacidad inicial
sin un ajuste debidamente autorizado.

## Precisión y redondeo

| Dato | Persistencia Core V3 | Regla |
|---|---|---|
| Capacidad de presentación | `NUMERIC(12,4)` | Hasta 4 decimales |
| Peso neto en kg | `NUMERIC(12,5)` | Hasta 5 decimales |
| Densidad | `NUMERIC(10,6)` | Hasta 6 decimales |
| Masa/volumen operacional y saldo | `NUMERIC(14,4)` | Hasta 4 decimales |
| Equivalencia en gramos | `NUMERIC(14,4)` | Hasta 4 decimales |

- No se redondean resultados intermedios.
- La base aplica su escala declarada al persistir.
- La API expone decimales como cadenas para no perder precisión en
  JavaScript.
- La interfaz puede formatear visualmente, pero reenvía el valor decimal
  completo.
- El redondeo del archivo oficial se aplica una sola vez al exportar y está
  sujeto a la aprobación descrita en EN-004.
- Cuando el formato aprobado exija redondeo, la regla será explícita y
  determinista (`ROUND_HALF_UP`); nunca truncamiento silencioso.

## Decisiones que eliminan ambigüedades

- Código SUNAT, concentración y estado físico pertenecen a la presentación,
  no al insumo genérico.
- Ubicación indica dónde está el frasco; custodia indica quién responde por
  él. No son sinónimos.
- Operación es el hecho de negocio; movimiento es su efecto cuantitativo.
- La densidad congelada en un movimiento no cambia si luego se actualiza el
  maestro.
- Un registro histórico sin densidad no se “corrige” inventando un valor; se
  marca como dato faltante y se reconcilia.
- Las personas se referencian por cuenta/identidad; no mediante texto libre.
- Un movimiento confirmado no se edita: se compensa con otro folio.

## Criterios de aceptación

- [x] Se definen insumo, presentación, frasco, operación, autorización, saldo,
  densidad, equivalencia y folio.
- [x] Se fijan unidad canónica, precisión, precedencia, conversión y redondeo.
- [x] Las ambigüedades críticas detectadas tienen una decisión explícita.

## Conformidad

La especificación ya es consistente con las migraciones Core V3. La validación
funcional final debe quedar registrada en el issue antes de cambiar su estado
de **En revisión** a **Hecho**.
