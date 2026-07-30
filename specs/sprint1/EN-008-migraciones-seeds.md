# EN-008 — Migraciones y datos semilla

- Issue: [IQBF-ULIMA_Back #61](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/61)
- Prioridad: P0
- Estado del Project: En revisión

## Objetivo

Implementar migraciones y datos semilla controlados para construir una base
vacía o evolucionar la base existente sin perder evidencia.

## Criterios verificados

- [x] El esquema registra cada versión en `iqbf.schema_migration`.
- [x] Una base PostgreSQL vacía se construye con `python -m app.cli migrate`.
- [x] Repetir el comando omite las versiones ya aplicadas.
- [x] La recuperación es forward-only y parte de un `pg_dump` verificado.
- [x] Los catálogos semilla se registran en `iqbf.seed_migration`.

## Secuencia

1. `000_core_baseline.sql`: línea base operacional.
2. `001_sprint1_core.sql`: identidad, roles, alcance y maestros.
3. `002_sprint1_acceptance.sql`: reconciliación Core V3 y seeds.
4. `003_sprint1_integrity.sql`: reglas de integridad e índices.

Ninguna migración contiene contraseñas ni el censo real. No se ofrecen
migraciones `down` destructivas sobre kardex o bitácora; ante un fallo se
restaura una base nueva y la corrección se publica como migración de avance.

## Evidencia

- `tests/conftest.py` crea una base desechable y aplica la secuencia dos veces.
- `migrations/README.md` documenta aplicación, backup y recuperación.
- `CORE_V3_RECONCILIACION.md` documenta conteos e integridad de la copia real.
