# US-007 — Maestro de insumos IQBF

- Issue: [IQBF-ULIMA_Back #7](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/7)
- Prioridad: P0
- Estado del Project: Hecho

## Historia

Como responsable, quiero crear y editar insumos IQBF con datos estandarizados.

## Criterios verificados

- [x] Código y nombre son obligatorios; el código de insumo es único.
- [x] Tipo, unidad base, política de densidad y estado son valores
  controlados.
- [x] La unidad de las presentaciones debe ser compatible con el tipo del
  insumo.
- [x] Los códigos fiscales, concentración, capacidad y envase se conservan en
  la presentación asociada.

## Contrato de backend

- `GET /api/insumos`: búsqueda y listado paginado.
- `POST /api/insumos`: alta en estado `VIGENTE`.
- `GET /api/insumos/{id_insumo}`: detalle con presentaciones.
- `PATCH /api/insumos/{id_insumo}`: edición controlada.
- Solo un insumo `LIQUIDO` puede declarar `densidad_variable`.
- No se puede cambiar tipo o política si las presentaciones existentes quedan
  incompatibles.

## Evidencia

- `tests/test_acceptance_sprint1.py::test_us007_us008_us010_us011_master_integrity_and_history`
- `tests/test_api_sprint1.py::test_insumo_presentacion_density_and_audit`
- Tabla: `insumo`; reglas adicionales en migración `003`.
