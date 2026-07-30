# US-001 — Autenticación

- Issue: [IQBF-ULIMA_Back #1](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/1)
- Prioridad: P0
- Estado del Project: Hecho

## Historia

Como usuario, quiero autenticarme para acceder únicamente con una identidad
válida.

## Criterios verificados

- [x] Las credenciales inválidas devuelven `401 CREDENCIALES_INVALIDAS` y no
  crean una sesión.
- [x] La sesión identifica al usuario, sus roles y su alcance.
- [x] El inicio se persiste en `sesion` y el cierre registra `cerrada_en`.
- [x] El mecanismo queda definido por `IQBF_AUTH_MODE`; Sprint 1 usa `local`.

## Contrato de backend

- `POST /api/auth/login`: valida cuenta activa, bloqueo, contraseña y roles;
  devuelve JWT y vencimiento.
- `GET /api/auth/me`: devuelve identidad, roles y alcance de la sesión.
- `POST /api/auth/logout`: cierra la sesión persistida; responde `204`.
- El JWT no sustituye la consulta de sesión: una sesión cerrada o revocada se
  rechaza con `401 SESION_INVALIDA`.

## Evidencia

- `tests/test_acceptance_sprint1.py::test_us001_invalid_login_does_not_create_session_and_logout_is_recorded`
- `tests/test_api_sprint1.py::test_login_me_and_logout`
- Tablas: `usuario`, `usuario_rol`, `sesion`.
