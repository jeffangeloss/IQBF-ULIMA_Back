# US-009 — Densidades versionadas

- Issue: [IQBF-ULIMA_Back #9](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/9)
- Prioridad: P0
- Estado del Project: Hecho

## Historia

Como responsable, quiero versionar densidades y factores con vigencia.

## Criterios verificados

- [x] Cada versión registra valor, unidad `g/mL`, fuente, inicio y fin de
  vigencia.
- [x] No se permiten intervalos solapados por presentación.
- [x] Las operaciones guardan la densidad aplicada como snapshot.
- [x] Cambiar el maestro no recalcula el kardex histórico.

## Contrato de backend

- `GET /api/presentaciones/{id_presentacion}/densidades`: historial ordenado.
- `POST /api/presentaciones/{id_presentacion}/densidades`: nueva versión.
- La nueva vigencia cierra automáticamente la versión abierta anterior.
- Una vigencia inválida responde `422 VIGENCIA_INVALIDA`; un solapamiento,
  `409 VIGENCIA_SOLAPADA`.
- La densidad de presentación aplica a líquidos de densidad fija. Los líquidos
  variables registran densidad a nivel de lote.
- `kardex.densidad_aplicada` conserva el valor usado en la operación.

## Evidencia

- `tests/test_acceptance_sprint1.py::test_us009_density_versions_and_operation_snapshots`
- Tablas: `densidad_vigencia`, `lote`, `kardex`.
