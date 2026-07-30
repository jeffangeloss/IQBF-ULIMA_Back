# US-010 — Presentaciones de insumo

- Issue: [IQBF-ULIMA_Back #10](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/10)
- Prioridad: P0
- Estado del Project: Hecho

## Historia

Como responsable, quiero asociar presentaciones a cada insumo.

## Criterios verificados

- [x] La presentación registra capacidad, unidad, equivalencia en gramos,
  envase y concentración.
- [x] El identificador, código SUNAT y código de presentación respetan
  unicidad cuando están informados.
- [x] La unidad es compatible con el tipo de insumo.
- [x] Solo se crean presentaciones para un insumo vigente.

## Contrato de backend

- `GET /api/insumos/{id_insumo}/presentaciones`: lista anidada.
- `POST /api/presentaciones`: crea y valida la política química.
- `GET /api/presentaciones/{id_presentacion}`: detalle.
- `PATCH /api/presentaciones/{id_presentacion}`: edición o inactivación.
- Sólidos aceptan `g`/`kg`; líquidos, `mL`/`L`.
- La equivalencia en gramos es obligatoria para el alta.
- Si se entrega densidad fija al crear la presentación, se genera su primera
  versión con fuente `ALTA_PRESENTACION`.

## Evidencia

- `tests/test_acceptance_sprint1.py::test_us007_us008_us010_us011_master_integrity_and_history`
- `tests/test_api_sprint1.py::test_insumo_presentacion_density_and_audit`
- Tablas: `presentacion`, `densidad_vigencia`.
