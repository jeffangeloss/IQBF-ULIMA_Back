# Sprint 1 — Acceso y maestros

Fecha de corte: 27 de julio de 2026.

Todos los elementos de esta tabla son issues reales del repositorio
`jeffangeloss/IQBF-ULIMA_Back` y permanecen enlazados al GitHub Project 2. La
conversión desde `DraftIssue` preservó prioridad, estimación, iteración y
estado.

| Ítem | Issue | Estado del Project | Spec |
|---|---:|---|---|
| US-001 | [#1](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/1) | Hecho | [Autenticación](US-001-autenticacion.md) |
| US-002 | [#2](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/2) | Hecho | [Roles y permisos](US-002-roles-permisos.md) |
| US-003 | [#3](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/3) | Hecho | [Cuentas](US-003-cuentas.md) |
| US-004 | [#4](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/4) | Hecho | [Organización](US-004-organizacion.md) |
| US-005 | [#5](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/5) | Hecho | [Personas y custodios](US-005-personas-custodios.md) |
| US-006 | [#6](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/6) | Hecho | [Alcance organizacional](US-006-alcance-organizacional.md) |
| US-007 | [#7](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/7) | Hecho | [Maestro de insumos](US-007-maestro-insumos.md) |
| US-008 | [#8](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/8) | Hecho | [Inactivación de insumo](US-008-inactivar-insumo.md) |
| US-009 | [#9](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/9) | Hecho | [Densidades versionadas](US-009-densidades.md) |
| US-010 | [#10](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/10) | Hecho | [Presentaciones](US-010-presentaciones.md) |
| US-011 | [#11](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/11) | Hecho | [Inactivación de presentación](US-011-inactivar-presentacion.md) |
| US-013 | [#13](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/13) | Hecho | [Búsqueda de maestros](US-013-busqueda.md) |
| EN-008 | [#61](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/61) | En revisión | [Migraciones y seeds](EN-008-migraciones-seeds.md) |

## Contrato transversal

- Base de API: `http://127.0.0.1:8000`.
- Autenticación: `Authorization: Bearer <token>`.
- Errores: `application/problem+json` con `code`, `title`, `detail` y
  `X-Request-ID`.
- Persistencia: PostgreSQL, esquema `iqbf`.
- No se realizan borrados físicos de maestros o evidencia histórica.
- La autorización y el alcance siempre se validan en backend.

## Validación

Desde `IQBF-ULIMA_Back`:

```bash
python -m pytest -q
PYTHONPATH=. python scripts/export_openapi.py
```
