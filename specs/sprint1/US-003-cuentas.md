# US-003 — Administración de cuentas

- Issue: [IQBF-ULIMA_Back #3](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/3)
- Prioridad: P0
- Estado del Project: Hecho

## Historia

Como administrador, quiero crear, activar, bloquear y desactivar cuentas.

## Criterios verificados

- [x] `codigo_institucional` y correo se normalizan y son únicos.
- [x] Una cuenta inactiva o bloqueada no puede iniciar sesión.
- [x] La inactivación conserva la cuenta, roles, sesiones e historial.
- [x] El alta y los cambios se auditan sin copiar hashes de contraseña.

## Contrato de backend

- `GET /api/usuarios`: búsqueda, filtro de estado y paginación.
- `POST /api/usuarios`: alta con roles y alcance válido.
- `GET /api/usuarios/{user_id}`: detalle de cuenta.
- `PATCH /api/usuarios/{user_id}`: nombre, estado, roles y alcance.
- Inactivar una cuenta revoca sus sesiones activas.
- No existe endpoint `DELETE /api/usuarios`.

## Evidencia

- `tests/test_acceptance_sprint1.py::test_us003_accounts_are_unique_inactivated_and_audited`
- `tests/test_api_sprint1.py::test_user_roles_scope_and_revocation`
- Tablas: `usuario`, `usuario_rol`, `usuario_alcance`, `sesion`,
  `bitacora_cambio`.
