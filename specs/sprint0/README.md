# Sprint 0 — Base funcional y técnica

Periodo del sprint: **15 al 28 de julio de 2026**.

Esta carpeta deja trazabilidad entre los cinco entregables del Sprint 0, los
issues reales de GitHub y la evidencia técnica disponible al 30 de julio de
2026. Una especificación terminada no sustituye una aprobación institucional:
cuando el criterio exige la firma del Responsable IQBF, el artefacto queda en
revisión o bloqueado hasta que dicha persona deje constancia.

## Matriz de trazabilidad

| ID | Entregable | Issue | Evidencia | Estado técnico | Pendiente externo |
|---|---|---|---|---|---|
| EN-001 | Mapa TO-BE y actores | [Front #1](https://github.com/jeffangeloss/IQBF-ULIMA_Front/issues/1) | [Mapa operativo](EN-001-mapa-to-be-y-actores.md) | En revisión | Aprobación del Responsable IQBF |
| EN-002 | Diccionario y reglas de cálculo | [Front #2](https://github.com/jeffangeloss/IQBF-ULIMA_Front/issues/2) | [Diccionario canónico](EN-002-diccionario-y-reglas-calculo.md) | En revisión | Validación funcional |
| EN-003 | Permisos y RACI | [Front #3](https://github.com/jeffangeloss/IQBF-ULIMA_Front/issues/3) | [Matriz de permisos](EN-003-matriz-permisos-raci.md) | En revisión | Validación organizacional |
| EN-004 | Formato de declaración y reconciliación | [Front #4](https://github.com/jeffangeloss/IQBF-ULIMA_Front/issues/4) | [Contrato de consolidación](EN-004-formato-declaracion-reconciliacion.md) | Bloqueado | Aprobación de formato y contraste celda a celda |
| EN-005 | Arquitectura y ambientes | [Back #58](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/58) | [Arquitectura reproducible](EN-005-arquitectura-y-ambientes.md) | Hecho | Ninguno |

## Regla de estados

- **En revisión:** el artefacto técnico existe y cubre los criterios, pero
  requiere conformidad de una persona responsable.
- **Bloqueado:** falta una decisión o fuente externa que el equipo no debe
  inventar.
- **Hecho:** los criterios son verificables en el repositorio y no queda una
  aprobación externa pendiente.

## Fuentes contrastadas

- Backlog del GitHub Project 2 y sus cinco issues de Sprint 0.
- Esquema Core V3 implementado por las migraciones `000` a `003`.
- BPMN existente `Proceso_IQBF_BPMN.drawio`, usado como antecedente.
- Archivos históricos de junio de 2026 (`RM04`, líquidos, sólidos y
  justificación de consumo), disponibles localmente y no incorporados al
  repositorio porque contienen datos operativos.
- Contrato OpenAPI, pruebas y documentación de arranque del backend actual.

## Cierre del sprint

EN-005 queda cerrado técnicamente. EN-001, EN-002 y EN-003 quedan preparados
para acta de conformidad. EN-004 conserva un bloqueo explícito: no se declarará
aprobado hasta revisar el libro histórico con una herramienta de Excel
habilitada y obtener la conformidad del Responsable IQBF sobre columnas,
códigos, unidades y redondeo.
