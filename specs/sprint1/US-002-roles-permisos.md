# US-002 — Roles y permisos

- Issue: [IQBF-ULIMA_Back #2](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/2)
- Prioridad: P0
- Estado del Project: Hecho

## Historia

Como responsable, quiero asignar roles para limitar las acciones sensibles.

## Criterios verificados

- [x] Existen seis roles canónicos: `RESPONSABLE_IQBF`,
  `OPERADOR_DOCIMASIA`, `DOCENTE_INVESTIGADOR`, `APROBADOR`, `AUDITOR` y
  `ADMIN_TECNICO`.
- [x] Las operaciones protegidas usan autorización en backend, aunque se
  manipule la interfaz.
- [x] Los cambios de rol conservan actor, fecha y valores en bitácora.

## Reglas

- El responsable IQBF con alcance global mantiene los maestros.
- El administrador técnico con alcance global crea y administra cuentas.
- Los demás roles pueden consultar únicamente los recursos autorizados.
- Un rol permitido no anula la restricción de alcance organizacional.
- Un rechazo de rol responde `403 PERMISO_DENEGADO`; un rechazo de alcance
  global responde `403 ALCANCE_GLOBAL_REQUERIDO`.

## Evidencia

- `tests/test_acceptance_sprint1.py::test_us002_six_roles_have_differentiated_backend_permissions`
- Dependencias: `app/dependencies.py::require_roles` y
  `PATCH /api/usuarios/{user_id}`.
- Tablas: `rol`, `usuario_rol`, `bitacora_cambio`.
