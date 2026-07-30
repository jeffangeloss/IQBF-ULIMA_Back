# Migraciones y recuperación

## Aplicación

Desde `IQBF-ULIMA_Back`, con el entorno virtual activo:

```bash
python -m app.cli migrate
```

El ejecutor ordena los archivos por versión, comprueba
`iqbf.schema_migration` y omite versiones ya aplicadas. El flujo fue validado
tanto desde una base vacía como desde una copia exacta de `iqbf_mvp`.

## Versiones

- `000_core_baseline.sql`: esquema operacional mínimo sin censo ni
  credenciales.
- `001_sprint1_core.sql`: autenticación local, seis roles, alcance,
  organización, maestros, densidad versionada y bitácora.
- `002_sprint1_acceptance.sql`: atributos y política química recuperados de
  IQBF Core V3, vistas de control y registro de seeds.
- `003_sprint1_integrity.sql`: reglas de altas vigentes, motivos de
  inactivación, unicidad fiscal e índices trigram.

Los seeds se registran en `iqbf.seed_migration`. Ninguna migración contiene el
censo de frascos ni contraseñas.

## Estrategia de rollback

Las migraciones son *forward-only* porque el kardex y la bitácora son evidencia
histórica. No se ofrecen scripts `down` que borren columnas o registros.

Antes de migrar:

```bash
pg_dump --format=custom --no-owner --no-privileges \
  --file=/ruta/segura/iqbf_pre_migracion.dump iqbf_mvp
shasum -a 256 /ruta/segura/iqbf_pre_migracion.dump
```

Si una validación posterior falla:

1. Detener la API para impedir nuevas escrituras.
2. Conservar la base afectada para análisis; no sobrescribirla.
3. Restaurar el dump en una base nueva.
4. Verificar conteos, integridad y checksum.
5. Cambiar `IQBF_DATABASE_URL` a la base recuperada y reiniciar la API.
6. Corregir mediante una migración de avance nueva.

Ejemplo de restauración aislada:

```bash
createdb iqbf_recuperacion
pg_restore --no-owner --no-privileges --exit-on-error \
  --dbname=iqbf_recuperacion /ruta/segura/iqbf_pre_migracion.dump
```

El respaldo previo a la reconciliación de Core V3 del 27 de julio de 2026 está
fuera del repositorio de frontend y no debe publicarse.
