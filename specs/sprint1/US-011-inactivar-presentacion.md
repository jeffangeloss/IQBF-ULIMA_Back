# US-011 — Inactivación de presentación

- Issue: [IQBF-ULIMA_Back #11](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/11)
- Prioridad: P0
- Estado del Project: Hecho

## Historia

Como responsable, quiero inactivar una presentación conservando sus frascos y
movimientos.

## Criterios verificados

- [x] Una presentación usada no se borra físicamente.
- [x] La presentación inactiva impide nuevas altas.
- [x] Los frascos y movimientos existentes continúan visibles.
- [x] La inactivación exige motivo y se audita.

## Contrato de backend

- La transición se realiza mediante
  `PATCH /api/presentaciones/{id_presentacion}` con `estado=INACTIVO` y
  `motivo`.
- Omitir el motivo devuelve `422 MOTIVO_REQUERIDO`.
- Las reglas de PostgreSQL impiden asociar lotes nuevos a una presentación
  inactiva.
- `GET /api/insumos/{id_insumo}/presentaciones?incluir_inactivas=true`
  permite recuperar el maestro histórico.
- `iqbf.v_inventario_core` conserva la visibilidad de los frascos.
- No existe endpoint de borrado físico.

## Evidencia

- `tests/test_acceptance_sprint1.py::test_us007_us008_us010_us011_master_integrity_and_history`
- Migración `003_sprint1_integrity.sql`.
