# EN-003 — Matriz de permisos y RACI

Issue: [IQBF-ULIMA_Front #3](https://github.com/jeffangeloss/IQBF-ULIMA_Front/issues/3)

Sprint: S0 — 15 al 28 de julio de 2026

Estado técnico: **En revisión**

## Leyenda

- **R:** ejecuta la actividad.
- **A:** responde por la decisión final.
- **C:** es consultado.
- **I:** recibe información.
- `—`: no tiene permiso.

El permiso efectivo es la intersección de rol, alcance organizacional, estado
del recurso y reglas de segregación. Tener un rol nunca amplía el alcance
asignado a la cuenta.

## RACI funcional

| Actividad | Responsable IQBF | Operador Docimasia | Docente/Investigador | Aprobador | Auditor | Admin técnico |
|---|---:|---:|---:|---:|---:|---:|
| Mantener insumos/presentaciones/densidades | A/R | C | I | I | consulta | — |
| Recepcionar ingreso y crear frascos | A | R | — | I | consulta | — |
| Registrar custodia/ubicación | A | R | I | I | consulta | — |
| Crear solicitud y justificación | I | C | R | I | consulta propia | — |
| Autorizar solicitud ordinaria | A | I | I | R | consulta | — |
| Registrar consumo/egreso | A | R | C | I | consulta | — |
| Autorizar exceso o excepción | C | I | I | A/R | consulta | — |
| Registrar ajuste físico | A/R | C | I | C | consulta | — |
| Autorizar reversión/corrección | A/R | I | I | C | I | — |
| Reconciliar y cerrar periodo | A/R | C | I | C | C | — |
| Consultar/exportar auditoría | A | consulta | consulta propia | consulta | R | — |
| Gestionar cuentas, roles y alcances | C | — | — | — | consulta | A/R |
| Configurar infraestructura/secretos | I | — | — | — | I | A/R |

## Permisos por rol

### Responsable IQBF

- CRUD de maestros IQBF dentro del alcance global autorizado.
- Consulta de todas las operaciones y evidencias.
- Ajustes, reversión compensatoria y cierre con motivo obligatorio.
- No puede eliminar movimientos confirmados.
- Si originó una excepción, no puede sustituir al Aprobador independiente.

### Operador de Docimasia

- Consulta de maestros vigentes.
- Ingreso, frascos, custodia y movimientos dentro de su establecimiento o
  laboratorio.
- No mantiene cuentas, roles, densidades maestras, cierres ni aprobaciones de
  su propia operación.

### Docente/Investigador

- Crea y consulta sus solicitudes y justificaciones.
- Adjunta evidencia y responde observaciones.
- No registra saldo físico ni aprueba, cierra, revierte o modifica maestros.

### Aprobador

- Consulta la solicitud, riesgo, saldo y evidencia necesarios.
- Autoriza o rechaza solicitudes, excesos y excepciones dentro de su alcance.
- No aprueba una solicitud propia ni una operación en la que actuó como
  ejecutor.

### Auditor

- Solo lectura sobre operaciones, kardex, bitácora, cierres y exportaciones
  autorizadas.
- Puede registrar hallazgos sin modificar el hecho auditado.
- No cambia maestros, saldo, permisos ni decisiones.

### Administrador técnico

- Altas/bajas de cuentas, roles, alcances y soporte de acceso.
- Configuración de ambientes y observabilidad.
- No crea insumos, mueve inventario, autoriza excepciones ni cierra periodos.

## Aprobaciones obligatorias

| Caso | Solicitante/ejecutor | Decisor | Condición mínima |
|---|---|---|---|
| Exceso de umbral | Docente u Operador | Aprobador | Justificación, saldo y evidencia; decisor distinto del solicitante |
| Excepción de regla | Cualquier actor operacional | Aprobador | Regla afectada, riesgo, vigencia y medida compensatoria |
| Ajuste físico | Operador/Responsable | Responsable IQBF | Conteo independiente y causa documentada |
| Reversión | Operador/Responsable | Responsable IQBF | Folio original, motivo y asiento compensatorio |
| Cierre diario/mensual | Operador prepara | Responsable IQBF | Reconciliación sin pendientes o diferencias justificadas |
| Corrección tras cierre | Responsable IQBF | Responsable IQBF + Aprobador si altera declaración | Nueva versión; nunca editar el cierre anterior |

## Sustituciones

1. La sustitución es explícita, nominal, con fecha de inicio/fin y alcance.
2. La persona sustituta usa su propia cuenta; se prohíben cuentas compartidas.
3. La bitácora conserva titular, sustituto, quien autorizó y motivo.
4. El sustituto no hereda permisos fuera del periodo ni del alcance.
5. La sustitución no elimina la segregación: quien solicitó o ejecutó no puede
   autoaprobarse.

## Segregación de funciones

- Solicitar/ejecutar y aprobar una excepción son funciones incompatibles para
  el mismo caso.
- Administrar identidades no habilita funciones operacionales.
- Auditoría es solo lectura sobre el inventario.
- Los cierres y reversiones exigen una identidad individual y motivo.
- La base registra actor, rol efectivo, alcance y `request_id` en cada acción
  auditable.
- Ningún rol puede borrar el kardex o la bitácora.

## Estado de implementación

El backend ya implementa los seis roles, alcances global/establecimiento/
laboratorio, autenticación y controles de maestros. Las reglas de aprobación,
excepción, cierre y sustitución aquí definidas son el contrato para los
siguientes módulos; no deben mostrarse en la interfaz como si ya estuvieran
implementadas.

## Criterios de aceptación

- [x] Cada rol tiene acciones permitidas y alcance.
- [x] Se identifican aprobaciones de excesos, reversiones y cierres.
- [x] Se definen sustituciones y segregación de funciones.

## Conformidad

La matriz requiere validación organizacional en el issue. Hasta recibirla,
permanece **En revisión** aunque su contenido técnico esté completo.
