# Especificaciones del backend IQBF

Esta carpeta convierte el backlog en contratos verificables de backend. Cada
spec enlaza el issue real de GitHub, conserva los criterios de aceptación y
señala la API, las reglas de persistencia y las pruebas que sirven como
evidencia.

## Convenciones

- GitHub Project 2 es la fuente de prioridad, sprint y estado.
- El issue de GitHub es la fuente de la historia y sus criterios.
- La spec define el comportamiento observable del backend.
- `openapi-sprint1.json` es el contrato consumido por el frontend.
- `tests/` contiene la evidencia automatizada.
- Los cambios incompatibles requieren actualizar issue, spec, OpenAPI y
  pruebas en el mismo trabajo.

## Entregas documentadas

- [Sprint 1 — Acceso y maestros](sprint1/README.md)

## Evidencia complementaria

- [Trazabilidad de aceptación](../SPRINT1_ACCEPTANCE.md)
- [Reconciliación Core V3](../CORE_V3_RECONCILIACION.md)
- [Migraciones y recuperación](../migrations/README.md)
