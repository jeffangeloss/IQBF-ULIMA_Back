# US-004 — Catálogos organizacionales

- Issue: [IQBF-ULIMA_Back #4](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/4)
- Prioridad: P0
- Estado del Project: Hecho

## Historia

Como responsable, quiero mantener establecimientos, carreras, laboratorios y
ubicaciones como catálogos controlados.

## Criterios verificados

- [x] Cada registro tiene código único, nombre, estado y vigencia.
- [x] Los valores usados se inactivan; no se borran físicamente.
- [x] Las nuevas relaciones solo aceptan referencias activas y vigentes.

## Contrato de backend

- `GET /api/catalogos/{catalogo}` lista y filtra por `q` y `estado`.
- `POST /api/catalogos/{catalogo}` crea un valor controlado.
- `PATCH /api/catalogos/{catalogo}/{item_id}` edita o inactiva.
- Catálogos de esta HU: `establecimientos`, `carreras`, `laboratorios` y
  `ubicaciones`.
- Un laboratorio y una ubicación requieren establecimiento vigente.
- `estado=ACTIVO` también comprueba el intervalo de vigencia.

## Evidencia

- `tests/test_acceptance_sprint1.py::test_us004_us005_organization_and_people_keep_vigency_and_history`
- `tests/test_api_sprint1.py::test_catalog_maintenance`
- Tablas: `establecimiento`, `carrera`, `laboratorio`, `ubicacion`.
