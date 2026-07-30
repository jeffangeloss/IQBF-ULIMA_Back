# US-013 — Búsqueda de insumos y presentaciones

- Issue: [IQBF-ULIMA_Back #13](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/13)
- Prioridad: P0
- Estado del Project: Hecho

## Historia

Como operador, quiero buscar insumos y presentaciones por nombre o cualquiera
de sus códigos.

## Criterios verificados

- [x] La búsqueda ignora tildes y diferencias entre mayúsculas y minúsculas.
- [x] Busca por nombre, código de insumo, código SUNAT y código de
  presentación.
- [x] Cada insumo incluye sus presentaciones anidadas y su conteo.
- [x] Permite filtrar estado y tipo, con paginación.
- [x] La prueba local exige una respuesta menor a un segundo.

## Contrato de backend

- `GET /api/insumos?q={texto}&estado={VIGENTE|INACTIVO|TODOS}&tipo={tipo}`.
- Parámetros de página: `page >= 1` y `1 <= page_size <= 100`.
- La función PostgreSQL `normalizar_busqueda` unifica acentos y caja.
- Los índices trigram de la migración `003` sostienen búsqueda parcial.
- El resultado es `Page[InsumoOut]` e incluye `presentaciones`.

## Evidencia

- `tests/test_acceptance_sprint1.py::test_us013_search_is_normalized_nested_filtered_and_fast`
- `tests/test_api_sprint1.py::test_insumo_presentacion_density_and_audit`
