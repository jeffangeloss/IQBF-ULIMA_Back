# US-006 — Alcance organizacional

- Issue: [IQBF-ULIMA_Back #6](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/6)
- Prioridad: P0
- Estado del Project: Hecho

## Historia

Como responsable, quiero restringir la información por establecimiento o
laboratorio.

## Criterios verificados

- [x] Una cuenta puede tener alcance global o una lista de establecimientos y
  laboratorios.
- [x] El responsable con alcance global puede consultar y mantener el conjunto
  completo.
- [x] Las consultas y exportaciones de catálogos reutilizan el mismo filtro.
- [x] Existen pruebas negativas de acceso fuera del alcance.

## Reglas

- `alcance_global=true` no puede mezclarse con alcances específicos.
- Una cuenta no global requiere al menos un establecimiento o laboratorio
  activo y vigente.
- `GET /api/auth/me` entrega el alcance efectivo al frontend.
- `GET /api/catalogos/{catalogo}` aplica el alcance antes de responder.
- `GET /api/catalogos/export/{catalogo}.csv` delega en la misma consulta
  filtrada; una exportación no amplía permisos.
- Las operaciones administrativas de cuentas y maestros requieren alcance
  global.

## Evidencia

- `tests/test_api_sprint1.py::test_user_roles_scope_and_revocation`
- `tests/test_acceptance_sprint1.py::test_us002_six_roles_have_differentiated_backend_permissions`
- Tabla: `usuario_alcance`.
