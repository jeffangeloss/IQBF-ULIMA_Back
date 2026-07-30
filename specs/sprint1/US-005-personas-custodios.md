# US-005 — Personas, investigadores y custodios

- Issue: [IQBF-ULIMA_Back #5](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/5)
- Prioridad: P0
- Estado del Project: Hecho

## Historia

Como responsable, quiero mantener el catálogo único de docentes,
investigadores y custodios.

## Criterios verificados

- [x] No se admiten duplicados por identificador institucional.
- [x] Cada registro se asocia a carrera o laboratorio y tiene estado.
- [x] Las operaciones referencian un identificador; no guardan nombres libres.
- [x] La inactivación conserva las referencias históricas.

## Contrato de backend

- El recurso se expone como
  `GET|POST /api/catalogos/investigadores` y
  `PATCH /api/catalogos/investigadores/{item_id}`.
- `codigo` de API se persiste como `codigo_institucional`.
- Una persona nueva requiere al menos `id_carrera` o `id_laboratorio`.
- Las referencias deben existir, estar activas y encontrarse vigentes.
- No existe operación de borrado físico.

## Evidencia

- `tests/test_acceptance_sprint1.py::test_us004_us005_organization_and_people_keep_vigency_and_history`
- Tabla: `investigador`.
