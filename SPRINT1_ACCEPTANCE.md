# Trazabilidad de aceptación — Sprint 1

Fecha de validación: 27 de julio de 2026.

Fuente de verdad: GitHub Project 2, iteración `S1 — Acceso y maestros`.

Las especificaciones detalladas y sus enlaces a issues reales están en
[`specs/sprint1/README.md`](specs/sprint1/README.md).

| Ítem | Evidencia implementada |
|---|---|
| US-001 | Login, identidad/roles, sesión persistida, logout y rechazo sin crear sesión en `test_us001_invalid_login_does_not_create_session_and_logout_is_recorded`. Autenticación local declarada por `IQBF_AUTH_MODE=local`. |
| US-002 | Seis roles canónicos y permisos diferenciados en backend; cambios de rol auditados. Matriz negativa/positiva en `test_us002_six_roles_have_differentiated_backend_permissions`. |
| US-003 | Código institucional normalizado y único, inactivación sin borrado, revocación de sesiones y bitácora sin hashes. Evidencia en `test_us003_accounts_are_unique_inactivated_and_audited`. |
| US-004 | Establecimientos, carreras, laboratorios y ubicaciones con código, nombre, estado y vigencia; solo referencias vigentes en operaciones nuevas. |
| US-005 | Personas/áreas en `investigador`, identificador único, carrera/laboratorio controlado e inactivación conservando historia. US-004/005 se validan en `test_us004_us005_organization_and_people_keep_vigency_and_history`. |
| US-006 | Alcance global o por establecimiento/laboratorio aplicado a consultas y exportación CSV. Pruebas negativas en `test_user_roles_scope_and_revocation` y US-002. |
| US-007 | Insumo estandarizado, códigos únicos, tipo/unidad compatible y política de densidad en API y triggers. |
| US-008 | Sin `DELETE`; inactivación con motivo/actor/fecha; bloquea presentaciones y lotes nuevos y conserva historia. |
| US-009 | Densidad con unidad, fuente, vigencias no solapadas y snapshot `kardex.densidad_aplicada`. Evidencia en `test_us009_density_versions_and_operation_snapshots`. |
| US-010 | Presentación con capacidad, unidad, equivalencia, envase y códigos únicos; solo se crea para insumo vigente. |
| US-011 | Lotes impiden borrar presentaciones usadas; inactivación impide altas nuevas y `v_inventario_core` conserva frascos. US-007/008/010/011 se validan en `test_us007_us008_us010_us011_master_integrity_and_history`. |
| US-013 | Búsqueda por nombre/códigos sin tildes ni mayúsculas, presentaciones anidadas, filtros de estado e índices trigram. Evidencia y objetivo local menor a 1 s en `test_us013_search_is_normalized_nested_filtered_and_fast`. |
| EN-008 | Bootstrap desde base vacía, migraciones `000..003` repetibles, seeds versionados y estrategia de recuperación documentada en `migrations/README.md`. El fixture de pruebas aplica las migraciones dos veces. |

## Resultado

```text
12 passed
```

La copia migrada de la base real conservó:

- 187 frascos.
- 206 movimientos registrados.
- 205 movimientos con efecto.
- 22 insumos.
- 64 presentaciones.
- 6 roles.
- 0 hashes de contraseña en bitácora.

## Frontera de sprint resuelta

US-030 (registrar consumo) pertenece a Sprint 4 y depende de US-019 (alta de
frasco), US-027 (autorizaciones) y US-033 (kardex/historial). Sprint 1 demuestra
acceso, permisos, alcance y maestros integrados. El motor histórico de kardex
se conserva como evidencia técnica, pero no se presenta como una UI de consumo
terminada en este sprint.
