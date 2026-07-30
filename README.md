# IQBF ULIMA — Backend

API IQBF con la base funcional/técnica de Sprint 0 y la implementación de
Sprint 1 para autenticación, roles, alcance organizacional, maestros de
insumos, presentaciones y densidades versionadas. Trabaja sobre el esquema
`iqbf` vigente; no usa ni reinstala el modelo histórico de 31 tablas.

## Preparación

Desde la raíz `PROYECTO_IQBF`:

```bash
source .venv/bin/activate
python -m pip install -r IQBF-ULIMA_Back/requirements.txt
cd IQBF-ULIMA_Back
cp .env.example .env
```

Cambie `IQBF_JWT_SECRET` en `.env`. La base local verificada usa por ahora
PostgreSQL en `127.0.0.1:5432`.

## Migraciones

Primero haga una copia de respaldo. Luego:

```bash
python -m app.cli migrate
```

Las migraciones `000` a `003` construyen una base vacía o actualizan de forma
incremental la base existente. Se pueden repetir: cada versión se aplica una
sola vez. No borran frascos, movimientos, censo ni evidencias.

- `000`: línea base operacional vacía.
- `001`: identidad, seis roles, alcance, maestros y bitácora.
- `002`: reconciliación de densidades y atributos de Core V3.
- `003`: integridad de altas/estados e índices de búsqueda.

La estrategia de restauración está en
[`migrations/README.md`](migrations/README.md).

## Primera cuenta

```bash
export IQBF_ADMIN_PASSWORD='una-clave-segura-de-al-menos-12-caracteres'
python -m app.cli create-admin \
  --email admin@example.edu.pe \
  --code CODIGO-INSTITUCIONAL \
  --name "Administrador IQBF"
unset IQBF_ADMIN_PASSWORD
```

La contraseña no se guarda en scripts ni archivos.

## Ejecutar backend

```bash
uvicorn app.main:app --reload --port 8000
```

- Documentación Swagger: `http://127.0.0.1:8000/api/docs`
- OpenAPI: `http://127.0.0.1:8000/api/openapi.json`
- Salud: `http://127.0.0.1:8000/api/health`

## Contrato para el frontend

```bash
PYTHONPATH=. python scripts/export_openapi.py
```

Genera `openapi-sprint1.json`, fuente para el cliente TypeScript de Claude.

## Pruebas de aceptación

```bash
python -m pytest -q
```

Las pruebas crean una base PostgreSQL vacía y desechable, aplican todas las
migraciones dos veces y validan los criterios de Sprint 1. La matriz de
trazabilidad está en
[`SPRINT1_ACCEPTANCE.md`](SPRINT1_ACCEPTANCE.md).

Las especificaciones por historia, enlazadas a los issues reales de GitHub,
están en [`specs/README.md`](specs/README.md).

La arquitectura, separación de ambientes y política de secretos están en
[`specs/sprint0/EN-005-arquitectura-y-ambientes.md`](specs/sprint0/EN-005-arquitectura-y-ambientes.md).

## Datos Core V3 reconciliados

La base local verificada conserva 187 frascos y 206 movimientos registrados
(205 con efecto). La vista `iqbf.v_panel_core_sprint1` distingue ambos conteos.
El cargador histórico `carga_censo_v3.py` y los esquemas legacy se mantienen
fuera del repositorio porque contienen configuración y datos locales.
