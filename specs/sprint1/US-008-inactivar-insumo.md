# US-008 — Inactivación de insumo

- Issue: [IQBF-ULIMA_Back #8](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/8)
- Prioridad: P0
- Estado del Project: Hecho

## Historia

Como responsable, quiero inactivar un insumo sin perder su historial.

## Criterios verificados

- [x] Un insumo usado no se borra y continúa disponible en consultas
  históricas.
- [x] Un insumo inactivo bloquea nuevas presentaciones y lotes.
- [x] El cambio de estado exige motivo y registra actor y fecha.

## Contrato de backend

- La transición se realiza con `PATCH /api/insumos/{id_insumo}` enviando
  `estado=INACTIVO` y `motivo`.
- Omitir el motivo responde `422 MOTIVO_REQUERIDO`.
- `POST /api/presentaciones` para un insumo inactivo responde
  `409 INSUMO_INACTIVO`.
- `GET /api/insumos?estado=TODOS` sigue devolviendo el maestro y sus
  relaciones.
- No existe endpoint `DELETE /api/insumos/{id_insumo}`.

## Evidencia

- `tests/test_acceptance_sprint1.py::test_us007_us008_us010_us011_master_integrity_and_history`
- Trigger de auditoría e integridad en `migrations/003_sprint1_integrity.sql`.
