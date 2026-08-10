-- ═══════════════════════════════════════════════════════════════════
-- Carga inicial del censo fotográfico IQBF — insumos líquidos
-- Generado por carga_censo_v4.py · fecha de corte 2026-08-05
-- Fuente: Cimiento_Censo_IQBF_v5_2026-08-06.xlsx
--
-- 96 frascos cargados · 6 descartados por el pre-flight
--
-- Un campo vacío YA NO descarta: el frasco entra con el hueco marcado
-- (sin código SUNAT, sin densidad, sin fecha) y la aplicación lo enseña
-- como alerta. Lo que queda fuera es lo que no se puede IDENTIFICAR ni
-- PESAR, o lo que exige una decisión del laboratorio. Se resuelve
-- volviendo a la foto o rotulando el frasco, no eligiendo un número.
-- Se resuelven volviendo a la foto, no eligiendo el número más creíble.
--   fila  99  IQF0708-141-01
--       · C10 el insumo IQF0708 aparece como liquido y como sólido en el censo; el modelo guarda un solo estado por insumo y manda el de sus otras presentaciones. Este frasco necesita su propio código.
--   fila 186  SIN-CODIGO-01
--       · C9 el envase no está rotulado: su código es un provisional del censo, no existe en el frasco
--   fila 187  SIN-CODIGO-02
--       · C9 el envase no está rotulado: su código es un provisional del censo, no existe en el frasco
--   fila 188  SIN-CODIGO-03
--       · C9 el envase no está rotulado: su código es un provisional del censo, no existe en el frasco
--   fila 189  SIN-CODIGO-04
--       · C9 el envase no está rotulado: su código es un provisional del censo, no existe en el frasco
--   fila 200  IQF1413-1
--       · C4 falta Presentación (L11)
-- ═══════════════════════════════════════════════════════════════════

BEGIN;
SET LOCAL search_path TO iqbf, public, pg_catalog;

-- ─── establecimiento y ubicaciones ────────────────────────────────
-- El establecimiento NO se crea: se usa el que ya exista. Crear uno
-- propio dejaba las ubicaciones colgando de un establecimiento
-- paralelo, invisible para toda cuenta con alcance de laboratorio.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM establecimiento) THEN
    INSERT INTO establecimiento (codigo, nombre) VALUES ('ULIMA-DOCIMASIA', 'Laboratorio de Docimasia — Universidad de Lima');
  END IF;
END;
$$;

INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N1', 'Casillero 1 · Nivel 1', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 1, NULL
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N1-P10', 'Casillero 1 · Nivel 1 · pos. 10', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 1, '10'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N1-P13', 'Casillero 1 · Nivel 1 · pos. 13', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 1, '13'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N1-P14', 'Casillero 1 · Nivel 1 · pos. 14', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 1, '14'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N1-P2', 'Casillero 1 · Nivel 1 · pos. 2', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 1, '2'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N1-P3', 'Casillero 1 · Nivel 1 · pos. 3', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 1, '3'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N1-P4', 'Casillero 1 · Nivel 1 · pos. 4', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 1, '4'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N1-P5', 'Casillero 1 · Nivel 1 · pos. 5', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 1, '5'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N1-P6', 'Casillero 1 · Nivel 1 · pos. 6', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 1, '6'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N1-P7', 'Casillero 1 · Nivel 1 · pos. 7', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 1, '7'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N1-P8', 'Casillero 1 · Nivel 1 · pos. 8', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 1, '8'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N1-P9', 'Casillero 1 · Nivel 1 · pos. 9', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 1, '9'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N2', 'Casillero 1 · Nivel 2', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 2, NULL
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N2-P15', 'Casillero 1 · Nivel 2 · pos. 15', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 2, '15'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N2-P16', 'Casillero 1 · Nivel 2 · pos. 16', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 2, '16'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N2-P17', 'Casillero 1 · Nivel 2 · pos. 17', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 2, '17'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N2-P18', 'Casillero 1 · Nivel 2 · pos. 18', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 2, '18'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N2-P19', 'Casillero 1 · Nivel 2 · pos. 19', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 2, '19'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N2-P21', 'Casillero 1 · Nivel 2 · pos. 21', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 2, '21'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N2-P22', 'Casillero 1 · Nivel 2 · pos. 22', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 2, '22'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N2-P26', 'Casillero 1 · Nivel 2 · pos. 26', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 2, '26'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N2-P30', 'Casillero 1 · Nivel 2 · pos. 30', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 2, '30'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N2-P33', 'Casillero 1 · Nivel 2 · pos. 33', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 2, '33'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N2-P34', 'Casillero 1 · Nivel 2 · pos. 34', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 2, '34'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N2-P35', 'Casillero 1 · Nivel 2 · pos. 35', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 2, '35'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N2-P36', 'Casillero 1 · Nivel 2 · pos. 36', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 2, '36'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C1-N2-P37', 'Casillero 1 · Nivel 2 · pos. 37', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  1, NULL, 2, '37'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N2', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 2', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 2, NULL
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N2-P62', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 2 · pos. 62', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 2, '62'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N2-P63', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 2 · pos. 63', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 2, '63'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N2-P64', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 2 · pos. 64', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 2, '64'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N2-P66', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 2 · pos. 66', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 2, '66'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N2-P67', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 2 · pos. 67', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 2, '67'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N2-P68', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 2 · pos. 68', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 2, '68'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N2-P69', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 2 · pos. 69', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 2, '69'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N2-P71', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 2 · pos. 71', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 2, '71'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N2-P72', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 2 · pos. 72', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 2, '72'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N3', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 3', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 3, NULL
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N3-P76', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 3 · pos. 76', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 3, '76'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N3-P77', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 3 · pos. 77', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 3, '77'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N3-P78', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 3 · pos. 78', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 3, '78'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N3-P79', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 3 · pos. 79', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 3, '79'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N3-P80', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 3 · pos. 80', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 3, '80'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N3-P81', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 3 · pos. 81', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 3, '81'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N3-P82', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 3 · pos. 82', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 3, '82'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N3-P84', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 3 · pos. 84', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 3, '84'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N3-P85', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 3 · pos. 85', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 3, '85'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N3-P90', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 3 · pos. 90', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 3, '90'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N3-P91', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 3 · pos. 91', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 3, '91'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N4', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 4', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 4, NULL
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N4-P40', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 4 · pos. 40', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 4, '40'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N4-P41', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 4 · pos. 41', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 4, '41'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N4-P42', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 4 · pos. 42', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 4, '42'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N4-P43', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 4 · pos. 43', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 4, '43'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N4-P44', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 4 · pos. 44', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 4, '44'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N4-P45', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 4 · pos. 45', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 4, '45'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N4-P46', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 4 · pos. 46', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 4, '46'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N4-P47', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 4 · pos. 47', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 4, '47'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C2-N4-P48', 'Casillero 2 (ÁCIDOS FUERTES) · Nivel 4 · pos. 48', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  2, 'ÁCIDOS FUERTES', 4, '48'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C3-N2-P101', 'Casillero 3 (SÓLIDOS) · Nivel 2 · pos. 101', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  3, 'SÓLIDOS', 2, '101'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C3-N2-P102', 'Casillero 3 (SÓLIDOS) · Nivel 2 · pos. 102', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  3, 'SÓLIDOS', 2, '102'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C3-N2-P103', 'Casillero 3 (SÓLIDOS) · Nivel 2 · pos. 103', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  3, 'SÓLIDOS', 2, '103'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C3-N2-P104', 'Casillero 3 (SÓLIDOS) · Nivel 2 · pos. 104', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  3, 'SÓLIDOS', 2, '104'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C3-N2-P108', 'Casillero 3 (SÓLIDOS) · Nivel 2 · pos. 108', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  3, 'SÓLIDOS', 2, '108'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C3-N2-P109', 'Casillero 3 (SÓLIDOS) · Nivel 2 · pos. 109', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  3, 'SÓLIDOS', 2, '109'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C3-N2-P111', 'Casillero 3 (SÓLIDOS) · Nivel 2 · pos. 111', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  3, 'SÓLIDOS', 2, '111'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C3-N2-P114', 'Casillero 3 (SÓLIDOS) · Nivel 2 · pos. 114', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  3, 'SÓLIDOS', 2, '114'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C3-N2-P115', 'Casillero 3 (SÓLIDOS) · Nivel 2 · pos. 115', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  3, 'SÓLIDOS', 2, '115'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C3-N2-P116', 'Casillero 3 (SÓLIDOS) · Nivel 2 · pos. 116', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  3, 'SÓLIDOS', 2, '116'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C3-N2-P117', 'Casillero 3 (SÓLIDOS) · Nivel 2 · pos. 117', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  3, 'SÓLIDOS', 2, '117'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C3-N2-P118', 'Casillero 3 (SÓLIDOS) · Nivel 2 · pos. 118', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  3, 'SÓLIDOS', 2, '118'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C3-N2-P119', 'Casillero 3 (SÓLIDOS) · Nivel 2 · pos. 119', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  3, 'SÓLIDOS', 2, '119'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C3-N2-P120', 'Casillero 3 (SÓLIDOS) · Nivel 2 · pos. 120', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  3, 'SÓLIDOS', 2, '120'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C3-N2-P121', 'Casillero 3 (SÓLIDOS) · Nivel 2 · pos. 121', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  3, 'SÓLIDOS', 2, '121'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C3-N2-P97', 'Casillero 3 (SÓLIDOS) · Nivel 2 · pos. 97', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  3, 'SÓLIDOS', 2, '97'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C3-N2-P98', 'Casillero 3 (SÓLIDOS) · Nivel 2 · pos. 98', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  3, 'SÓLIDOS', 2, '98'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;
INSERT INTO ubicacion (codigo, nombre, id_establecimiento, id_laboratorio, casillero, nombre_puerta, nivel, posicion)
SELECT 'C3-N2-P99', 'Casillero 3 (SÓLIDOS) · Nivel 2 · pos. 99', e.id_establecimiento,
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  3, 'SÓLIDOS', 2, '99'
  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1
  ON CONFLICT (codigo) DO UPDATE SET
    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,
    id_establecimiento = EXCLUDED.id_establecimiento,
    id_laboratorio = EXCLUDED.id_laboratorio,
    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,
    posicion = EXCLUDED.posicion;

-- ─── investigadores (lista controlada · US-04) ────────────────────
-- Nombres canónicos: ver ALIAS_CUSTODIO en carga_censo_v4.py.
--
-- La base exige que todo investigador tenga carrera o laboratorio
-- (ck_investigador_adscripcion). Se resuelve en este orden:
--   1. si es un ÁREA, su laboratorio es él mismo;
--   2. si todos sus frascos declaran el mismo laboratorio, ese;
--   3. si no, el del almacén donde están sus frascos, MARCADO COMO
--      PROVISIONAL: es dónde está el producto, no dónde trabaja la
--      persona. Hay que confirmarlo con el laboratorio.
-- PROVISIONAL · Abel Gutarra: sin laboratorio en ninguno de sus frascos; se le adscribe «Docimasia» por ser el almacén donde están. CONFIRMAR.
INSERT INTO investigador (nombre, tipo, id_laboratorio)
SELECT 'Abel Gutarra', 'PERSONA', (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia')
WHERE NOT EXISTS (SELECT 1 FROM investigador WHERE nombre IN ('Abel Gutarra'));
INSERT INTO investigador (nombre, tipo, id_laboratorio)
SELECT 'Académico', 'AREA', (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Académico')
WHERE NOT EXISTS (SELECT 1 FROM investigador WHERE nombre IN ('Académico'));
INSERT INTO investigador (nombre, tipo, id_laboratorio)
SELECT 'Académico (lab Quimica)', 'PERSONA', (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Laboratorio de Química')
WHERE NOT EXISTS (SELECT 1 FROM investigador WHERE nombre IN ('Académico (lab Quimica)'));
-- PROVISIONAL · Chasquibol: sin laboratorio en ninguno de sus frascos; se le adscribe «Docimasia» por ser el almacén donde están. CONFIRMAR.
INSERT INTO investigador (nombre, tipo, id_laboratorio)
SELECT 'Chasquibol', 'PERSONA', (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia')
WHERE NOT EXISTS (SELECT 1 FROM investigador WHERE nombre IN ('Chasquibol'));
-- PROVISIONAL · H. Villagarcía: sin laboratorio en ninguno de sus frascos; se le adscribe «Docimasia» por ser el almacén donde están. CONFIRMAR.
INSERT INTO investigador (nombre, tipo, id_laboratorio)
SELECT 'H. Villagarcía', 'PERSONA', (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia')
WHERE NOT EXISTS (SELECT 1 FROM investigador WHERE nombre IN ('H. Villagarcía'));
INSERT INTO investigador (nombre, tipo, id_laboratorio)
SELECT 'Ing. Civil', 'AREA', (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Ingeniería Civil')
WHERE NOT EXISTS (SELECT 1 FROM investigador WHERE nombre IN ('Ing. Civil'));
INSERT INTO investigador (nombre, tipo, id_laboratorio)
SELECT 'Juan Carlos Yacono', 'PERSONA', (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Ingeniería Civil')
WHERE NOT EXISTS (SELECT 1 FROM investigador WHERE nombre IN ('Juan Carlos Yacono'));
-- PROVISIONAL · La Cruz: sin laboratorio en ninguno de sus frascos; se le adscribe «Docimasia» por ser el almacén donde están. CONFIRMAR.
INSERT INTO investigador (nombre, tipo, id_laboratorio)
SELECT 'La Cruz', 'PERSONA', (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia')
WHERE NOT EXISTS (SELECT 1 FROM investigador WHERE nombre IN ('La Cruz'));
INSERT INTO investigador (nombre, tipo, id_laboratorio)
SELECT 'Lab. Alimentos', 'AREA', (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Laboratorio de Alimentos')
WHERE NOT EXISTS (SELECT 1 FROM investigador WHERE nombre IN ('Lab. Alimentos'));
INSERT INTO investigador (nombre, tipo, id_laboratorio)
SELECT 'Lab. Docimasia', 'AREA', (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia')
WHERE NOT EXISTS (SELECT 1 FROM investigador WHERE nombre IN ('Lab. Docimasia'));
-- PROVISIONAL · Montoya: sin laboratorio en ninguno de sus frascos; se le adscribe «Docimasia» por ser el almacén donde están. CONFIRMAR.
INSERT INTO investigador (nombre, tipo, id_laboratorio)
SELECT 'Montoya', 'PERSONA', (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia')
WHERE NOT EXISTS (SELECT 1 FROM investigador WHERE nombre IN ('Montoya'));
-- PROVISIONAL · Muedas: sin laboratorio en ninguno de sus frascos; se le adscribe «Docimasia» por ser el almacén donde están. CONFIRMAR.
INSERT INTO investigador (nombre, tipo, id_laboratorio)
SELECT 'Muedas', 'PERSONA', (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia')
WHERE NOT EXISTS (SELECT 1 FROM investigador WHERE nombre IN ('Muedas'));
INSERT INTO investigador (nombre, tipo, id_laboratorio)
SELECT 'Quino', 'PERSONA', (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'FAUGRO Microbiología')
WHERE NOT EXISTS (SELECT 1 FROM investigador WHERE nombre IN ('Quino'));
-- PROVISIONAL · Sanabria: sin laboratorio en ninguno de sus frascos; se le adscribe «Docimasia» por ser el almacén donde están. CONFIRMAR.
INSERT INTO investigador (nombre, tipo, id_laboratorio)
SELECT 'Sanabria', 'PERSONA', (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia')
WHERE NOT EXISTS (SELECT 1 FROM investigador WHERE nombre IN ('Sanabria'));
-- PROVISIONAL · Silvia Ponce: sin laboratorio en ninguno de sus frascos; se le adscribe «Docimasia» por ser el almacén donde están. CONFIRMAR.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM investigador) THEN
    INSERT INTO investigador (nombres, apellidos, correo_ulima, rol)
    VALUES ('Administrador', 'Sistema IQBF', 'admin@aloe.ulima.edu.pe', 'ADMINISTRADOR');
  END IF;
END;
$$;
INSERT INTO investigador (nombre, tipo, id_laboratorio)
SELECT 'Silvia Ponce', 'PERSONA', (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia')
WHERE NOT EXISTS (SELECT 1 FROM investigador WHERE nombre IN ('Silvia Ponce'));
INSERT INTO investigador (nombre, tipo, id_laboratorio)
SELECT 'W. Hernández', 'PERSONA', (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia')
WHERE NOT EXISTS (SELECT 1 FROM investigador WHERE nombre IN ('W. Hernández'));

-- ─── el censo necesita un usuario que lo firme ────────────────────
-- Sin cuenta no hay movimiento: registrado_por es NOT NULL y la
-- trazabilidad de US-18 exige saber quién cargó cada saldo.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM usuario) THEN
    INSERT INTO usuario (id_usuario, nombre, email, contrasena, rol, estado)
    VALUES (1, 'Administrador Sistema', 'admin@aloe.ulima.edu.pe', '$2b$12$eImiTXuWVxfM37uY4JANjO5E/151.7.0.0.0.0.0.0.0.0.0.0.0.0.0', 'ADMINISTRADOR', 'ACTIVO')
    ON CONFLICT DO NOTHING;
  END IF;
END;
$$;

-- ─── insumos ──────────────────────────────────────────────────────
INSERT INTO insumo (id_insumo, nombre_comercial, tipo, unidad_base, densidad_variable, estado)
VALUES ('IQF0102', 'Ácido clorhídrico', 'LIQUIDO', 'g', FALSE, 'VIGENTE')
  ON CONFLICT (id_insumo) DO UPDATE SET
    nombre_comercial = EXCLUDED.nombre_comercial,
    tipo = EXCLUDED.tipo,
    densidad_variable = EXCLUDED.densidad_variable;
INSERT INTO insumo (id_insumo, nombre_comercial, tipo, unidad_base, densidad_variable, estado)
VALUES ('IQF0106', 'Acido Nitrico', 'LIQUIDO', 'g', FALSE, 'VIGENTE')
  ON CONFLICT (id_insumo) DO UPDATE SET
    nombre_comercial = EXCLUDED.nombre_comercial,
    tipo = EXCLUDED.tipo,
    densidad_variable = EXCLUDED.densidad_variable;
INSERT INTO insumo (id_insumo, nombre_comercial, tipo, unidad_base, densidad_variable, estado)
VALUES ('IQF0108', 'Ácido sulfúrico', 'LIQUIDO', 'g', FALSE, 'VIGENTE')
  ON CONFLICT (id_insumo) DO UPDATE SET
    nombre_comercial = EXCLUDED.nombre_comercial,
    tipo = EXCLUDED.tipo,
    densidad_variable = EXCLUDED.densidad_variable;
INSERT INTO insumo (id_insumo, nombre_comercial, tipo, unidad_base, densidad_variable, estado)
VALUES ('IQF0213', 'Anhidrido Acetico 97%', 'LIQUIDO', 'g', FALSE, 'VIGENTE')
  ON CONFLICT (id_insumo) DO UPDATE SET
    nombre_comercial = EXCLUDED.nombre_comercial,
    tipo = EXCLUDED.tipo,
    densidad_variable = EXCLUDED.densidad_variable;
INSERT INTO insumo (id_insumo, nombre_comercial, tipo, unidad_base, densidad_variable, estado)
VALUES ('IQF0304', 'Ethanol', 'LIQUIDO', 'g', FALSE, 'VIGENTE')
  ON CONFLICT (id_insumo) DO UPDATE SET
    nombre_comercial = EXCLUDED.nombre_comercial,
    tipo = EXCLUDED.tipo,
    densidad_variable = EXCLUDED.densidad_variable;
INSERT INTO insumo (id_insumo, nombre_comercial, tipo, unidad_base, densidad_variable, estado)
VALUES ('IQF0308', 'Metanol', 'LIQUIDO', 'g', FALSE, 'VIGENTE')
  ON CONFLICT (id_insumo) DO UPDATE SET
    nombre_comercial = EXCLUDED.nombre_comercial,
    tipo = EXCLUDED.tipo,
    densidad_variable = EXCLUDED.densidad_variable;
INSERT INTO insumo (id_insumo, nombre_comercial, tipo, unidad_base, densidad_variable, estado)
VALUES ('IQF0401', 'Acetona', 'LIQUIDO', 'g', FALSE, 'VIGENTE')
  ON CONFLICT (id_insumo) DO UPDATE SET
    nombre_comercial = EXCLUDED.nombre_comercial,
    tipo = EXCLUDED.tipo,
    densidad_variable = EXCLUDED.densidad_variable;
INSERT INTO insumo (id_insumo, nombre_comercial, tipo, unidad_base, densidad_variable, estado)
VALUES ('IQF0408', 'Acetato De Etilo', 'LIQUIDO', 'g', FALSE, 'VIGENTE')
  ON CONFLICT (id_insumo) DO UPDATE SET
    nombre_comercial = EXCLUDED.nombre_comercial,
    tipo = EXCLUDED.tipo,
    densidad_variable = EXCLUDED.densidad_variable;
INSERT INTO insumo (id_insumo, nombre_comercial, tipo, unidad_base, densidad_variable, estado)
VALUES ('IQF0501', 'Éter dietílico', 'LIQUIDO', 'g', FALSE, 'VIGENTE')
  ON CONFLICT (id_insumo) DO UPDATE SET
    nombre_comercial = EXCLUDED.nombre_comercial,
    tipo = EXCLUDED.tipo,
    densidad_variable = EXCLUDED.densidad_variable;
INSERT INTO insumo (id_insumo, nombre_comercial, tipo, unidad_base, densidad_variable, estado)
VALUES ('IQF0502', 'Eter Sulfurico', 'LIQUIDO', 'g', FALSE, 'VIGENTE')
  ON CONFLICT (id_insumo) DO UPDATE SET
    nombre_comercial = EXCLUDED.nombre_comercial,
    tipo = EXCLUDED.tipo,
    densidad_variable = EXCLUDED.densidad_variable;
INSERT INTO insumo (id_insumo, nombre_comercial, tipo, unidad_base, densidad_variable, estado)
VALUES ('IQF0605', 'N-Hexano', 'LIQUIDO', 'g', FALSE, 'VIGENTE')
  ON CONFLICT (id_insumo) DO UPDATE SET
    nombre_comercial = EXCLUDED.nombre_comercial,
    tipo = EXCLUDED.tipo,
    densidad_variable = EXCLUDED.densidad_variable;
INSERT INTO insumo (id_insumo, nombre_comercial, tipo, unidad_base, densidad_variable, estado)
VALUES ('IQF0612', 'Xileno', 'LIQUIDO', 'g', FALSE, 'VIGENTE')
  ON CONFLICT (id_insumo) DO UPDATE SET
    nombre_comercial = EXCLUDED.nombre_comercial,
    tipo = EXCLUDED.tipo,
    densidad_variable = EXCLUDED.densidad_variable;
INSERT INTO insumo (id_insumo, nombre_comercial, tipo, unidad_base, densidad_variable, estado)
VALUES ('IQF0613', 'Tolueno', 'LIQUIDO', 'g', FALSE, 'VIGENTE')
  ON CONFLICT (id_insumo) DO UPDATE SET
    nombre_comercial = EXCLUDED.nombre_comercial,
    tipo = EXCLUDED.tipo,
    densidad_variable = EXCLUDED.densidad_variable;
INSERT INTO insumo (id_insumo, nombre_comercial, tipo, unidad_base, densidad_variable, estado)
VALUES ('IQF0702', 'Hidróxido de amonio', 'LIQUIDO', 'g', FALSE, 'VIGENTE')
  ON CONFLICT (id_insumo) DO UPDATE SET
    nombre_comercial = EXCLUDED.nombre_comercial,
    tipo = EXCLUDED.tipo,
    densidad_variable = EXCLUDED.densidad_variable;
INSERT INTO insumo (id_insumo, nombre_comercial, tipo, unidad_base, densidad_variable, estado)
VALUES ('IQF0708', 'Hidróxido de sodio en solución', 'SOLIDO', 'g', FALSE, 'VIGENTE')
  ON CONFLICT (id_insumo) DO UPDATE SET
    nombre_comercial = EXCLUDED.nombre_comercial,
    tipo = EXCLUDED.tipo,
    densidad_variable = EXCLUDED.densidad_variable;
INSERT INTO insumo (id_insumo, nombre_comercial, tipo, unidad_base, densidad_variable, estado)
VALUES ('IQF0904', 'Oxido De Calcio', 'SOLIDO', 'g', FALSE, 'VIGENTE')
  ON CONFLICT (id_insumo) DO UPDATE SET
    nombre_comercial = EXCLUDED.nombre_comercial,
    tipo = EXCLUDED.tipo,
    densidad_variable = EXCLUDED.densidad_variable;
INSERT INTO insumo (id_insumo, nombre_comercial, tipo, unidad_base, densidad_variable, estado)
VALUES ('IQF1122', 'Carbonato De Sodio Anhidro', 'SOLIDO', 'g', FALSE, 'VIGENTE')
  ON CONFLICT (id_insumo) DO UPDATE SET
    nombre_comercial = EXCLUDED.nombre_comercial,
    tipo = EXCLUDED.tipo,
    densidad_variable = EXCLUDED.densidad_variable;
INSERT INTO insumo (id_insumo, nombre_comercial, tipo, unidad_base, densidad_variable, estado)
VALUES ('IQF1123', 'Carbonato De Potasio', 'SOLIDO', 'g', FALSE, 'VIGENTE')
  ON CONFLICT (id_insumo) DO UPDATE SET
    nombre_comercial = EXCLUDED.nombre_comercial,
    tipo = EXCLUDED.tipo,
    densidad_variable = EXCLUDED.densidad_variable;

-- ─── presentaciones ───────────────────────────────────────────────
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0102-111', 'IQF0102', '000111', '111',
  '36.5% - 38%', 2.5, 'L', 'Botella de',
  2950.0000, 1.1800, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0102-112', 'IQF0102', '000112', '112',
  '36.5 % - 38 %', 2.5, 'L', 'Botella de',
  2950.0000, 1.1800, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0102-115', 'IQF0102', '000115', '115',
  '37 %', 2.5, 'L', 'Botella de',
  2975.0000, 1.1920, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0102-123', 'IQF0102', '000123', '123',
  '36.5% - 38%', 2.5, 'L', 'Botella de',
  2950.0000, 1.1800, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0102-137', 'IQF0102', '000137', '137',
  '32 % - 35 %', 0.5, 'L', 'Botella de',
  590.0000, 1.1800, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0102-69', 'IQF0102', '000069', '69',
  '36.8 %', 0.5, 'L', 'Botella Frasco de',
  2950.0000, 1.1800, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0106-116', 'IQF0106', '000116', '116',
  '65%', 1, 'L', 'Botella de',
  1390.0000, 1.3900, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0106-122', 'IQF0106', '000122', '122',
  '64.5 - 66.5 % (Ensayo como HNO3)', 2.5, 'L', 'Botella de',
  3525.0000, 1.4100, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0106-124', 'IQF0106', NULL, '124',
  '65 %', 2.5, 'L', 'Botella de vidrio',
  3475.0000, 1.3900, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0106-134', 'IQF0106', '000134', '134',
  '65%', 2.5, 'L', 'Botella de',
  3480.0000, 1.3920, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0108-084', 'IQF0108', '000084', '084',
  '95-97%', 1, 'L', 'Botella de vidrio',
  1840.0000, 1.8400, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0108-104', 'IQF0108', '000104', '104',
  NULL, 1, 'L', 'Botella de',
  1840.0000, 1.8400, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0108-120', 'IQF0108', '000120', '120',
  '95-97%', 2.5, 'L', 'Botella de vidrio',
  4600.0000, 1.8400, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0108-129', 'IQF0108', '000129', '129',
  NULL, 2.5, 'L', 'Botella de',
  4600.0000, 1.8400, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0213-19', 'IQF0213', '000019', '19',
  '97 %', 1, 'L', 'Botella de',
  1080.0000, 1.0800, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0213-20', 'IQF0213', '000020', '20',
  '97 %', 1, 'L', 'Botella de',
  1080.0000, 1.0800, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0304-1L', 'IQF0304', NULL, 'IQF0304-1L',
  'absolute', 1, 'L', 'Botella',
  790.0000, 0.7900, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0304-2-5L', 'IQF0304', NULL, 'IQF0304-2-5L',
  'absolute', 2.5, 'L', 'Botella',
  1975.0000, 0.7900, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0308-1L', 'IQF0308', NULL, 'IQF0308-1L',
  NULL, 1, 'L', 'Botella',
  790.0000, 0.7900, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0308-2-5L', 'IQF0308', NULL, 'IQF0308-2-5L',
  NULL, 2.5, 'L', 'Botella',
  1975.0000, 0.7900, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0308-4L', 'IQF0308', NULL, 'IQF0308-4L',
  NULL, 4, 'L', 'Botella',
  3160.0000, 0.7900, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0401-106', 'IQF0401', '000106', '106',
  NULL, 2.5, 'L', 'Botella de',
  1975.0000, 0.7920, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0401-125', 'IQF0401', '000125', '125',
  NULL, 1, 'L', 'Botella de',
  790.0000, 0.7900, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0408-03', 'IQF0408', '000003', '03',
  'min. 99,5 %; etiqueta del importador:', 1, 'L', 'Botella de',
  900.0000, 0.9000, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0408-04', 'IQF0408', '000004', '04',
  '99.5 %', 1, 'L', 'Botella de',
  900.0000, 0.9000, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0501-100', 'IQF0501', '000100', '100',
  'Purity (GC) >= 99.7 %', 1, 'L', 'Botella de',
  710.0000, 0.7100, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0501-33', 'IQF0501', '000033', '33',
  '99.8 %', 1, 'L', 'Botella de',
  710.0000, 0.7100, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0501-90', 'IQF0501', '000090', '90',
  'Purity (GC) >= 99.7 %', 1, 'L', 'Botella de',
  710.0000, 0.7100, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0502-35', 'IQF0502', '000035', '35',
  '99.5 a 99.8 %', 1, 'L', 'Botella de',
  710.0000, 0.7100, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0502-36', 'IQF0502', '000036', '36',
  NULL, 1, 'L', 'Botella de',
  710.0000, 0.7100, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0605-098', 'IQF0605', '000098', '098',
  NULL, 1, 'L', 'Botella de',
  660.0000, 0.6600, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0605-132', 'IQF0605', '000132', '132',
  NULL, 2.5, 'L', 'Botella de',
  1650.0000, 0.6600, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0612-53', 'IQF0612', '000053', '53',
  '99.5 %', 1, 'L', 'Botella de',
  860.0000, 0.8600, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0613-126', 'IQF0613', '000126', '126',
  NULL, 1, 'L', 'Botella de',
  870.0000, 0.8700, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0702-105', 'IQF0702', '000105', '105',
  '28.0 - 30.0 %', 2.5, 'L', 'Botella de',
  2250.0000, 0.9000, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0702-94', 'IQF0702', '000094', '94',
  '28.0 % - 30.0 %', 2.5, 'L', 'Botella de',
  2250.0000, 0.9000, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0708-119', 'IQF0708', '000119', '119',
  NULL, 1, 'kg', 'Botella Frasco de',
  1000.0000, NULL, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF0904-54', 'IQF0904', '000054', '54',
  NULL, 1, 'kg', 'Botella Envase de',
  1000.0000, NULL, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF1122-114', 'IQF1122', '000114', '114',
  NULL, 1, 'kg', 'Botella Envase de',
  1000.0000, NULL, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF1122-130', 'IQF1122', '000130', '130',
  NULL, 1, 'kg', 'Botella Envase de',
  1000.0000, NULL, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF1122-133', 'IQF1122', '000133', '133',
  NULL, 0.5, 'kg', 'Botella Envase de',
  500.0000, NULL, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF1122-95', 'IQF1122', '000095', '95',
  NULL, 1, 'kg', 'Botella Envase de',
  1000.0000, NULL, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,
  equivalencia_g, densidad, vigencia_desde, estado)
VALUES ('IQF1123-27', 'IQF1123', '000027', '27',
  '98–100 %', 1, 'kg', 'Botella Envase de',
  1000.0000, NULL, '2026-08-05', 'VIGENTE')
  ON CONFLICT (id_presentacion) DO UPDATE SET
    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,
    equivalencia_g = EXCLUDED.equivalencia_g,
    densidad = EXCLUDED.densidad;

-- ─── densidades versionadas (US-01 · fuente y vigencia) ───────────
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0102-111', 1.1800, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0102-111'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0102-112', 1.1800, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0102-112'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0102-115', 1.1920, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0102-115'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0102-123', 1.1800, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0102-123'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0102-137', 1.1800, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0102-137'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0102-69', 1.1800, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0102-69'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0106-116', 1.3900, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0106-116'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0106-122', 1.4100, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0106-122'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0106-124', 1.3900, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0106-124'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0106-134', 1.3920, 'g/mL', 'Censo fotográfico 2026-08-05', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0106-134'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0108-084', 1.8400, 'g/mL', 'Censo fotográfico 2026-08-05', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0108-084'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0108-104', 1.8400, 'g/mL', 'Censo fotográfico 2026-08-05', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0108-104'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0108-120', 1.8400, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0108-120'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0108-129', 1.8400, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0108-129'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0213-19', 1.0800, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0213-19'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0213-20', 1.0800, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0213-20'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0304-1L', 0.7900, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0304-1L'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0304-2-5L', 0.7900, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0304-2-5L'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0308-1L', 0.7900, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0308-1L'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0308-2-5L', 0.7900, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0308-2-5L'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0308-4L', 0.7900, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0308-4L'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0401-106', 0.7920, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0401-106'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0401-125', 0.7900, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0401-125'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0408-03', 0.9000, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0408-03'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0408-04', 0.9000, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0408-04'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0501-100', 0.7100, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0501-100'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0501-33', 0.7100, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0501-33'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0501-90', 0.7100, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0501-90'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0502-35', 0.7100, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0502-35'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0502-36', 0.7100, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0502-36'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0605-098', 0.6600, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0605-098'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0605-132', 0.6600, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0605-132'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0612-53', 0.8600, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0612-53'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0613-126', 0.8700, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0613-126'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0702-105', 0.9000, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0702-105'
     AND dv.vigencia_desde = '2026-08-05');
INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, vigencia_desde)
SELECT 'IQF0702-94', 0.9000, 'g/mL', 'Etiqueta del fabricante', '2026-08-05'
WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv
   WHERE dv.id_presentacion = 'IQF0702-94'
     AND dv.vigencia_desde = '2026-08-05');

-- ─── lotes ────────────────────────────────────────────────────────
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0102-111', 'Y42C35', 'RA ACS',
  '2019-11-13', '2023-10-09', NULL, 'ACTIVO'
WHERE 'IQF0102-111' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0102-111'
     AND l.numero_lote IS NOT DISTINCT FROM 'Y42C35');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0102-112', 'B44W37', 'RA ACS - REACTIVO BAKER',
  '2021-05-05', '2025-10-29', NULL, 'ACTIVO'
WHERE 'IQF0102-112' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0102-112'
     AND l.numero_lote IS NOT DISTINCT FROM 'B44W37');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0102-115', 'K52385917 015', 'EMSURE, ACS, ISO, Reag. Ph Eur, for',
  '2020-11-25', '2025-03-31', NULL, 'ACTIVO'
WHERE 'IQF0102-115' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0102-115'
     AND l.numero_lote IS NOT DISTINCT FROM 'K52385917 015');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0102-115', 'Z0805717219', 'EMSURE, ACS, ISO, Reag. Ph Eur — for',
  '2022-09-09', '2027-04-30', NULL, 'ACTIVO'
WHERE 'IQF0102-115' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0102-115'
     AND l.numero_lote IS NOT DISTINCT FROM 'Z0805717219');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0102-123', 'C24W37', 'ACS',
  '2022-04-27', '2026-06-08', NULL, 'ACTIVO'
WHERE 'IQF0102-123' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0102-123'
     AND l.numero_lote IS NOT DISTINCT FROM 'C24W37');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0102-123', 'E22W35', 'RA ACS',
  '2022-10-05', '2027-05-31', NULL, 'ACTIVO'
WHERE 'IQF0102-123' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0102-123'
     AND l.numero_lote IS NOT DISTINCT FROM 'E22W35');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0102-137', '4221050', 'Ultrex ACS',
  '2023-03-09', '2024-05-27', NULL, 'ACTIVO'
WHERE 'IQF0102-137' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0102-137'
     AND l.numero_lote IS NOT DISTINCT FROM '4221050');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0102-69', '320544', 'ACS',
  '2023-09-08', NULL, NULL, 'ACTIVO'
WHERE 'IQF0102-69' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0102-69'
     AND l.numero_lote IS NOT DISTINCT FROM '320544');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0106-116', 'K54021656 203', 'EMSURE, Reag. Ph Eur, ISO, for analysis',
  '2022-06-27', '2025-01-31', NULL, 'ACTIVO'
WHERE 'IQF0106-116' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0106-116'
     AND l.numero_lote IS NOT DISTINCT FROM 'K54021656 203');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0106-122', 'C19W37', 'REACTIVO BAKER®',
  '2022-06-08', '2026-05-12', NULL, 'ACTIVO'
WHERE 'IQF0106-122' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0106-122'
     AND l.numero_lote IS NOT DISTINCT FROM 'C19W37');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0106-124', NULL, 'EMSURE, Reag. Ph Eur, ISO, for analysis',
  NULL, '2028-07-31', NULL, 'ACTIVO'
WHERE 'IQF0106-124' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0106-124'
     AND l.numero_lote IS NOT DISTINCT FROM NULL);
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0106-134', 'K54469956 225', 'EMSURE / Reag. Ph Eur, ISO / for',
  '2023-01-24', '2025-06-30', NULL, 'ACTIVO'
WHERE 'IQF0106-134' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0106-134'
     AND l.numero_lote IS NOT DISTINCT FROM 'K54469956 225');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0106-134', 'K54509856227', 'EMSURE, Reag. Ph Eur, ISO, for analysis',
  '2023-03-07', '2025-06-30', NULL, 'ACTIVO'
WHERE 'IQF0106-134' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0106-134'
     AND l.numero_lote IS NOT DISTINCT FROM 'K54509856227');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0108-084', 'Z0998831 520', 'EMSURE ISO - for analysis (p.a.)',
  '2026-03-31', '2030-04-30', NULL, 'ACTIVO'
WHERE 'IQF0108-084' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0108-084'
     AND l.numero_lote IS NOT DISTINCT FROM 'Z0998831 520');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0108-104', 'K53643131 135', NULL,
  '2022-06-22', '2026-07-31', NULL, 'ACTIVO'
WHERE 'IQF0108-104' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0108-104'
     AND l.numero_lote IS NOT DISTINCT FROM 'K53643131 135');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0108-120', 'Z0943031 430', 'EMSURE ISO (for analysis)',
  '2025-01-13', '2029-07-31', NULL, 'ACTIVO'
WHERE 'IQF0108-120' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0108-120'
     AND l.numero_lote IS NOT DISTINCT FROM 'Z0943031 430');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0108-129', '203242', 'ACS',
  '2022-10-06', '2027-01-28', NULL, 'ACTIVO'
WHERE 'IQF0108-129' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0108-129'
     AND l.numero_lote IS NOT DISTINCT FROM '203242');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0213-19', NULL, 'Q.P.',
  '2005-12-31', NULL, NULL, 'ACTIVO'
WHERE 'IQF0213-19' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0213-19'
     AND l.numero_lote IS NOT DISTINCT FROM NULL);
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0213-20', '………...…..…', 'GR / p.a. (zur Analyse)',
  '2005-12-31', NULL, NULL, 'ACTIVO'
WHERE 'IQF0213-20' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0213-20'
     AND l.numero_lote IS NOT DISTINCT FROM '………...…..…');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0304-1L', NULL, 'EMSURE, ACS, ISO, Reag. Ph Eur, for',
  '2024-07-03', '2028-07-31', NULL, 'ACTIVO'
WHERE 'IQF0304-1L' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0304-1L'
     AND l.numero_lote IS NOT DISTINCT FROM NULL);
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0304-1L', 'I1305383', 'EMSURE, ACS, ISO, Reag. Ph Eur, for',
  '2024-07-03', '2028-07-31', NULL, 'ACTIVO'
WHERE 'IQF0304-1L' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0304-1L'
     AND l.numero_lote IS NOT DISTINCT FROM 'I1305383');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0304-2-5L', NULL, 'EMSURE, ACS, ISO, Reag. Ph Eur, for',
  '2024-07-03', '2027-08-31', NULL, 'ACTIVO'
WHERE 'IQF0304-2-5L' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0304-2-5L'
     AND l.numero_lote IS NOT DISTINCT FROM NULL);
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0304-2-5L', 'I1243083 239', 'EMSURE ACS, ISO, Reag. Ph Eur',
  '2024-06-10', '2027-08-31', NULL, 'ACTIVO'
WHERE 'IQF0304-2-5L' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0304-2-5L'
     AND l.numero_lote IS NOT DISTINCT FROM 'I1243083 239');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0304-2-5L', 'I1316817 401', 'ACS (EMPARTA, for analysis)',
  '2024-08-10', '2028-09-30', NULL, 'ACTIVO'
WHERE 'IQF0304-2-5L' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0304-2-5L'
     AND l.numero_lote IS NOT DISTINCT FROM 'I1316817 401');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0304-2-5L', 'I1366383 433', 'EMSURE, ACS, ISO, Reag. Ph Eur, for',
  NULL, '2029-07-31', NULL, 'ACTIVO'
WHERE 'IQF0304-2-5L' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0304-2-5L'
     AND l.numero_lote IS NOT DISTINCT FROM 'I1366383 433');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0308-1L', NULL, 'EMSURE, ACS, ISO, Reag. Ph Eur, for',
  '2024-12-12', '2028-05-31', NULL, 'ACTIVO'
WHERE 'IQF0308-1L' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0308-1L'
     AND l.numero_lote IS NOT DISTINCT FROM NULL);
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0308-2-5L', NULL, 'EMSURE, ACS, ISO, Reag. Ph Eur, for',
  '2024-12-12', '2029-08-31', NULL, 'ACTIVO'
WHERE 'IQF0308-2-5L' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0308-2-5L'
     AND l.numero_lote IS NOT DISTINCT FROM NULL);
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0308-4L', NULL, NULL,
  '2024-12-12', NULL, NULL, 'ACTIVO'
WHERE 'IQF0308-4L' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0308-4L'
     AND l.numero_lote IS NOT DISTINCT FROM NULL);
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0401-106', 'K50364114 827', 'EMSURE, ACS, ISO, Reag. Ph Eur, for',
  '2019-02-12', '2023-06-30', NULL, 'ACTIVO'
WHERE 'IQF0401-106' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0401-106'
     AND l.numero_lote IS NOT DISTINCT FROM 'K50364114 827');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0401-125', 'I1265114 304', 'EMSURE, ACS, ISO, Reag. Ph Eur, for',
  '2024-04-09', '2027-11-30', NULL, 'ACTIVO'
WHERE 'IQF0401-125' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0401-125'
     AND l.numero_lote IS NOT DISTINCT FROM 'I1265114 304');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0401-125', 'K52802314 138', 'EMSURE, ACS, ISO, Reag. Ph Eur, for',
  '2022-06-22', '2025-09-30', NULL, 'ACTIVO'
WHERE 'IQF0401-125' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0401-125'
     AND l.numero_lote IS NOT DISTINCT FROM 'K52802314 138');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0408-03', '41 K 3495923', 'pro analysi / zur Analyse / GR; ACS',
  '2005-12-31', NULL, NULL, 'ACTIVO'
WHERE 'IQF0408-03' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0408-03'
     AND l.numero_lote IS NOT DISTINCT FROM '41 K 3495923');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0408-04', NULL, 'R.G., Reag. ACS, Reag. ISO, Reag. Ph.',
  '2005-12-31', NULL, NULL, 'ACTIVO'
WHERE 'IQF0408-04' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0408-04'
     AND l.numero_lote IS NOT DISTINCT FROM NULL);
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0408-04', '31820', 'R.G., Reag. ACS, Reag. ISO, Reag. Ph.',
  '2005-12-31', NULL, NULL, 'ACTIVO'
WHERE 'IQF0408-04' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0408-04'
     AND l.numero_lote IS NOT DISTINCT FROM '31820');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0501-100', 'K49626121 748', 'EMSURE, ACS, ISO, Reag. Ph Eur, for',
  '2018-05-09', '2019-11-30', NULL, 'ACTIVO'
WHERE 'IQF0501-100' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0501-100'
     AND l.numero_lote IS NOT DISTINCT FROM 'K49626121 748');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0501-100', 'K51736221 943', 'EMSURE, ACS, ISO, Reag. Ph Eur, for',
  '2020-11-25', '2022-08-31', NULL, 'ACTIVO'
WHERE 'IQF0501-100' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0501-100'
     AND l.numero_lote IS NOT DISTINCT FROM 'K51736221 943');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0501-33', 'H21604', '''BAKER ANALYZED'' A.C.S. Reagent',
  NULL, '1995-05-31', NULL, 'ACTIVO'
WHERE 'IQF0501-33' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0501-33'
     AND l.numero_lote IS NOT DISTINCT FROM 'H21604');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0501-90', 'K48362221 648', 'EMSURE, ACS, ISO, Reag. Ph Eur, for',
  '2017-09-12', '2019-10-31', NULL, 'ACTIVO'
WHERE 'IQF0501-90' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0501-90'
     AND l.numero_lote IS NOT DISTINCT FROM 'K48362221 648');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0502-35', NULL, NULL,
  NULL, NULL, NULL, 'ACTIVO'
WHERE 'IQF0502-35' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0502-35'
     AND l.numero_lote IS NOT DISTINCT FROM NULL);
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0502-36', NULL, 'Q.P.',
  NULL, NULL, NULL, 'ACTIVO'
WHERE 'IQF0502-36' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0502-36'
     AND l.numero_lote IS NOT DISTINCT FROM NULL);
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0605-098', 'K56270474446', 'EMSURE ACS, Reag. Ph Eur (for analysis)',
  NULL, '2029-10-31', NULL, 'ACTIVO'
WHERE 'IQF0605-098' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0605-098'
     AND l.numero_lote IS NOT DISTINCT FROM 'K56270474446');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0605-132', 'I1267271', 'SupraSolv',
  '2024-06-26', '2026-01-31', NULL, 'ACTIVO'
WHERE 'IQF0605-132' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0605-132'
     AND l.numero_lote IS NOT DISTINCT FROM 'I1267271');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0605-132', 'K55965174 421', 'EMSURE, ACS, Reag. Ph Eur, for analysis',
  NULL, '2029-05-31', NULL, 'ACTIVO'
WHERE 'IQF0605-132' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0605-132'
     AND l.numero_lote IS NOT DISTINCT FROM 'K55965174 421');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0605-132', 'K56289467 504', 'EMSURE, ACS, for analysis',
  NULL, '2029-11-30', NULL, 'ACTIVO'
WHERE 'IQF0605-132' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0605-132'
     AND l.numero_lote IS NOT DISTINCT FROM 'K56289467 504');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0612-53', '37312 350853', 'Reactivo analitico',
  NULL, NULL, NULL, 'ACTIVO'
WHERE 'IQF0612-53' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0612-53'
     AND l.numero_lote IS NOT DISTINCT FROM '37312 350853');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0613-126', 'K55699825', 'EMSURE / ACS, ISO, Reag. Ph Eur',
  '2024-07-17', '2029-01-31', NULL, 'ACTIVO'
WHERE 'IQF0613-126' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0613-126'
     AND l.numero_lote IS NOT DISTINCT FROM 'K55699825');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0702-105', '156264', 'ACS; el sobre-rótulo del importador lo',
  '2018-09-19', NULL, NULL, 'ACTIVO'
WHERE 'IQF0702-105' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0702-105'
     AND l.numero_lote IS NOT DISTINCT FROM '156264');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0702-94', '156264', 'REACTIVO BAKER ACS / RA',
  '2017-12-20', '2021-10-04', NULL, 'ACTIVO'
WHERE 'IQF0702-94' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0702-94'
     AND l.numero_lote IS NOT DISTINCT FROM '156264');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0708-119', '-', 'EMSURE',
  '2024-06-26', '2026-04-30', NULL, 'ACTIVO'
WHERE 'IQF0708-119' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0708-119'
     AND l.numero_lote IS NOT DISTINCT FROM '-');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0708-119', 'MB1975398 149', 'EMSURE / pellets for analysis',
  '2022-09-09', '2024-07-31', NULL, 'ACTIVO'
WHERE 'IQF0708-119' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0708-119'
     AND l.numero_lote IS NOT DISTINCT FROM 'MB1975398 149');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0708-119', 'MB2241998 429', 'EMSURE',
  '2025-05-29', '2026-11-30', NULL, 'ACTIVO'
WHERE 'IQF0708-119' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0708-119'
     AND l.numero_lote IS NOT DISTINCT FROM 'MB2241998 429');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF0904-54', '40-6301-016', NULL,
  NULL, NULL, NULL, 'ACTIVO'
WHERE 'IQF0904-54' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF0904-54'
     AND l.numero_lote IS NOT DISTINCT FROM '40-6301-016');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF1122-114', 'A1420492 919', 'PA Cert',
  '2020-11-25', '2024-04-30', NULL, 'ACTIVO'
WHERE 'IQF1122-114' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF1122-114'
     AND l.numero_lote IS NOT DISTINCT FROM 'A1420492 919');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF1122-130', '14403', 'PA Cert',
  '2022-10-06', NULL, NULL, 'ACTIVO'
WHERE 'IQF1122-130' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF1122-130'
     AND l.numero_lote IS NOT DISTINCT FROM '14403');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF1122-133', 'A1655992236', 'EMSURE ISO',
  '2023-01-10', NULL, NULL, 'ACTIVO'
WHERE 'IQF1122-133' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF1122-133'
     AND l.numero_lote IS NOT DISTINCT FROM 'A1655992236');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF1122-95', 'A1218292 741', 'EMSURE ISO',
  '2018-03-20', NULL, NULL, 'ACTIVO'
WHERE 'IQF1122-95' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF1122-95'
     AND l.numero_lote IS NOT DISTINCT FROM 'A1218292 741');
INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,
  fecha_ingreso, fecha_caducidad, densidad, estado)
SELECT 'IQF1123-27', '………………', NULL,
  '1998-03-27', NULL, NULL, 'ACTIVO'
WHERE 'IQF1123-27' IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM lote l
   WHERE l.id_presentacion = 'IQF1123-27'
     AND l.numero_lote IS NOT DISTINCT FROM '………………');

-- ─── frascos ──────────────────────────────────────────────────────
-- peso_neto_actual_g entra en 0 y lo sube el movimiento de censo_inicial:
-- el saldo solo lo escribe el trigger del kardex (fn_frasco_guardia).
-- fila 8 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0102-111-98', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N3'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'aproximada — sin adhesivo: se conoce la balda, no la posición dentro de ella', 2024.1800, 1280.8000, 743.3800, 0,
  629.9831, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6.2026 IQBF LÍQUIDOS.xlsx, hoja HCl fila 257: 1280.80 g, dif -0.00 g)', '2026-07-21 17:17:25', NULL,
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Dañado. Tara 1280.80 g (Tara del censo referencial). ATENCION: la carpeta de evidencias IQF0102-111-98 contiene fotografias de DOS frascos fisicamente distintos de acido clorhidrico J.T.Baker 2.5 L del mismo lote Y42C35. Condición del envase sin resolver: la fotografía no la fija y sin tara no hay % de llenado con que deducirla. El libro traía «Dañado», deducido de un texto descriptivo, no de evidencia.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0102-111'
   AND l.numero_lote IS NOT DISTINCT FROM 'Y42C35'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 9 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0102-115-99', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N3-P90'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1795.8600, 1279.3000, 516.5600, 0,
  433.3557, 'Etiqueta interna / evidencia fotográfica', '2026-07-21 17:17:27', 'A la mitad',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: A la mitad. Bruto 1795.86 g. Tara 1284.30 g (Etiqueta interna / evidencia fotográfica). Neto físico 511.56 g. PRIMER FRASCO DE ORIGEN AUSTRIACO de la serie.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0102-115'
   AND l.numero_lote IS NOT DISTINCT FROM 'K52385917 015'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 10 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0102-112-100', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N3-P76'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 4183.5500, 1232.2000, 2951.3500, 0,
  2501.1441, 'Etiqueta interna / evidencia fotográfica', '2026-07-21 16:13:29', 'Sellado',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Sellado. Bruto 4183.55 g. Tara 1232.20 g (Etiqueta interna / evidencia fotográfica). Neto físico 2951.35 g. SEGUNDA EVIDENCIA DE TRAZABILIDAD LOGISTICA.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0102-112'
   AND l.numero_lote IS NOT DISTINCT FROM 'B44W37'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 11 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0102-112-101', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N3-P77'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 4189.3200, 1237.1000, 2952.2200, 0,
  2501.8814, 'Etiqueta interna / evidencia fotográfica', '2026-07-21 16:38:14', 'Sellado',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Sellado. Bruto 4189.32 g. Tara 1237.13 g (Etiqueta interna / evidencia fotográfica). Neto físico 2952.19 g. Frasco de acido clorhidrico J.T.Baker 2.5 L, lote B44W37, fabricado 2020/10/29 y con caducidad impresa 2025/10/29.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0102-112'
   AND l.numero_lote IS NOT DISTINCT FROM 'B44W37'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 15 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0102-115-105', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Ing. Civil'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N3-P91'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Ingeniería Civil'),
  'exacta — por adhesivo naranja', 3720.0300, 1245.6000, 2474.4300, 0,
  2075.8641, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6.2026 IQBF LÍQUIDOS.xlsx, hoja HCl fila 478: 1245.60 g, dif -0.00 g)', '2026-07-21 17:17:17', 'Abierto',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Abierto. Bruto 3720.03 g. Tara 1245.60 g (Tara del censo referencial). Neto físico 2474.43 g. Frasco Supelco/Merck EMSURE de ácido clorhídrico fumante 37% para análisis, cat.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0102-115'
   AND l.numero_lote IS NOT DISTINCT FROM 'Z0805717219'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 16 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0102-123-106', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N3-P79'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 4223.0300, 1269.9000, 2953.1300, 0,
  2502.6525, 'Etiqueta interna / evidencia fotográfica', '2026-07-24 11:41:53', 'Sellado',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Sellado. Bruto 4223.03 g. Tara 1269.91 g (Etiqueta interna / evidencia fotográfica). Neto físico 2953.12 g. Frasco con etiqueta blanca del laboratorio ''CHASQUIBOL / IQF 0102-123-106'' pegada en el hombro y cubierta con film.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0102-123'
   AND l.numero_lote IS NOT DISTINCT FROM 'E22W35'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 17 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0102-123-107', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N3-P78'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 4154.0100, 1201.1000, 2952.9100, 0,
  2502.4661, 'Etiqueta interna / evidencia fotográfica', '2026-07-21 16:01:31', 'Sellado',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Sellado. Bruto 4154.01 g. Tara 1201.08 g (Etiqueta interna / evidencia fotográfica). Neto físico 2952.93 g. PRIMER FRASCO CON TRAZABILIDAD LOGISTICA COMPLETA.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0102-123'
   AND l.numero_lote IS NOT DISTINCT FROM 'E22W35'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 18 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0102-137-108', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Juan Carlos Yacono'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N3'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Ingeniería Civil'),
  'aproximada — sin adhesivo: se conoce la balda, no la posición dentro de ella', 621.8200, 94.1000, 527.7200, 0,
  447.2203, 'Etiqueta interna / evidencia fotográfica', '2026-07-22 18:39:21', 'Abierto',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Abierto. Bruto 621.82 g. Tara 94.10 g (Etiqueta interna / evidencia fotográfica). Neto físico 527.72 g. Frasco gemelo del IQF0102-137-109: mismo producto Ultrex 32-35 %, mismo lote 4221050, misma fecha de ingreso y mismo vencimiento.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0102-137'
   AND l.numero_lote IS NOT DISTINCT FROM '4221050'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 19 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0102-137-109', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Juan Carlos Yacono'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N3'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Ingeniería Civil'),
  'aproximada — sin adhesivo: se conoce la balda, no la posición dentro de ella', 683.3700, 91.6000, 591.7700, 0,
  501.5000, 'Etiqueta interna / evidencia fotográfica', '2026-07-22 18:39:18', 'Abierto',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Sellado. Bruto 683.37 g. Tara 91.60 g (Etiqueta interna / evidencia fotográfica). Neto físico 591.77 g. La etiqueta interna roja declara PESO TOTAL 681.62 g.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0102-137'
   AND l.numero_lote IS NOT DISTINCT FROM '4221050'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 20 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0102-69-110', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N3-P85'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 4137.6900, 1186.4000, 2951.2900, 0,
  2501.0932, 'Etiqueta interna / evidencia fotográfica', '2026-07-22 18:39:32', 'Sellado',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: Sellado. Bruto 4137.69 g. Tara 1186.43 g (Etiqueta interna / evidencia fotográfica). Neto físico 2951.26 g. Frasco Fermont de 2.5 L de ácido clorhídrico ACS, con asa. Acción histórica Baja-residuo conservada; sugerida: Mantener. Sin fecha de caducidad legible: la acción «Baja-residuo» viene del censo, no de la evidencia.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0102-69'
   AND l.numero_lote IS NOT DISTINCT FROM '320544'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 21 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0102-69-111', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N3-P82'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 4140.7400, 1189.7000, 2951.0400, 0,
  2500.8814, 'Etiqueta interna / evidencia fotográfica', '2026-07-24 11:53:24', 'Sellado',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: Sellado. Bruto 4140.74 g. Tara 1189.72 g (Etiqueta interna / evidencia fotográfica). Neto físico 2951.02 g. EL FRASCO QUE MEJOR CUADRA CON EL CENSO DE TODA LA SERIE. Acción sin decidir: no hay fecha de caducidad legible —ni en el censo ni en la etiqueta— y la condición del envase no basta por sí sola para clasificarlo. El censo traía «NO SE SABE».'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0102-69'
   AND l.numero_lote IS NOT DISTINCT FROM '320544'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 22 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0102-69-112', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N3-P80'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 4142.3600, 1191.2000, 2951.1600, 0,
  2500.9831, 'Etiqueta interna / evidencia fotográfica', '2026-07-24 11:46:46', 'Sellado',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: Sellado. Bruto 4142.36 g. Tara 1191.21 g (Etiqueta interna / evidencia fotográfica). Neto físico 2951.15 g. Frasco Fermont ''PA Cert'' de Acido Clorhidrico ACS, 2.5 L, catalogo 01245, lote 320544. Acción sin decidir: no hay fecha de caducidad legible —ni en el censo ni en la etiqueta— y la condición del envase no basta por sí sola para clasificarlo. El censo traía «NO SE SABE».'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0102-69'
   AND l.numero_lote IS NOT DISTINCT FROM '320544'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 23 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0102-69-113', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Quino'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N3-P84'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 3796.5000, 1199.3000, 2597.2000, 0,
  2201.0169, 'Etiqueta interna / evidencia fotográfica', '2026-07-21 16:05:13', 'Abierto',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: Sellado. Bruto 3796.50 g. Tara 1199.30 g (Etiqueta interna / evidencia fotográfica). Neto físico 2597.20 g. FORMATO DE STICKER DISTINTO: aqui el codigo lleva guion tras las siglas, "IQF-0102-69-113", y el custodio se escribe con el prefijo INV. Sin fecha de caducidad legible: la acción «Mantener» viene del censo, no de la evidencia.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0102-69'
   AND l.numero_lote IS NOT DISTINCT FROM '320544'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 24 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0102-69-114', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Quino'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N3-P81'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 3499.7900, 1188.8000, 2310.9900, 0,
  1958.4661, 'Etiqueta interna / evidencia fotográfica', '2026-07-21 17:17:20', 'A la mitad',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: A la mitad. Bruto 3499.79 g. Tara 1188.80 g (Etiqueta interna / evidencia fotográfica). Neto físico 2310.99 g. FORMATO DE STICKER DISTINTO: aqui el codigo lleva guion tras las siglas, "IQF-0102-69-114", y el custodio se escribe con el prefijo INV. Sin fecha de caducidad legible: la acción «Mantener» viene del censo, no de la evidencia.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0102-69'
   AND l.numero_lote IS NOT DISTINCT FROM '320544'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 31 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0102-69-116', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N3'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'aproximada — sin adhesivo: se conoce la balda, no la posición dentro de ella', 1218.9900, 1200.2000, 18.7900, 0,
  15.9237, 'Etiqueta interna / evidencia fotográfica', '2026-07-21 16:20:40', 'Agotado',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. DEPURADO: este frasco figuraba en 6 filas por mismo código interno; se conservó esta y se borraron las otras 5. Ninguna de las borradas tenía pesaje propio. Evidencia fotográfica conciliada: Agotado. Bruto 1218.98 g. Tara 1200.21 g (Etiqueta interna / evidencia fotográfica). Neto físico 18.77 g. FRASCO PRACTICAMENTE VACIO. Acción histórica Mantener conservada; sugerida: Baja-residuo.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0102-69'
   AND l.numero_lote IS NOT DISTINCT FROM '320544'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 36 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0106-122-23', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Sanabria'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N2-P71'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 4392.4700, 1160.9000, 3231.5700, 0,
  2291.8936, 'Etiqueta interna / evidencia fotográfica', '2026-07-21 15:41:39', 'Abierto',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Abierto. Bruto 4392.47 g. Tara 1160.92 g (Etiqueta interna / evidencia fotográfica). Neto físico 3231.55 g. Etiqueta del fabricante también indica FECHA DE MANUFACTURA 2021/05/12, Gravedad Específica a 60/60 °F Mín.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0106-122'
   AND l.numero_lote IS NOT DISTINCT FROM 'C19W37'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 37 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0106-122-24', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Sanabria'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N2-P72'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 4595.6700, 1068.7000, 3526.9700, 0,
  2501.3972, 'Etiqueta interna / evidencia fotográfica', '2026-07-21 15:33:31', 'Sellado',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Sellado. Bruto 4595.67 g. Tara 1068.68 g (Etiqueta interna / evidencia fotográfica). Neto físico 3526.99 g. Frasco de ácido nítrico 64.5-66.5 % J.T.Baker / Avantor, catálogo 9621-05, 2.5 L.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0106-122'
   AND l.numero_lote IS NOT DISTINCT FROM 'C19W37'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 38 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0106-116-25', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Académico'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N2-P67'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 713.5300, 675.1000, 38.4300, 0,
  27.6475, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6.2026 IQBF LÍQUIDOS.xlsx, hoja HNO3 fila 189: 675.12 g, dif -0.02 g)', '2026-07-21 14:40:20', NULL,
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Dañado. Tara 675.10 g (Tara del censo referencial). El frasco de esta carpeta es Ácido nítrico 65% EMSURE (Merck/Supelco), cat. Condición del envase sin resolver: la fotografía no la fija y sin tara no hay % de llenado con que deducirla. El libro traía «Dañado», deducido de un texto descriptivo, no de evidencia.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0106-116'
   AND l.numero_lote IS NOT DISTINCT FROM 'K54021656 203'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 39 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0106-134-26', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Académico'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N2-P69'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 4422.1100, 1251.2000, 3170.9100, 0,
  2277.9526, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6.2026 IQBF LÍQUIDOS.xlsx, hoja HNO3 fila 220: 1251.20 g, dif +0.00 g)', '2026-07-21 15:03:37', NULL,
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Residuo. Tara 1251.20 g (Tara del censo referencial). Frasco fotografiado en mano (sostenido con guante de nitrilo), nunca sobre la balanza. Condición del envase sin resolver: la fotografía no la fija y sin tara no hay % de llenado con que deducirla. El libro traía «Residuo», deducido de un texto descriptivo, no de evidencia.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0106-134'
   AND l.numero_lote IS NOT DISTINCT FROM 'K54469956 225'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 40 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0106-134-27', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Ing. Civil'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N2-P68'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Ingeniería Civil'),
  'exacta — por adhesivo naranja', 3351.6900, 1263.5000, 2088.1900, 0,
  1500.1365, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6.2026 IQBF LÍQUIDOS.xlsx, hoja HNO3 fila 252: 1263.52 g, dif -0.02 g)', '2026-07-21 15:26:46', 'A la mitad',
  TRUE, 'EN_USO', 'CADUCIDAD RESUELTA (criterio del laboratorio, 2026-08-06): la fecha válida es 30/06/2025, la que imprime el fabricante (Supelco/Merck) en la etiqueta oficial del frasco, y es la que ya tenía el censo. La etiqueta interna del laboratorio declara 30/06/2023: no es una etiqueta oficial, la rotuló alguien y la rotuló mal. Se descarta ese 2023 y hay que corregir el rótulo interno del frasco. Con la fecha válida el producto sigue VENCIDO al 05-08-2026, así que la disposición no cambia. Evidencia fotográfica conciliada: A la mitad. Bruto 3551.69 g. Tara 1263.50 g (Tara del censo referencial). Neto físico 2288.19 g. Frasco de acido nitrico 65% Supelco/Merck, cat.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0106-134'
   AND l.numero_lote IS NOT DISTINCT FROM 'K54509856227'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 47 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0108-104-27', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Académico'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N2'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'aproximada — sin adhesivo: se conoce la balda, no la posición dentro de ella', 717.9800, 683.4000, 34.5800, 0,
  18.7935, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6.2026 IQBF LÍQUIDOS.xlsx, hoja H2SO4 fila 118: 683.36 g, dif +0.04 g)', '2026-07-21 00:00:00', NULL,
  TRUE, 'EN_USO', 'DEPURADO: este frasco figuraba en 2 filas por misma carpeta de evidencia «IQF0108-104-27»; se conservó esta y se borraron las otras 1. Ninguna de las borradas tenía pesaje propio. Bruto 717.98 g − tara 683.40 g = neto 34.58 g. La tara no se ve en ninguna foto: se tomó la del censo, el neto queda por confirmar. La etiqueta física dice «IQF-0108-104». Datos de etiqueta no registrados antes: marca Merck KGaA (marca Supelco; Merck KGaA, 64271 Darmstadt / EMD Millipore Corporation, sigmaaldrich.com), catálogo 1.00731.1000, CAS 7664-93-9. Alertas: FALTA LA FOTO DE LA BALANZA. Sin ella no se puede registrar peso_bruto_balanza_g ni ejecutar la aritmética de control. Repetir el pesaje y fotografiar el display (verificando Tara = 0.00 g). | FALTA LA FOTO DE LA FICHA INTERNA MANUSCRITA (o el frasco no la lleva). Sin ella no hay tara, ni fechas de ingreso/apertura/vencimiento, ni densidad declarada, ni profesor responsable. Verificar si existe en la cara no fotografiada y, si existe, fotografiarla; si no existe, rotular el frasco. | CÓDIGO INTERNO INCOMPLETO: solo se lee ''IQF-0108-104''; el sufijo final está ilegible bajo la cinta adhesiva. Repetir la foto del código sin reflejos antes de dar el frasco por identificado.. REPETIR FOTO: codigo_interno_leido: el tramo final del código, después de ''IQF-0108-104'', está tapado por los reflejos y arrugas de la cinta adhesiva transparente (foto 02); ilegible incluso ampliando a resolución original. SE REQUIERE REPETIR LA FOTO del código interno., condicion_envase: no decidible con la evidencia disponible. El vidrio oscuro impide ver el nivel de llenado en las tres fotos, no hay lectura de balanza ni tara, y la banda inviolable de la tapa se ve pero no se distingue con certeza si está íntegra o cortada. SE REQUIERE FOTO DE BALANZA y una toma nítida de la banda de la tapa., Texto vertical pequeño en el borde izquierdo de la etiqueta frontal (fotos 01 y 03, junto a ''1.00731.1000''): posible código impreso del fabricante; ilegible a resolución original por el curvado de la etiqueta.. Evidencia: carpeta IQF0108-104-27, 3 fotos leídas.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0108-104'
   AND l.numero_lote IS NOT DISTINCT FROM 'K53643131 135'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 48 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0108-129-28', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N2-P62'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1518.4800, 1212.3000, 306.1800, 0,
  166.4022, 'Etiqueta interna / evidencia fotográfica', '2026-07-21 15:13:49', 'Agotado',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Agotado. Bruto 1519.48 g. Tara 1040.00 g (Etiqueta interna / evidencia fotográfica). Neto físico 479.48 g. Frasco de Acido Sulfurico ACS Fermont, cat. Acción histórica Mantener conservada; sugerida: Baja-residuo.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0108-129'
   AND l.numero_lote IS NOT DISTINCT FROM '203242'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 49 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0108-129-29', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N2-P64'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 5791.9800, 1190.5000, 4601.4800, 0,
  2500.8043, 'Etiqueta interna / evidencia fotográfica', '2026-07-21 16:09:31', 'Sellado',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Sellado. Bruto 5791.98 g. Tara 1190.54 g (Etiqueta interna / evidencia fotográfica). Neto físico 4601.44 g. Frasco de acido sulfurico ACS Fermont de 2.5 L, etiqueta de fabrica completa (frente + resultado de analisis del lote 203242) y etiqueta de importador peruano pegada al costado.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0108-129'
   AND l.numero_lote IS NOT DISTINCT FROM '203242'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 50 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0108-129-30', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N2-P63'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 5795.7800, 1194.3000, 4601.4800, 0,
  2500.8043, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6.2026 IQBF LÍQUIDOS.xlsx, hoja H2SO4 fila 233: 1194.29 g, dif +0.01 g)', '2026-07-21 14:32:38', NULL,
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Dañado. Tara 1194.30 g (Tara del censo referencial). Carpeta con solo 3 fotos, todas del cuerpo del frasco: no hay foto del display de la balanza ni foto de ficha manuscrita interna, y tampoco se ve ninguna ficha manuscrita pegada al frasco en las tomas disponibles. Acción histórica Mantener conservada; sugerida: Reasignar. Condición del envase sin resolver: la fotografía no la fija y sin tara no hay % de llenado con que deducirla. El libro traía «Dañado», deducido de un texto descriptivo, no de evidencia.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0108-129'
   AND l.numero_lote IS NOT DISTINCT FROM '203242'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 54 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0108-120-34', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Quino'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N2-P66'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'FAUGRO Microbiología'),
  'exacta — por adhesivo naranja', 5646.3300, 1252.4000, 4393.9300, 0,
  2388.0054, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6.2026 IQBF LÍQUIDOS.xlsx, hoja H2SO4 fila 370: 1252.41 g, dif -0.01 g)', '2026-07-21 15:30:30', 'Abierto',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Abierto. Bruto 5646.33 g. Tara 1252.40 g (Tara del censo referencial). Neto físico 4393.93 g. El frasco NO lleva la ficha interna manuscrita del laboratorio (no aparece en ninguna de las 6 fotos, incluida la cara posterior 04__IMG_1260.jpg): por eso quedan sin dato la tara (PESO FRASCO), el PESO TOTAL de rotulado, la FECHA DE INGRESO y la FECHA DE APE…'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0108-120'
   AND l.numero_lote IS NOT DISTINCT FROM 'Z0943031 430'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 55 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0108-120-35', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N2'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'aproximada — sin adhesivo: se conoce la balda, no la posición dentro de ella', 3004.9200, 1322.3000, 1682.6200, 0,
  914.4674, 'Etiqueta interna / evidencia fotográfica', '2026-07-21 15:24:18', 'A la mitad',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: A la mitad. Bruto 3004.92 g. Tara 1322.30 g (Etiqueta interna / evidencia fotográfica). Neto físico 1682.62 g. PRIMER FRASCO DE ORIGEN BELGA de toda la serie.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0108-120'
   AND l.numero_lote IS NOT DISTINCT FROM 'Z0943031 430'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 56 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0108-120-36', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N2'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'aproximada — sin adhesivo: se conoce la balda, no la posición dentro de ella', 5908.5000, 1307.8000, 4600.7000, 0,
  2500.3804, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6.2026 IQBF LÍQUIDOS.xlsx, hoja H2SO4 fila 419: 1307.76 g, dif +0.04 g)', '2026-07-21 14:30:15', 'Sellado',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Sellado. Tara 1307.80 g (Tara del censo referencial). Solo hay 3 fotos y las tres son de la misma cara del frasco sostenido en la mano: NO hay foto de la balanza y NO hay ficha interna manuscrita del laboratorio en ninguna toma, por lo que todo el bloque de pesaje y el bloque de etiqueta interna del laboratorio …'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0108-120'
   AND l.numero_lote IS NOT DISTINCT FROM 'Z0943031 430'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 57 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0108-084-37', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Ing. Civil'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N2'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Ingeniería Civil'),
  'aproximada — sin adhesivo: se conoce la balda, no la posición dentro de ella', 2511.8700, 671.7000, 1840.1700, 0,
  1000.0924, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6.2026 IQBF LÍQUIDOS.xlsx, hoja H2SO4 fila 443: 671.70 g, dif +0.00 g)', '2026-07-21 14:44:08', NULL,
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Dañado. Tara 671.70 g (Tara del censo referencial). Carpeta con solo 3 fotografias, todas del frasco sostenido en la mano: 01 y 02 muestran la cara frontal de la etiqueta desde dos angulos y 03 la cara posterior con el texto de peligros multiidioma. Acción histórica Mantener conservada; sugerida: Reasignar. Condición del envase sin resolver: la fotografía no la fija y sin tara no hay % de llenado con que deducirla. El libro traía «Dañado», deducido de un texto descriptivo, no de evidencia.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0108-084'
   AND l.numero_lote IS NOT DISTINCT FROM 'Z0998831 520'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 64 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0605-132-34', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'H. Villagarcía'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N4-P46'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 2798.4000, 1537.8000, 1260.6000, 0,
  1910.0000, 'Etiqueta interna / evidencia fotográfica', '2026-07-24 12:43:48', 'A la mitad',
  TRUE, 'EN_USO', 'LETRERO DE PUERTA MAL ROTULADO: la etiqueta de la puerta que lista las posiciones 39–48 dice «NIVEL 3», pero los marcadores del propio estante dicen NIVEL 4 (el NIVEL 3 es la balda de encima, la del clorhídrico) y el laboratorio lo confirma. Este frasco está en el NIVEL 4. Hay que reimprimir ese letrero de puerta: quien busque por él irá al estante equivocado. Evidencia fotográfica conciliada: A la mitad. Bruto 2798.40 g. Tara 1537.84 g (Etiqueta interna / evidencia fotográfica). Neto físico 1260.56 g. Frasco de 2.5 L de n-Hexano SupraSolv (Supelco/Merck) sobre la balanza RADWAG con Tara 0.00 g.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0605-132'
   AND l.numero_lote IS NOT DISTINCT FROM 'I1267271'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 69 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0605-132-39', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Académico'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N4-P45'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1997.5900, 1259.6000, 737.9900, 0,
  1118.1667, 'Etiqueta interna / evidencia fotográfica', '2026-07-24 12:46:28', 'A la mitad',
  TRUE, 'EN_USO', 'LETRERO DE PUERTA MAL ROTULADO: la etiqueta de la puerta que lista las posiciones 39–48 dice «NIVEL 3», pero los marcadores del propio estante dicen NIVEL 4 (el NIVEL 3 es la balda de encima, la del clorhídrico) y el laboratorio lo confirma. Este frasco está en el NIVEL 4. Hay que reimprimir ese letrero de puerta: quien busque por él irá al estante equivocado. DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de ingreso. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: A la mitad. Bruto 1997.59 g. Tara 1259.60 g (Etiqueta interna / evidencia fotográfica). Neto físico 737.99 g. PRODUCTO DISTINTO AL DE SUS DOS HERMANOS DE CODIGO.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0605-132'
   AND l.numero_lote IS NOT DISTINCT FROM 'K56289467 504'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 70 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0605-132-40', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Alimentos'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N4'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'aproximada — sin adhesivo: se conoce la balda, no la posición dentro de ella', 2903.4000, 1253.5000, 1649.9000, 0,
  2499.8485, 'Etiqueta interna / evidencia fotográfica', '2026-07-24 11:56:57', 'Sellado',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de ingreso. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: Sellado. Bruto 2903.40 g. Tara 1253.50 g (Etiqueta interna / evidencia fotográfica). Neto físico 1649.90 g. FRASCO GEMELO DEL IQF0605-132-41: mismo lote K55965174 421, mismo catalogo 1.04374.2500, mismo vencimiento 2029/05/31, mismo custodio LAB ALIMENTOS.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0605-132'
   AND l.numero_lote IS NOT DISTINCT FROM 'K55965174 421'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 71 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0605-132-41', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Alimentos'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N4'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'aproximada — sin adhesivo: se conoce la balda, no la posición dentro de ella', 2904.3900, 1253.5000, 1650.8900, 0,
  2501.3485, 'Etiqueta interna / evidencia fotográfica', '2026-07-24 12:12:15', 'Sellado',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de ingreso. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: Abierto. Bruto 2904.39 g. Tara 1253.50 g (Etiqueta interna / evidencia fotográfica). Neto físico 1650.89 g. FRASCO GEMELO DEL IQF0605-132-40: mismo lote K55965174 421, mismo catalogo, mismo vencimiento y mismo custodio.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0605-132'
   AND l.numero_lote IS NOT DISTINCT FROM 'K55965174 421'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 73 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0605-098-43', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Alimentos'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N4'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Laboratorio de Alimentos'),
  'aproximada — sin adhesivo: se conoce la balda, no la posición dentro de ella', 1342.6800, 680.1000, 662.5800, 0,
  1003.9091, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6.2026 IQBF LÍQUIDOS.xlsx, hoja HEXANO fila 421: 680.08 g, dif +0.02 g)', '2026-07-24 00:00:00', 'Sellado',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de ingreso. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: Sellado. Bruto 1342.68 g. Tara 680.10 g (Tara del censo referencial). Neto físico 662.58 g. Frasco de n-Hexano EMSURE de 1 L, marca Merck/Supelco, cat.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0605-098'
   AND l.numero_lote IS NOT DISTINCT FROM 'K56270474446'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 75 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0702-94-08', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Muedas'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N4-P47'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 2914.9100, 1075.0000, 1839.9100, 0,
  2044.3444, 'Etiqueta interna / evidencia fotográfica', '2026-07-24 12:39:37', 'Abierto',
  TRUE, 'EN_USO', 'LETRERO DE PUERTA MAL ROTULADO: la etiqueta de la puerta que lista las posiciones 39–48 dice «NIVEL 3», pero los marcadores del propio estante dicen NIVEL 4 (el NIVEL 3 es la balda de encima, la del clorhídrico) y el laboratorio lo confirma. Este frasco está en el NIVEL 4. Hay que reimprimir ese letrero de puerta: quien busque por él irá al estante equivocado. Evidencia fotográfica conciliada: Sellado. Bruto 2914.91 g. Tara 1075.00 g (Etiqueta interna / evidencia fotográfica). Neto físico 1839.91 g. CUARTO IMPORTADOR DE LA SERIE: MC Laboratorio SAC, RUC 20600877454, Jr.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0702-94'
   AND l.numero_lote IS NOT DISTINCT FROM '156264'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 76 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0702-105-09', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Académico (lab Quimica)'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N4-P48'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Laboratorio de Química'),
  'exacta — por adhesivo naranja', 3324.0400, 1076.0000, 2248.0400, 0,
  2497.8222, 'Etiqueta interna / evidencia fotográfica', '2026-07-24 12:24:42', 'Sellado',
  TRUE, 'EN_USO', 'LETRERO DE PUERTA MAL ROTULADO: la etiqueta de la puerta que lista las posiciones 39–48 dice «NIVEL 3», pero los marcadores del propio estante dicen NIVEL 4 (el NIVEL 3 es la balda de encima, la del clorhídrico) y el laboratorio lo confirma. Este frasco está en el NIVEL 4. Hay que reimprimir ese letrero de puerta: quien busque por él irá al estante equivocado. DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: Sellado. Bruto 3324.04 g. Tara 1076.00 g (Etiqueta interna / evidencia fotográfica). Neto físico 2248.04 g. Frasco J.T.Baker de 2.5 L de hidróxido de amonio 28.0-30.0 % (''Reactivo Baker'' ACS, cat. Acción sin decidir: no hay fecha de caducidad legible —ni en el censo ni en la etiqueta— y la condición del envase no basta por sí sola para clasificarlo.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0702-105'
   AND l.numero_lote IS NOT DISTINCT FROM '156264'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 78 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0401-106-23', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Académico'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N4-P40'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 2326.5200, 1199.4000, 1127.1200, 0,
  1423.1313, 'Etiqueta interna / evidencia fotográfica', '2026-07-24 12:17:19', 'A la mitad',
  TRUE, 'EN_USO', 'LETRERO DE PUERTA MAL ROTULADO: la etiqueta de la puerta que lista las posiciones 39–48 dice «NIVEL 3», pero los marcadores del propio estante dicen NIVEL 4 (el NIVEL 3 es la balda de encima, la del clorhídrico) y el laboratorio lo confirma. Este frasco está en el NIVEL 4. Hay que reimprimir ese letrero de puerta: quien busque por él irá al estante equivocado. Evidencia fotográfica conciliada: A la mitad. Bruto 2326.52 g. Tara 1199.40 g (Etiqueta interna / evidencia fotográfica). Neto físico 1127.12 g. FRASCO VENCIDO CON CONSUMO NO REGISTRADO.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0401-106'
   AND l.numero_lote IS NOT DISTINCT FROM 'K50364114 827'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 79 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0401-125-24', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'La Cruz'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N4-P42'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1416.2200, 627.7000, 788.5200, 0,
  998.1266, 'Etiqueta interna / evidencia fotográfica', '2026-07-24 12:00:49', 'Sellado',
  TRUE, 'EN_USO', 'LETRERO DE PUERTA MAL ROTULADO: la etiqueta de la puerta que lista las posiciones 39–48 dice «NIVEL 3», pero los marcadores del propio estante dicen NIVEL 4 (el NIVEL 3 es la balda de encima, la del clorhídrico) y el laboratorio lo confirma. Este frasco está en el NIVEL 4. Hay que reimprimir ese letrero de puerta: quien busque por él irá al estante equivocado. Evidencia fotográfica conciliada: Sellado. Bruto 1416.22 g. Tara 627.69 g (Etiqueta interna / evidencia fotográfica). Neto físico 788.53 g. TERCER FORMATO DE ETIQUETA INTERNA.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0401-125'
   AND l.numero_lote IS NOT DISTINCT FROM 'K52802314 138'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 80 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0401-125-25', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'H. Villagarcía'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N4-P41'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1466.5400, 674.9000, 791.6400, 0,
  1002.0759, 'Etiqueta interna / evidencia fotográfica', '2026-07-24 12:48:36', 'Sellado',
  TRUE, 'EN_USO', 'LETRERO DE PUERTA MAL ROTULADO: la etiqueta de la puerta que lista las posiciones 39–48 dice «NIVEL 3», pero los marcadores del propio estante dicen NIVEL 4 (el NIVEL 3 es la balda de encima, la del clorhídrico) y el laboratorio lo confirma. Este frasco está en el NIVEL 4. Hay que reimprimir ese letrero de puerta: quien busque por él irá al estante equivocado. Evidencia fotográfica conciliada: Sellado. Bruto 1466.54 g. Tara 674.89 g (Etiqueta interna / evidencia fotográfica). Neto físico 791.65 g. Tercer frasco de acetona de la serie, y el unico intacto.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0401-125'
   AND l.numero_lote IS NOT DISTINCT FROM 'I1265114 304'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 81 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0401-125-26', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'H. Villagarcía'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N4-P43'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1461.0300, 668.3000, 792.7300, 0,
  1003.4557, 'Etiqueta interna / evidencia fotográfica', '2026-07-24 12:56:27', 'Sellado',
  TRUE, 'EN_USO', 'LETRERO DE PUERTA MAL ROTULADO: la etiqueta de la puerta que lista las posiciones 39–48 dice «NIVEL 3», pero los marcadores del propio estante dicen NIVEL 4 (el NIVEL 3 es la balda de encima, la del clorhídrico) y el laboratorio lo confirma. Este frasco está en el NIVEL 4. Hay que reimprimir ese letrero de puerta: quien busque por él irá al estante equivocado. Evidencia fotográfica conciliada: Sellado. Bruto 1461.03 g. Tara 668.33 g (Etiqueta interna / evidencia fotográfica). Neto físico 792.70 g. Frasco de acetona Merck/Supelco EMSURE 1 L, cat.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0401-125'
   AND l.numero_lote IS NOT DISTINCT FROM 'I1265114 304'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 84 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0613-126-02', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Juan Carlos Yacono'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N4-P44'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1378.1100, 665.8000, 712.3100, 0,
  818.7471, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6.2026 IQBF LÍQUIDOS.xlsx, hoja TOLUENO fila 38: 665.80 g, dif +0.00 g)', '2026-07-24 12:21:13', 'Abierto',
  TRUE, 'EN_USO', 'LETRERO DE PUERTA MAL ROTULADO: la etiqueta de la puerta que lista las posiciones 39–48 dice «NIVEL 3», pero los marcadores del propio estante dicen NIVEL 4 (el NIVEL 3 es la balda de encima, la del clorhídrico) y el laboratorio lo confirma. Este frasco está en el NIVEL 4. Hay que reimprimir ese letrero de puerta: quien busque por él irá al estante equivocado. Evidencia fotográfica conciliada: Abierto. Bruto 1378.11 g. Tara 665.80 g (Tara del censo referencial). Neto físico 712.31 g. Frasco Merck EMSURE de tolueno para analisis, 1 L, botella de vidrio ambar.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0613-126'
   AND l.numero_lote IS NOT DISTINCT FROM 'K55699825'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 85 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0501-33-03', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N1-P3'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 488.7300, 111.2000, 377.5300, 0,
  531.7324, 'Etiqueta interna / evidencia fotográfica', '2026-08-03 00:00:00', 'A la mitad',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de ingreso. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. *** PRIORIDAD DE SEGURIDAD *** Éter etílico (dietil éter, CAS 60-29-7) J.T. Baker cat. 9240-22, lote H21604. La etiqueta del fabricante imprime "USE BEFORE: 05/95": mayo de 1995, verificado en foto. Lleva ~31 años pasado de fecha, el envase está abierto y consumido hasta la mitad (neto 377.53 g sobre 1 L nominal), con mucho espacio de aire. La propia etiqueta CIMATEC pegada al frasco advierte que los recipientes con éter no deben almacenarse más de 3 meses. El éter dietílico forma peróxidos explosivos al envejecer en contacto con el aire y la luz, y el riesgo crece al concentrarse el remanente. La bitácora manuscrita del propio frasco registra usos desde los años 90 hasta 2013. NO MOVER NI ABRIR sin evaluación previa de personal cualificado; tratar como el punto más urgente del censo, por delante de cualquier trámite documental. (La fecha se registró como 1995-05-31 por convención de fin de mes: la etiqueta solo imprime mes y año, el día no aparece.) Evidencia fotográfica conciliada: A la mitad. Bruto 488.73 g. Tara 111.20 g (Etiqueta interna / evidencia fotográfica). Neto físico 377.53 g. Frasco de eter etilico (dietil eter) J.T.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0501-33'
   AND l.numero_lote IS NOT DISTINCT FROM 'H21604'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 86 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0501-90-06', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N1-P4'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1406.5500, 698.0000, 708.5500, 0,
  997.9577, 'Etiqueta interna / evidencia fotográfica', '2026-08-03 00:00:00', 'Sellado',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Sellado. Bruto 1406.55 g. Tara 698.00 g (Etiqueta interna / evidencia fotográfica). Neto físico 708.55 g. ATENCION: la etiqueta advierte de forma expresa ''May form explosive peroxides'' / ''Puede formar peroxidos explosivos''.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0501-90'
   AND l.numero_lote IS NOT DISTINCT FROM 'K48362221 648'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 87 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0501-100-07', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N1-P5'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1355.0400, 648.8000, 706.2400, 0,
  994.7042, 'Etiqueta interna / evidencia fotográfica', '2026-08-03 00:00:00', 'Sellado',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Sellado. Bruto 1355.04 g. Tara 648.80 g (Etiqueta interna / evidencia fotográfica). Neto físico 706.24 g. TERCER ETER DIETILICO DE LA SERIE.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0501-100'
   AND l.numero_lote IS NOT DISTINCT FROM 'K49626121 748'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 88 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0501-100-08', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N1-P6'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1336.9600, 628.3000, 708.6600, 0,
  998.1127, 'Etiqueta interna / evidencia fotográfica', '2026-08-03 00:00:00', 'Sellado',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Sellado. Bruto 1336.96 g. Tara 628.32 g (Etiqueta interna / evidencia fotográfica). Neto físico 708.64 g. TERCER ETER DIETILICO VENCIDO DEL LABORATORIO, junto a IQF0501-90-06 y IQF0501-100-07.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0501-100'
   AND l.numero_lote IS NOT DISTINCT FROM 'K51736221 943'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 89 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0502-35-01', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N1-P8'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 709.4100, 453.0000, 256.4100, 0,
  361.1408, 'Etiqueta interna / evidencia fotográfica', '2026-08-03 00:00:00', 'A la mitad',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento, fecha de ingreso. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: A la mitad. Bruto 709.41 g. Tara 453.50 g (Etiqueta interna / evidencia fotográfica). Neto físico 255.91 g. Frasco muy antiguo con historial de uso registrado a mano desde 1999. Acción sin decidir: no hay fecha de caducidad legible —ni en el censo ni en la etiqueta— y la condición del envase no basta por sí sola para clasificarlo.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0502-35'
   AND l.numero_lote IS NOT DISTINCT FROM NULL
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 90 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0502-36-02', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N1-P7'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1026.5500, 499.1000, 527.4500, 0,
  742.8873, 'Etiqueta interna / evidencia fotográfica', '2026-08-03 00:00:00', 'A la mitad',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento, fecha de ingreso. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: A la mitad. Bruto 1026.55 g. Tara 500.30 g (Etiqueta interna / evidencia fotográfica). Neto físico 526.25 g. Frasco antiguo del stock histórico del laboratorio. Acción sin decidir: no hay fecha de caducidad legible —ni en el censo ni en la etiqueta— y la condición del envase no basta por sí sola para clasificarlo.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0502-36'
   AND l.numero_lote IS NOT DISTINCT FROM NULL
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 91 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0612-53-03', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N1-P9'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1122.4400, 620.9000, 501.5400, 0,
  583.1860, 'Etiqueta interna / evidencia fotográfica', '2026-08-03 00:00:00', 'A la mitad',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento, fecha de ingreso. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: A la mitad. Bruto 1122.44 g. Tara 620.90 g (Etiqueta interna / evidencia fotográfica). Neto físico 501.54 g. BITACORA DE CONSUMO EN EL PROPIO FRASCO: ficha REACTIVOS CONTROLADOS con N Frasco 1118-3 y densidad 0.86, con cuatro apuntes entre 2010 y 2015, incluidos dos marcados como MERMA y uno como curso QII. Acción sin decidir: no hay fecha de caducidad legible —ni en el censo ni en la etiqueta— y la condición del envase no basta por sí sola para clasificarlo.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0612-53'
   AND l.numero_lote IS NOT DISTINCT FROM '37312 350853'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 92 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0213-19-01', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N1-P2'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1097.6900, 630.7000, 466.9900, 0,
  432.3981, 'Etiqueta interna / evidencia fotográfica', '2026-08-03 00:00:00', 'Residuo',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: Residuo. Bruto 1097.69 g. Tara 683.30 g (Etiqueta interna / evidencia fotográfica). Neto físico 414.39 g. Frasco de anhidrido acetico 97 % Q.P., procedencia Erba - Italia, distribuido por PROQUIRESA S.R.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0213-19'
   AND l.numero_lote IS NOT DISTINCT FROM NULL
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 93 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0213-20-02', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N1-P2'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1735.2600, 683.3000, 1051.9600, 0,
  974.0370, 'Etiqueta interna / evidencia fotográfica', '2026-08-03 00:00:00', 'Abierto',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: Abierto. Bruto 1735.26 g. Tara 683.30 g (Etiqueta interna / evidencia fotográfica). Neto físico 1051.96 g. BITACORA DE CONSUMO EN EL PROPIO FRASCO: ficha REACTIVOS CONTROLADOS con Nombre del Reactivo "ANHIDRIDO ACETICO 97 %", N Frasco 25014-2 y Densidad 1.08. Acción sin decidir: no hay fecha de caducidad legible —ni en el censo ni en la etiqueta— y la condición del envase no basta por sí sola para clasificarlo.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0213-20'
   AND l.numero_lote IS NOT DISTINCT FROM '………...…..…'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 94 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0408-03-01', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N1-P14'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 717.4600, 696.3000, 21.1600, 0,
  23.5111, 'Etiqueta interna / evidencia fotográfica', '2026-08-03 00:00:00', 'Agotado',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: Agotado. Bruto 717.46 g. Tara 696.30 g (Etiqueta interna / evidencia fotográfica). Neto físico 21.16 g. Frasco MERCK ''Ethylacetat zur Analyse'' Art.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0408-03'
   AND l.numero_lote IS NOT DISTINCT FROM '41 K 3495923'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 96 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0408-04-03', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N1'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'aproximada — sin adhesivo: se conoce la balda, no la posición dentro de ella', 1505.0900, 694.3000, 810.7900, 0,
  900.8778, 'Etiqueta interna / evidencia fotográfica', '2026-08-03 00:00:00', 'Abierto',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: Abierto. Bruto 1505.09 g. Tara 695.00 g (Etiqueta interna / evidencia fotográfica). Neto físico 810.09 g. BITACORA DE CONSUMO EN EL PROPIO FRASCO. Acción sin decidir: no hay fecha de caducidad legible —ni en el censo ni en la etiqueta— y la condición del envase no basta por sí sola para clasificarlo.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0408-04'
   AND l.numero_lote IS NOT DISTINCT FROM '31820'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 97 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0408-04-04', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N1-P10'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1504.4500, 693.9000, 810.5500, 0,
  900.6111, 'Etiqueta interna / evidencia fotográfica', '2026-08-03 00:00:00', 'Abierto',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: Abierto. Bruto 1504.45 g. Tara 693.90 g (Etiqueta interna / evidencia fotográfica). Neto físico 810.55 g. BITACORA DE CONSUMO EN EL PROPIO FRASCO. Acción sin decidir: no hay fecha de caducidad legible —ni en el censo ni en la etiqueta— y la condición del envase no basta por sí sola para clasificarlo.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0408-04'
   AND l.numero_lote IS NOT DISTINCT FROM '31820'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 130 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0708-119-35', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C3-N2-P101'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 435.6300, 97.9000, 337.7300, 0,
  NULL, 'Etiqueta interna / evidencia fotográfica', '2026-08-05 16:04:44', 'A la mitad',
  TRUE, 'EN_USO', 'CADUCIDAD CORREGIDA a 2026-04-30 por criterio del laboratorio (la etiqueta oficial del frasco manda sobre el censo y sobre el rotulo interno): confirmada por el laboratorio; coincide con la etiqueta del fabricante y con el rotulo interno, ambos 30/04/2026. El censo traia 2026-12-31. Evidencia fotográfica conciliada: A la mitad. Bruto 435.63 g. Tara 97.91 g (Etiqueta interna / evidencia fotográfica). Neto físico 337.72 g. Frasco de hidróxido de sodio en lentejas (pellets) marca Supelco/Merck KGaA, grado EMSURE, envase de 1 kg fabricado en Alemania, importado por Merck Peruana S.A.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0708-119'
   AND l.numero_lote IS NOT DISTINCT FROM '-'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 135 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0708-119-40', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C3-N2-P111'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 797.0500, 97.9000, 699.1500, 0,
  NULL, 'Etiqueta interna / evidencia fotográfica', '2026-08-05 16:10:53', 'A la mitad',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: A la mitad. Bruto 797.05 g. Tara 92.40 g (Etiqueta interna / evidencia fotográfica). Neto físico 704.65 g. Etiqueta de fábrica Merck/MilliporeSigma: ''Sodium hydroxide pellets for analysis'', 1 kg, NaOH, M = 40 g/mol, CAS-No 1310-73-2, Made in Germany, Merck KGaA 64271 Darmstadt / EMD Millipore Corporation, 400 Summit Drive, Burlington MA 01803, USA.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0708-119'
   AND l.numero_lote IS NOT DISTINCT FROM '-'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 136 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0708-119-41', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C3-N2-P109'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1104.6400, 93.1000, 1011.5400, 0,
  NULL, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6.2026 IQBF SÓLIDOS.xlsx, hoja NaOH fila 987: 93.14 g, dif -0.04 g)', '2026-08-05 16:26:43', 'Sellado',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Sellado. Bruto 1104.64 g. Tara 93.10 g (Tara del censo referencial). Neto físico 1011.54 g.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0708-119'
   AND l.numero_lote IS NOT DISTINCT FROM '-'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 137 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0708-119-42', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C3-N2-P104'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1101.5400, 96.3000, 1005.2400, 0,
  NULL, 'Etiqueta interna / evidencia fotográfica', '2026-08-05 15:58:24', 'Sellado',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Sellado. Bruto 1101.54 g. Tara 93.52 g (Etiqueta interna / evidencia fotográfica). Neto físico 1008.02 g. Frasco de hidróxido de sodio en perlas (EMSURE) de 1 kg, marca Merck, importado por Merck Peruana S.A.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0708-119'
   AND l.numero_lote IS NOT DISTINCT FROM '-'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 138 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0708-119-43', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C3-N2-P103'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1097.0900, 95.5000, 1001.5900, 0,
  NULL, 'Etiqueta interna / evidencia fotográfica', '2026-08-05 15:38:56', 'Sellado',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Sellado. Bruto 1097.09 g. Tara 97.88 g (Etiqueta interna / evidencia fotográfica). Neto físico 999.21 g. Frasco EMSURE de hidróxido de sodio en lentejas, 1 kg, de Merck.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0708-119'
   AND l.numero_lote IS NOT DISTINCT FROM '-'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 139 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0708-119-44', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C3-N2-P108'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1099.5100, 93.4000, 1006.1100, 0,
  NULL, 'Etiqueta interna / evidencia fotográfica', '2026-08-05 16:29:01', 'Sellado',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Sellado. Bruto 1099.51 g. Tara 93.14 g (Etiqueta interna / evidencia fotográfica). Neto físico 1006.37 g. Frasco Merck/Supelco EMSURE de hidroxido de sodio en pellets, 1 kg, hecho en Alemania.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0708-119'
   AND l.numero_lote IS NOT DISTINCT FROM '-'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 140 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0708-119-45', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C3-N2-P108'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1099.9600, 95.3000, 1004.6600, 0,
  NULL, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6.2026 IQBF SÓLIDOS.xlsx, hoja NaOH fila 1087: 95.28 g, dif +0.02 g)', '2026-08-05 16:08:31', 'Sellado',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Sellado. Bruto 1099.96 g. Tara 95.30 g (Tara del censo referencial). Neto físico 1004.66 g.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0708-119'
   AND l.numero_lote IS NOT DISTINCT FROM '-'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 142 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0708-119-47', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Académico'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C3-N2-P98'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Académico'),
  'exacta — por adhesivo naranja', 810.8500, 101.6000, 709.2500, 0,
  NULL, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6.2026 IQBF SÓLIDOS.xlsx, hoja NaOH fila 1139: 101.61 g, dif -0.01 g)', '2026-08-05 16:14:54', 'A la mitad',
  TRUE, 'EN_USO', 'CADUCIDAD 2026-11-30, confirmada por el laboratorio con el frasco en la mano (formato impreso AAAA-MM-DD). Coincide con la etiqueta del fabricante leída en foto. El censo traía 2030-11-30, que era el error. Los tres frascos del lote MB2241998 429 (-47, -49 y -50) comparten esta misma fecha. Vigente al cierre del censo, pero caduca en noviembre de 2026: conviene priorizar su consumo. El censo traia 2030-11-30. Evidencia fotográfica conciliada: A la mitad. Bruto 810.85 g. Tara 101.60 g (Tara del censo referencial). Neto físico 709.25 g. Frasco de hidróxido de sodio en perlas, EMSURE, catálogo Merck 1.06498.1000, 1 kg nominal.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0708-119'
   AND l.numero_lote IS NOT DISTINCT FROM 'MB2241998 429'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 144 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0708-119-49', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Académico'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C3-N2-P99'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Académico'),
  'exacta — por adhesivo naranja', 1104.9000, 104.2000, 1000.7000, 0,
  NULL, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6.2026 IQBF SÓLIDOS.xlsx, hoja NaOH fila 1195: 104.20 g, dif -0.00 g)', '2026-08-05 16:25:15', 'Sellado',
  TRUE, 'EN_USO', 'CADUCIDAD 2026-11-30, confirmada por el laboratorio con el frasco en la mano (formato impreso AAAA-MM-DD). Coincide con la etiqueta del fabricante leída en foto. El censo traía 2030-11-30, que era el error. Los tres frascos del lote MB2241998 429 (-47, -49 y -50) comparten esta misma fecha. Vigente al cierre del censo, pero caduca en noviembre de 2026: conviene priorizar su consumo. Evidencia fotográfica conciliada: Sellado. Bruto 1104.90 g. Tara 104.20 g (Tara del censo referencial). Neto físico 1000.70 g. Frasco Merck/Supelco EMSURE de hidróxido de sodio en pellets, 1 kg, hecho en Alemania.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0708-119'
   AND l.numero_lote IS NOT DISTINCT FROM 'MB2241998 429'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 145 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0708-119-50', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Académico'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C3-N2-P97'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1104.3700, 103.7000, 1000.6700, 0,
  NULL, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6.2026 IQBF SÓLIDOS.xlsx, hoja NaOH fila 1223: 103.67 g, dif +0.03 g)', '2026-08-05 16:12:51', 'Sellado',
  TRUE, 'EN_USO', 'CADUCIDAD 2026-11-30, confirmada por el laboratorio con el frasco en la mano (formato impreso AAAA-MM-DD). Coincide con la etiqueta del fabricante leída en foto. El censo traía 2030-11-30, que era el error. Los tres frascos del lote MB2241998 429 (-47, -49 y -50) comparten esta misma fecha. Vigente al cierre del censo, pero caduca en noviembre de 2026: conviene priorizar su consumo. Evidencia fotográfica conciliada: Sellado. Bruto 1104.37 g. Tara 103.70 g (Tara del censo referencial). Neto físico 1000.67 g.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0708-119'
   AND l.numero_lote IS NOT DISTINCT FROM 'MB2241998 429'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 152 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF1122-95-01', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C3-N2-P117'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 205.3000, 87.9000, 117.4000, 0,
  NULL, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6.2026 IQBF SÓLIDOS.xlsx, hoja Na2CO3 fila 36: 87.90 g, dif -0.00 g)', '2026-08-05 15:35:07', 'A la mitad',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: A la mitad. Bruto 205.30 g. Tara 87.90 g (Tara del censo referencial). Neto físico 117.40 g. Acción sin decidir: no hay fecha de caducidad legible —ni en el censo ni en la etiqueta— y la condición del envase no basta por sí sola para clasificarlo.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF1122-95'
   AND l.numero_lote IS NOT DISTINCT FROM 'A1218292 741'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 153 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF1122-114-03', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C3-N2-P118'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 765.6600, 88.0000, 677.6600, 0,
  NULL, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6.2026 IQBF SÓLIDOS.xlsx, hoja Na2CO3 fila 94: 87.95 g, dif +0.05 g)', '2026-08-05 16:01:24', 'A la mitad',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: A la mitad. Bruto 765.66 g. Tara 88.00 g (Tara del censo referencial). Neto físico 677.66 g.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF1122-114'
   AND l.numero_lote IS NOT DISTINCT FROM 'A1420492 919'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 154 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF1122-130-04', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C3-N2-P121'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1412.8600, 409.8000, 1003.0600, 0,
  NULL, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6.2026 IQBF SÓLIDOS.xlsx, hoja Na2CO3 fila 121: 409.84 g, dif -0.04 g)', '2026-08-05 15:23:56', 'Sellado',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: Sellado. Bruto 1412.86 g. Tara 409.80 g (Tara del censo referencial). Neto físico 1003.06 g. Acción sin decidir: no hay fecha de caducidad legible —ni en el censo ni en la etiqueta— y la condición del envase no basta por sí sola para clasificarlo.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF1122-130'
   AND l.numero_lote IS NOT DISTINCT FROM '14403'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 155 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF1122-130-05', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C3-N2-P120'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1411.8700, 408.7000, 1003.1700, 0,
  NULL, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6.2026 IQBF SÓLIDOS.xlsx, hoja Na2CO3 fila 145: 408.69 g, dif +0.01 g)', '2026-08-05 15:31:09', 'Sellado',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: Sellado. Bruto 1411.87 g. Tara 408.70 g (Tara del censo referencial). Neto físico 1003.17 g. Acción sin decidir: no hay fecha de caducidad legible —ni en el censo ni en la etiqueta— y la condición del envase no basta por sí sola para clasificarlo.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF1122-130'
   AND l.numero_lote IS NOT DISTINCT FROM '14403'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 156 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF1122-130-06', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C3-N2-P119'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1411.3000, 408.4000, 1002.9000, 0,
  NULL, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6.2026 IQBF SÓLIDOS.xlsx, hoja Na2CO3 fila 169: 408.39 g, dif +0.01 g)', '2026-08-05 15:27:07', 'Sellado',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: Sellado. Bruto 1411.30 g. Tara 408.40 g (Tara del censo referencial). Neto físico 1002.90 g. Acción sin decidir: no hay fecha de caducidad legible —ni en el censo ni en la etiqueta— y la condición del envase no basta por sí sola para clasificarlo.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF1122-130'
   AND l.numero_lote IS NOT DISTINCT FROM '14403'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 157 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF1122-133-07', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Académico'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C3-N2-P116'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 81.0400, 81.0000, 0.0400, 0,
  NULL, 'pesaje del frasco vacío, confirmado por el laboratorio 2026-08-06', '2026-08-05 15:33:17', 'Agotado',
  TRUE, 'EN_USO', 'TARA ACTUALIZADA A 81.04 g. El laboratorio confirmó en estante que el frasco está vacío, así que los 81.04 g que marcó la balanza SON el frasco. El contenido queda en 0 g y desaparece el saldo negativo. La tara anterior, 81.30 g del censo (81.27 g en ALL.DATA, hoja Na2CO3 fila 192), era la de 2023 al ingresar: correcta entonces, pero el envase perdió 0.23 g por el camino y el precinto de la tapa aparece roto en las fotos. Se conserva aquí como referencia histórica. De los 500 g de Na2CO3 no queda nada: Agotado, baja-residuo. DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: Agotado. Bruto 81.04 g. Tara 81.30 g (Tara del censo referencial). Neto físico -0.26 g.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF1122-133'
   AND l.numero_lote IS NOT DISTINCT FROM 'A1655992236'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 158 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF1123-27-05', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = NULL),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C3-N2-P114'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1196.1300, 186.3000, 1009.8300, 0,
  NULL, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6.2026 IQBF SÓLIDOS.xlsx, hoja K2CO3 fila 6: 186.30 g, dif -0.00 g)', '2026-08-05 16:30:27', 'Sellado',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento, responsable. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: Sellado. Bruto 1196.13 g. Tara 186.30 g (Tara del censo referencial). Neto físico 1009.83 g. Acción sin decidir: no hay fecha de caducidad legible —ni en el censo ni en la etiqueta— y la condición del envase no basta por sí sola para clasificarlo.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF1123-27'
   AND l.numero_lote IS NOT DISTINCT FROM '………………'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 165 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0904-54-02', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = NULL),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C3-N2-P115'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1302.0100, 298.2000, 1003.8100, 0,
  NULL, 'Etiqueta interna / evidencia fotográfica', '2026-08-05 15:42:12', 'Dañado',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento, fecha de ingreso, responsable. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: Dañado. Bruto 1302.01 g. Tara 298.20 g (Etiqueta interna / evidencia fotográfica). Neto físico 1003.81 g.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0904-54'
   AND l.numero_lote IS NOT DISTINCT FROM '40-6301-016'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 169 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0106-124-32', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Alimentos'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N2'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'aproximada — sin adhesivo: se conoce la balda, no la posición dentro de ella', 4773.8000, NULL, NULL, 0,
  NULL, 'No disponible en la evidencia', '2026-07-21 14:46:36', 'Sellado',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de ingreso. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. TARA PENDIENTE DE MEDIR: hay peso bruto pero no se conoce el peso del frasco vacío, ni en la etiqueta interna, ni en el censo, ni en las fichas CONTROL DE REACTIVOS de ALL.DATA. Mientras falte, el contenido de este frasco NO es calculable y no tiene saldo declarable ante SUNAT. No se estima con la tara de otro frasco: entre envases iguales del mismo insumo hay hasta 195 g de diferencia. Pesar el frasco vacío, seco y con tapa, cuando se agote. Ver SOLICITUD_TARA.md. Evidencia fotográfica conciliada: condición no resoluble. Bruto 4773.80 g. TRIO DEL MISMO LOTE Z1014252 531.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0106-124'
   AND l.numero_lote IS NOT DISTINCT FROM NULL
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 170 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0106-124-31', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Alimentos'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N2'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'aproximada — sin adhesivo: se conoce la balda, no la posición dentro de ella', 4757.8900, NULL, NULL, 0,
  NULL, 'No disponible en la evidencia', '2026-07-21 15:07:53', 'Sellado',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de ingreso. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. TARA PENDIENTE DE MEDIR: hay peso bruto pero no se conoce el peso del frasco vacío, ni en la etiqueta interna, ni en el censo, ni en las fichas CONTROL DE REACTIVOS de ALL.DATA. Mientras falte, el contenido de este frasco NO es calculable y no tiene saldo declarable ante SUNAT. No se estima con la tara de otro frasco: entre envases iguales del mismo insumo hay hasta 195 g de diferencia. Pesar el frasco vacío, seco y con tapa, cuando se agote. Ver SOLICITUD_TARA.md. Evidencia fotográfica conciliada: condición no resoluble. Bruto 4757.89 g. TRIO DEL MISMO LOTE Z1014252 531.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0106-124'
   AND l.numero_lote IS NOT DISTINCT FROM NULL
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 171 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0106-124-33', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N2'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'aproximada — sin adhesivo: se conoce la balda, no la posición dentro de ella', 4695.9000, NULL, NULL, 0,
  NULL, 'No disponible en la evidencia', '2026-07-21 15:18:52', 'Abierto',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de ingreso. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. TARA PENDIENTE DE MEDIR: hay peso bruto pero no se conoce el peso del frasco vacío, ni en la etiqueta interna, ni en el censo, ni en las fichas CONTROL DE REACTIVOS de ALL.DATA. Mientras falte, el contenido de este frasco NO es calculable y no tiene saldo declarable ante SUNAT. No se estima con la tara de otro frasco: entre envases iguales del mismo insumo hay hasta 195 g de diferencia. Pesar el frasco vacío, seco y con tapa, cuando se agote. Ver SOLICITUD_TARA.md. Evidencia fotográfica conciliada: condición no resoluble. Bruto 4695.90 g. TRIO DEL MISMO LOTE Z1014252 531.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0106-124'
   AND l.numero_lote IS NOT DISTINCT FROM NULL
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 172 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0102-123-102', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Sanabria'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N3'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'aproximada — sin adhesivo: se conoce la balda, no la posición dentro de ella', 4224.8600, 1272.0700, 2952.7900, 0,
  2502.3644, 'Etiqueta interna / evidencia fotográfica', '2026-07-22 18:39:30', 'Sellado',
  TRUE, 'EN_USO', 'ESTADO CORREGIDO: esta fila tenía el texto fijo «NO SE SABE» en «Estado (auto)», con la fórmula borrada. Con su caducidad real (2026-06-08) el frasco está VENCIDO desde hace 58 días. Se restauró la fórmula. Evidencia fotográfica conciliada: Sellado. Bruto 4224.86 g. Tara 1272.07 g (Etiqueta interna / evidencia fotográfica). Neto físico 2952.79 g. Frasco de Ácido Clorhídrico ACS J.T.Baker de 2.5 L, catálogo 9535-05, lote C24W37, fabricado 2021/06/08 y con caducidad impresa 2026/06/08.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0102-123'
   AND l.numero_lote IS NOT DISTINCT FROM 'C24W37'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 173 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0102-123-103', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Sanabria'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C2-N3'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'aproximada — sin adhesivo: se conoce la balda, no la posición dentro de ella', 4235.5000, 1282.4700, 2953.0300, 0,
  2502.5678, 'Etiqueta interna / evidencia fotográfica', '2026-07-22 18:39:27', 'Abierto',
  TRUE, 'EN_USO', 'ESTADO CORREGIDO: esta fila tenía el texto fijo «NO SE SABE» en «Estado (auto)», con la fórmula borrada. Con su caducidad real (2026-06-08) el frasco está VENCIDO desde hace 58 días. Se restauró la fórmula. Evidencia fotográfica conciliada: Sellado. Bruto 4235.50 g. Tara 1282.47 g (Etiqueta interna / evidencia fotográfica). Neto físico 2953.03 g. DISCREPANCIA DE CODIGO CON EL CENSO.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0102-123'
   AND l.numero_lote IS NOT DISTINCT FROM 'C24W37'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 174 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0408-04-05', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N1-P13'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1514.8300, 692.3000, 822.5300, 0,
  913.9222, 'Etiqueta interna / evidencia fotográfica', '2026-08-03 00:00:00', 'Abierto',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: Abierto. Bruto 1514.83 g. Tara 692.30 g (Etiqueta interna / evidencia fotográfica). Neto físico 822.53 g. El frasco lleva pegada una ficha de control de uso manuscrita (fotos 01 y 05) con encabezado ''Nombre del Reactivo: Acetato de Etilo 99.5%'', ''N Frasco: 2...'' (ilegible, queda cortado en el borde de la etiqueta), ''Peso Frasco: 692.3'' y ''Densidad: 0,90''. Acción sin decidir: no hay fecha de caducidad legible —ni en el censo ni en la etiqueta— y la condición del envase no basta por sí sola para clasificarlo.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0408-04'
   AND l.numero_lote IS NOT DISTINCT FROM NULL
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 175 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0308-44', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N1'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'aproximada — sin adhesivo: se conoce la balda, no la posición dentro de ella', 2457.8200, 1418.4000, 1039.4200, 0,
  NULL, 'ficha CONTROL DE REACTIVOS de 6. IQBF ALCOHOL METILICO JUNIO 2026.xlsx bajo el código IQF0308-44', '2026-08-03 00:00:00', 'A la mitad',
  TRUE, 'EN_USO', 'TARA RECUPERADA: 1418.41 g, de la ficha CONTROL DE REACTIVOS de 6. IQBF ALCOHOL METILICO JUNIO 2026.xlsx (hoja METANOL, fila 646), registrada bajo el código IQF0308-44. Se usa esa ficha porque la etiqueta del frasco dice IQF0308-44 y su bruto 2457.82 g coincide con esa ficha. Conviene confirmar el peso en balanza cuando se vacíe el frasco. DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. TARA PENDIENTE DE MEDIR: hay peso bruto pero no se conoce el peso del frasco vacío, ni en la etiqueta interna, ni en el censo, ni en las fichas CONTROL DE REACTIVOS de ALL.DATA. Mientras falte, el contenido de este frasco NO es calculable y no tiene saldo declarable ante SUNAT. No se estima con la tara de otro frasco: entre envases iguales del mismo insumo hay hasta 195 g de diferencia. Pesar el frasco vacío, seco y con tapa, cuando se agote. Ver SOLICITUD_TARA.md. DEPURADO: este frasco figuraba en 2 filas por misma carpeta de evidencia «IQF0308-44»; se conservó esta y se borraron las otras 1. Ninguna de las borradas tenía pesaje propio. Bruto 2457.82 g − tara 1418.41 g = neto 1039.41 g (32.9 % del nominal 3160.00 g). Condición: A la mitad (neto entre 3 % y 80 % del nominal). Datos de etiqueta no registrados antes: marca Fermont - Productos Quimicos Monterrey S.A. de C.V., Mirador 201, Monterrey N.L., Mexico, catálogo 06125, CAS 67-56-1, UN UN1230, importador Corporacion Quimica Yohisa SAC. Alertas: CONSUMO SIN REGISTRO Y EL MAYOR DE LA SERIE: 2120.59 g de metanol, cerca de 2.7 L, sin fecha de apertura ni bitacora | SIN CODIGO SUNAT: no declarable, siendo metanol | FALTAN TOMAS: se necesita foto del resultado de analisis (lote) y de la fecha de ingreso. Evidencia: carpeta IQF0308-44, 1 fotos leídas.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0308-4L'
   AND l.numero_lote IS NOT DISTINCT FROM NULL
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 176 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0308-43', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N2-P35'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 2702.0400, 1473.9000, 1228.1400, 0,
  1554.6076, 'Etiqueta interna / evidencia fotográfica', '2026-08-03 00:00:00', 'A la mitad',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: A la mitad. Bruto 2702.04 g. Tara 1473.91 g (Etiqueta interna / evidencia fotográfica). Neto físico 1228.13 g. Garrafa de 4 L de Metanol ACS Fermont (cat. Acción sin decidir: no hay fecha de caducidad legible —ni en el censo ni en la etiqueta— y la condición del envase no basta por sí sola para clasificarlo.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0308-4L'
   AND l.numero_lote IS NOT DISTINCT FROM NULL
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 177 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0308-45', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N2-P36'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 4609.8000, 1467.8000, 3142.0000, 0,
  3977.2152, 'Etiqueta interna / evidencia fotográfica', '2026-08-03 00:00:00', 'Sellado',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de vencimiento. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: Abierto. Bruto 4609.80 g. Tara 1467.80 g (Etiqueta interna / evidencia fotográfica). Neto físico 3142.00 g. PRIMER FRASCO DE FABRICANTE E IMPORTADOR DISTINTOS. Acción sin decidir: no hay fecha de caducidad legible —ni en el censo ni en la etiqueta— y la condición del envase no basta por sí sola para clasificarlo.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0308-4L'
   AND l.numero_lote IS NOT DISTINCT FROM NULL
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 178 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0308-46', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'W. Hernández'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N2-P37'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  'exacta — por adhesivo naranja', 3232.2200, 1820.9000, 1411.3200, 0,
  1786.4810, 'ficha CONTROL DE REACTIVOS de este frasco (6. IQBF ALCOHOL METILICO JUNIO 2026.xlsx, hoja METANOL fila 712) — prevalece sobre el rótulo interno por criterio del laboratorio', '2026-08-03 00:00:00', 'A la mitad',
  TRUE, 'EN_USO', 'TARA CAMBIADA A 1820.91 g (antes 1570.00 g). El rótulo interno del frasco y la ficha CONTROL DE REACTIVOS discrepan en 250.91 g, y ambos son internamente coherentes: los dos dan un contenido de ingreso de 3160.00 g exactos (4 L x 0.79). Se adopta la de ALL.DATA por criterio del laboratorio, y porque sus cifras (1820.91 / 4980.91 g) tienen decimales de pesaje mientras que las del rótulo son redondas (1570.00 / 4730.00 g), propias de un valor derivado. CONSECUENCIA: el contenido declarado baja de 1662.22 a 1411.31 g. VERIFICAR pesando el frasco vacío cuando se agote. Evidencia fotográfica conciliada: A la mitad. Bruto 3232.22 g. Tara 1570.00 g (Etiqueta interna / evidencia fotográfica). Neto físico 1662.22 g. Frasco de 4 L de metanol HPLC J.T.Baker/Avantor, origen Mexico, importado por MERCANTIL S.A.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0308-4L'
   AND l.numero_lote IS NOT DISTINCT FROM NULL
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 179 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0308-48', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Académico'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N2-P30'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 2945.6800, 1267.4000, 1678.2800, 0,
  2124.4051, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6. IQBF ALCOHOL METILICO JUNIO 2026.xlsx, hoja METANOL fila 785: 1267.39 g, dif +0.00 g)', '2026-08-03 00:00:00', 'Sellado',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Sellado. Bruto 2945.68 g. Tara 1267.39 g (Ficha CONTROL DE REACTIVOS (6. IQBF ALCOHOL METILICO JUNIO 2026.xlsx / METANOL)). Neto físico 1678.29 g. Segunda presentacion de metanol EMSURE: 2.5 L catalogo 1.06009.2500, frente al 1.06009.1000 de 1 L del IQF0308-41.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0308-2-5L'
   AND l.numero_lote IS NOT DISTINCT FROM NULL
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 180 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0308-41', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N2-P34'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1323.0200, 630.1000, 692.9200, 0,
  877.1139, 'Etiqueta interna / evidencia fotográfica', '2026-08-03 00:00:00', 'Abierto',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Abierto. Bruto 1323.02 g. Tara 630.10 g (Etiqueta interna / evidencia fotográfica). Neto físico 692.92 g. PRIMER FRASCO DE TODA LA SERIE CON DECLARACION EXPRESA DE SUSTANCIA CONTROLADA.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0308-1L'
   AND l.numero_lote IS NOT DISTINCT FROM NULL
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 181 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0308-42', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N2-P33'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1465.2200, 674.7000, 790.5200, 0,
  1000.6582, 'Etiqueta interna / evidencia fotográfica', '2026-08-03 00:00:00', 'Sellado',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Sellado. Bruto 1465.22 g. Tara 674.70 g (Etiqueta interna / evidencia fotográfica). Neto físico 790.52 g. ETIQUETA INTERNA EN FORMATO IMPRESO, NO MANUSCRITO.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0308-1L'
   AND l.numero_lote IS NOT DISTINCT FROM NULL
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 183 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0304-27', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N2-P22'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1601.2900, 1250.5000, 350.7900, 0,
  444.0380, 'Etiqueta interna / evidencia fotográfica', '2026-08-04 15:19:26', 'A la mitad',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: A la mitad. Bruto 1601.29 g. Tara 1250.52 g (Etiqueta interna / evidencia fotográfica). Neto físico 350.77 g. PRIMER FRASCO CON CONSUMO REAL MEDIDO.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0304-2-5L'
   AND l.numero_lote IS NOT DISTINCT FROM NULL
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 184 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0304-33', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Académico'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N2-P19'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1751.6100, 1264.8000, 486.8100, 0,
  616.2152, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6. IQBF ETANOL JUNIO 2026.xlsx, hoja ETANOL fila 1064: 1264.81 g, dif +0.00 g)', '2026-08-04 15:25:30', 'A la mitad',
  TRUE, 'EN_USO', 'DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de ingreso. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: A la mitad. Bruto 1751.61 g. Tara 1264.81 g (Ficha CONTROL DE REACTIVOS (6. IQBF ETANOL JUNIO 2026.xlsx / ETANOL)). Neto físico 486.80 g. LOTE DISTINTO AL DE LOS CUATRO FRASCOS DE MONTOYA: aqui el lote es I1350683 425 y el vencimiento 2029/03/31, frente a I1366383 433 y 2029/07/31.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0304-2-5L'
   AND l.numero_lote IS NOT DISTINCT FROM NULL
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 185 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0304-37', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Montoya'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N2'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'aproximada — asignada por el laboratorio: los etanoles van juntos en esa balda', 3176.8900, 1202.1000, 1974.7900, 0,
  2499.7342, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6. IQBF ETANOL JUNIO 2026.xlsx, hoja ETANOL fila 1183: 1202.07 g, dif -0.00 g)', '2026-08-04 15:32:59', 'Sellado',
  TRUE, 'EN_USO', 'UBICACIÓN ASIGNADA POR EL LABORATORIO: los etanoles se guardan juntos en el Nivel 2 del Casillero 1, la misma balda que los metanoles (el letrero de la puerta reserva 15–28 para etanol y 29–38 para metanol). Este frasco no lleva adhesivo naranja, así que se conoce la balda pero no la posición dentro de ella. OJO CON LA ARITMÉTICA: el letrero reserva 14 plazas de etanol, hay 12 ocupadas por frascos con adhesivo y quedan libres la 24 y la 25, pero sin ubicar hay 4 etanoles. Dos de ellos caben en 24 y 25; los otros dos exceden las plazas rotuladas. Al rotularlos habrá que ampliar el letrero o reubicarlos. DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de ingreso. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: Sellado. Bruto 3176.89 g. Tara 1202.07 g (Ficha CONTROL DE REACTIVOS (6. IQBF ETANOL JUNIO 2026.xlsx / ETANOL)). Neto físico 1974.82 g. CUARTO FRASCO DEL LOTE I1366383 433, junto con IQF0304-34, -35 y -36.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0304-2-5L'
   AND l.numero_lote IS NOT DISTINCT FROM NULL
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 190 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0304-11', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'W. Hernández'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N2-P21'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 2814.1800, 1252.0000, 1562.1800, 0,
  1977.4430, 'Etiqueta interna / evidencia fotográfica', '2026-08-05 15:20:53', 'A la mitad',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: A la mitad. Bruto 2814.18 g. Tara 1251.99 g (Etiqueta interna / evidencia fotográfica). Neto físico 1562.19 g. Etiqueta IQNF normalizada a IQF por tratarse de un insumo fiscalizado. Rotulo interno del laboratorio dice ''IQNF-0304-11''.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0304-2-5L'
   AND l.numero_lote IS NOT DISTINCT FROM 'I1243083 239'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 191 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0304-12', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N2-P26'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  'exacta — por adhesivo naranja', 2134.8300, 161.3000, 1973.5300, 0,
  2498.1392, 'Etiqueta interna / evidencia fotográfica', '2026-08-05 15:52:22', 'Sellado',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Sellado. Bruto 2134.83 g. Tara 161.30 g (Etiqueta interna / evidencia fotográfica). Neto físico 1973.53 g. Etiqueta IQNF normalizada a IQF por tratarse de un insumo fiscalizado. Frasco de 2.5 L de etanol absoluto EMPARTA ACS de Supelco/Merck.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0304-2-5L'
   AND l.numero_lote IS NOT DISTINCT FROM 'I1316817 401'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 192 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0304-13', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Abel Gutarra'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N2-P15'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1459.2000, 668.5000, 790.7000, 0,
  1000.8861, 'Etiqueta interna / evidencia fotográfica', '2026-08-04 15:42:26', 'Sellado',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Sellado. Bruto 1459.20 g. Tara 668.45 g (Etiqueta interna / evidencia fotográfica). Neto físico 790.75 g. TERCER FRASCO DE LA MISMA COMPRA.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0304-1L'
   AND l.numero_lote IS NOT DISTINCT FROM 'I1305383'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 193 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0304-14', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Abel Gutarra'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N2-P18'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1460.2000, 669.4000, 790.8000, 0,
  1001.0127, 'Etiqueta interna / evidencia fotográfica', '2026-08-04 15:39:26', 'Sellado',
  TRUE, 'EN_USO', 'Evidencia fotográfica conciliada: Sellado. Bruto 1460.20 g. Tara 669.44 g (Etiqueta interna / evidencia fotográfica). Neto físico 790.76 g. Etiqueta impresa declara ''1 l = 0.79 kg'' y ''M = 46.07 g/mol''.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0304-1L'
   AND l.numero_lote IS NOT DISTINCT FROM 'I1305383'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 194 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0304-15', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Abel Gutarra'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N2-P17'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1460.6500, 669.9000, 790.7500, 0,
  1000.9494, 'ficha CONTROL DE REACTIVOS de este frasco (6. IQBF ETANOL JUNIO 2026.xlsx, hoja ETANOL fila 508) — prevalece sobre el rótulo interno por criterio del laboratorio', '2026-08-04 15:57:51', 'Sellado',
  TRUE, 'EN_USO', 'TARA CAMBIADA A 669.90 g (antes 669.40 g). El rótulo interno del frasco y la ficha CONTROL DE REACTIVOS discrepan en 0.50 g, y ambos son internamente coherentes: los dos dan un contenido de ingreso de 3160.00 g exactos (4 L x 0.79). Se adopta la de ALL.DATA por criterio del laboratorio, y porque sus cifras (669.90 / 1459.90 g) tienen decimales de pesaje mientras que las del rótulo son redondas (669.40 / 3829.40 g), propias de un valor derivado. CONSECUENCIA: el contenido declarado baja de 791.25 a 790.75 g. VERIFICAR pesando el frasco vacío cuando se agote. Evidencia fotográfica conciliada: Sellado. Bruto 1460.65 g. Tara 669.40 g (Etiqueta interna / evidencia fotográfica). Neto físico 791.25 g. CUARTO FRASCO DE 1 L DE LA MISMA COMPRA, junto con IQF0304-13, -14 y -22: misma fecha de ingreso 03/07/2024, mismo profesor A.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0304-1L'
   AND l.numero_lote IS NOT DISTINCT FROM 'I1305383'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 195 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0304-28', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Abel Gutarra'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N2-P16'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'exacta — por adhesivo naranja', 1459.4500, 668.7000, 790.7500, 0,
  1000.9494, 'Etiqueta interna / evidencia fotográfica', '2026-08-04 15:15:22', 'Sellado',
  TRUE, 'EN_USO', 'STICKER CORREGIDO A MANO — REIMPRIMIR. Este frasco lleva el código escrito a bolígrafo sobre el impreso, y lo que lleva escrito es IQF0304-22, que es el código de OTRO frasco. Su código real es IQF0304-28, verificado contra ALL.DATA fila 920 (tara 668.71 g, bruto de ingreso 1458.71 g, custodio A. GUTARRA). Reimprimir el sticker como IQF0304-28 antes de cerrar el inventario: mientras lleve el 22 escrito a mano, cualquiera lo contará como el frasco equivocado. Evidencia fotográfica conciliada: Sellado. Bruto 1459.45 g. Tara 668.71 g (Etiqueta interna / evidencia fotográfica). Neto físico 790.74 g. FRASCO REETIQUETADO A MANO.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0304-1L'
   AND l.numero_lote IS NOT DISTINCT FROM NULL
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 196 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0304-34', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Montoya'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N2'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'aproximada — asignada por el laboratorio: los etanoles van juntos en esa balda', 2432.3000, 1197.4000, 1234.9000, 0,
  1563.1646, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6. IQBF ETANOL JUNIO 2026.xlsx, hoja ETANOL fila 1096: 1197.36 g, dif -0.00 g)', '2026-08-04 16:03:48', 'A la mitad',
  TRUE, 'EN_USO', 'UBICACIÓN ASIGNADA POR EL LABORATORIO: los etanoles se guardan juntos en el Nivel 2 del Casillero 1, la misma balda que los metanoles (el letrero de la puerta reserva 15–28 para etanol y 29–38 para metanol). Este frasco no lleva adhesivo naranja, así que se conoce la balda pero no la posición dentro de ella. OJO CON LA ARITMÉTICA: el letrero reserva 14 plazas de etanol, hay 12 ocupadas por frascos con adhesivo y quedan libres la 24 y la 25, pero sin ubicar hay 4 etanoles. Dos de ellos caben en 24 y 25; los otros dos exceden las plazas rotuladas. Al rotularlos habrá que ampliar el letrero o reubicarlos. DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de ingreso. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: A la mitad. Bruto 2432.30 g. Tara 1197.36 g (Ficha CONTROL DE REACTIVOS (6. IQBF ETANOL JUNIO 2026.xlsx / ETANOL)). Neto físico 1234.94 g. TERCER FRASCO DEL LOTE I1366383 433, junto con IQF0304-35 y IQF0304-36.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0304-2-5L'
   AND l.numero_lote IS NOT DISTINCT FROM 'I1366383 433'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 197 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0304-35', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Montoya'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N2'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'aproximada — asignada por el laboratorio: los etanoles van juntos en esa balda', 3171.9300, 1197.1000, 1974.8300, 0,
  2499.7848, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6. IQBF ETANOL JUNIO 2026.xlsx, hoja ETANOL fila 1125: 1197.09 g, dif -0.00 g)', '2026-08-04 15:36:19', 'Sellado',
  TRUE, 'EN_USO', 'UBICACIÓN ASIGNADA POR EL LABORATORIO: los etanoles se guardan juntos en el Nivel 2 del Casillero 1, la misma balda que los metanoles (el letrero de la puerta reserva 15–28 para etanol y 29–38 para metanol). Este frasco no lleva adhesivo naranja, así que se conoce la balda pero no la posición dentro de ella. OJO CON LA ARITMÉTICA: el letrero reserva 14 plazas de etanol, hay 12 ocupadas por frascos con adhesivo y quedan libres la 24 y la 25, pero sin ubicar hay 4 etanoles. Dos de ellos caben en 24 y 25; los otros dos exceden las plazas rotuladas. Al rotularlos habrá que ampliar el letrero o reubicarlos. DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de ingreso. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: Sellado. Bruto 3171.93 g. Tara 1197.09 g (Ficha CONTROL DE REACTIVOS (6. IQBF ETANOL JUNIO 2026.xlsx / ETANOL)). Neto físico 1974.84 g. FRASCO GEMELO DEL IQF0304-36: mismo lote I1366383 433, mismo catalogo 1.00983.2500, mismo vencimiento impreso 2029/07/31, misma capacidad 2.5 L, mismo profesor MONTOYA, misma tirada de etiqueta 654833 y mismo copyright 2022.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0304-2-5L'
   AND l.numero_lote IS NOT DISTINCT FROM NULL
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 198 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0304-36', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Montoya'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N2'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = NULL),
  'aproximada — asignada por el laboratorio: los etanoles van juntos en esa balda', 3172.9500, 1198.1000, 1974.8500, 0,
  2499.8101, 'censo, CORROBORADA por la ficha CONTROL DE REACTIVOS de este frasco (6. IQBF ETANOL JUNIO 2026.xlsx, hoja ETANOL fila 1154: 1198.14 g, dif +0.00 g)', '2026-08-04 15:55:44', 'Sellado',
  TRUE, 'EN_USO', 'UBICACIÓN ASIGNADA POR EL LABORATORIO: los etanoles se guardan juntos en el Nivel 2 del Casillero 1, la misma balda que los metanoles (el letrero de la puerta reserva 15–28 para etanol y 29–38 para metanol). Este frasco no lleva adhesivo naranja, así que se conoce la balda pero no la posición dentro de ella. OJO CON LA ARITMÉTICA: el letrero reserva 14 plazas de etanol, hay 12 ocupadas por frascos con adhesivo y quedan libres la 24 y la 25, pero sin ubicar hay 4 etanoles. Dos de ellos caben en 24 y 25; los otros dos exceden las plazas rotuladas. Al rotularlos habrá que ampliar el letrero o reubicarlos. DATOS QUE NO APARECEN EN NINGUNA FUENTE: fecha de ingreso. Se buscó en la fotografía del frasco (etiqueta del fabricante y rótulo interno), en el censo y en las fichas CONTROL DE REACTIVOS de los libros operativos. Solicitar al laboratorio. Ver SOLICITUD_DATOS_FALTANTES.md. Evidencia fotográfica conciliada: Sellado. Bruto 3172.95 g. Tara 1198.14 g (Ficha CONTROL DE REACTIVOS (6. IQBF ETANOL JUNIO 2026.xlsx / ETANOL)). Neto físico 1974.81 g. FALTA LA ETIQUETA INTERNA DEL LABORATORIO.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0304-2-5L'
   AND l.numero_lote IS NOT DISTINCT FROM 'I1366383 433'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- fila 199 del censo
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual,
  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,
  peso_neto_actual_g,
  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,
  existe, estado, observaciones)
SELECT 'IQF0708-119-21', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Juan Carlos Yacono'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C3-N2-P102'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Ingeniería Civil'),
  'exacta — por adhesivo naranja', 1098.7900, 106.4000, 992.3900, 0,
  NULL, 'ficha CONTROL DE REACTIVOS de 6.2026 IQBF SÓLIDOS.xlsx bajo el código IQF0708-121-21', '2026-08-05 16:18:41', 'Abierto',
  TRUE, 'EN_USO', 'TARA RECUPERADA: 106.35 g, de la ficha CONTROL DE REACTIVOS de 6.2026 IQBF SÓLIDOS.xlsx (hoja NaOH, fila 434), registrada bajo el código IQF0708-121-21. Se usa esa ficha porque la etiqueta impresa dice 119 pero el manuscrito del propio frasco dice 121-21, que es el código de esta ficha. Conviene confirmar el peso en balanza cuando se vacíe el frasco. TARA PENDIENTE DE MEDIR: hay peso bruto pero no se conoce el peso del frasco vacío, ni en la etiqueta interna, ni en el censo, ni en las fichas CONTROL DE REACTIVOS de ALL.DATA. Mientras falte, el contenido de este frasco NO es calculable y no tiene saldo declarable ante SUNAT. No se estima con la tara de otro frasco: entre envases iguales del mismo insumo hay hasta 195 g de diferencia. Pesar el frasco vacío, seco y con tapa, cuando se agote. Ver SOLICITUD_TARA.md. Evidencia fotográfica conciliada: Abierto. Bruto 1098.79 g. Frasco de hidroxido de sodio en lentejas (pellets) para analisis, marca Merck/Supelco linea EMSURE, presentacion 1 kg, cat.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0708-119'
   AND l.numero_lote IS NOT DISTINCT FROM 'MB1975398 149'
  ON CONFLICT (id_frasco) DO UPDATE SET
    id_investigador = EXCLUDED.id_investigador,
    id_ubicacion = EXCLUDED.id_ubicacion,
    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,
                                     frasco.id_laboratorio_actual),
    peso_bruto_g = EXCLUDED.peso_bruto_g,
    tara_g = EXCLUDED.tara_g,
    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,
    fuente_tara = EXCLUDED.fuente_tara,
    fecha_pesaje = EXCLUDED.fecha_pesaje,
    condicion_envase = EXCLUDED.condicion_envase;

-- ─── saldo inicial: un movimiento de censo por frasco ─────────────
-- Hasta aquí ningún frasco tiene saldo. Si la carga falla a medias, no
-- queda inventario fantasma.
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0102-111-98', 'ENTRADA', 'censo_inicial', 743.3800,
  743.3800, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  '2026-07-21 17:17:25', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0102-111-98')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0102-111-98'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0102-115-99', 'ENTRADA', 'censo_inicial', 516.5600,
  516.5600, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  '2026-07-21 17:17:27', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0102-115-99')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0102-115-99'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0102-112-100', 'ENTRADA', 'censo_inicial', 2951.3500,
  2951.3500, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  '2026-07-21 16:13:29', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0102-112-100')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0102-112-100'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0102-112-101', 'ENTRADA', 'censo_inicial', 2952.2200,
  2952.2200, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  '2026-07-21 16:38:14', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0102-112-101')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0102-112-101'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0102-115-105', 'ENTRADA', 'censo_inicial', 2474.4300,
  2474.4300, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Ing. Civil'),
  '2026-07-21 17:17:17', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0102-115-105')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0102-115-105'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0102-123-106', 'ENTRADA', 'censo_inicial', 2953.1300,
  2953.1300, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  '2026-07-24 11:41:53', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0102-123-106')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0102-123-106'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0102-123-107', 'ENTRADA', 'censo_inicial', 2952.9100,
  2952.9100, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  '2026-07-21 16:01:31', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0102-123-107')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0102-123-107'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0102-137-108', 'ENTRADA', 'censo_inicial', 527.7200,
  527.7200, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Juan Carlos Yacono'),
  '2026-07-22 18:39:21', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0102-137-108')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0102-137-108'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0102-137-109', 'ENTRADA', 'censo_inicial', 591.7700,
  591.7700, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Juan Carlos Yacono'),
  '2026-07-22 18:39:18', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0102-137-109')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0102-137-109'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0102-69-110', 'ENTRADA', 'censo_inicial', 2951.2900,
  2951.2900, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  '2026-07-22 18:39:32', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0102-69-110')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0102-69-110'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0102-69-111', 'ENTRADA', 'censo_inicial', 2951.0400,
  2951.0400, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  '2026-07-24 11:53:24', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0102-69-111')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0102-69-111'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0102-69-112', 'ENTRADA', 'censo_inicial', 2951.1600,
  2951.1600, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  '2026-07-24 11:46:46', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0102-69-112')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0102-69-112'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0102-69-113', 'ENTRADA', 'censo_inicial', 2597.2000,
  2597.2000, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Quino'),
  '2026-07-21 16:05:13', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0102-69-113')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0102-69-113'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0102-69-114', 'ENTRADA', 'censo_inicial', 2310.9900,
  2310.9900, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Quino'),
  '2026-07-21 17:17:20', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0102-69-114')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0102-69-114'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0102-69-116', 'ENTRADA', 'censo_inicial', 18.7900,
  18.7900, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  '2026-07-21 16:20:40', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0102-69-116')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0102-69-116'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0106-122-23', 'ENTRADA', 'censo_inicial', 3231.5700,
  3231.5700, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Sanabria'),
  '2026-07-21 15:41:39', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0106-122-23')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0106-122-23'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0106-122-24', 'ENTRADA', 'censo_inicial', 3526.9700,
  3526.9700, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Sanabria'),
  '2026-07-21 15:33:31', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0106-122-24')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0106-122-24'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0106-116-25', 'ENTRADA', 'censo_inicial', 38.4300,
  38.4300, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Académico'),
  '2026-07-21 14:40:20', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0106-116-25')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0106-116-25'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0106-134-26', 'ENTRADA', 'censo_inicial', 3170.9100,
  3170.9100, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Académico'),
  '2026-07-21 15:03:37', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0106-134-26')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0106-134-26'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0106-134-27', 'ENTRADA', 'censo_inicial', 2088.1900,
  2088.1900, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Ing. Civil'),
  '2026-07-21 15:26:46', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0106-134-27')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0106-134-27'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0108-104-27', 'ENTRADA', 'censo_inicial', 34.5800,
  34.5800, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Académico'),
  '2026-07-21 00:00:00', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0108-104-27')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0108-104-27'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0108-129-28', 'ENTRADA', 'censo_inicial', 306.1800,
  306.1800, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  '2026-07-21 15:13:49', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0108-129-28')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0108-129-28'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0108-129-29', 'ENTRADA', 'censo_inicial', 4601.4800,
  4601.4800, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  '2026-07-21 16:09:31', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0108-129-29')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0108-129-29'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0108-129-30', 'ENTRADA', 'censo_inicial', 4601.4800,
  4601.4800, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  '2026-07-21 14:32:38', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0108-129-30')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0108-129-30'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0108-120-34', 'ENTRADA', 'censo_inicial', 4393.9300,
  4393.9300, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Quino'),
  '2026-07-21 15:30:30', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0108-120-34')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0108-120-34'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0108-120-35', 'ENTRADA', 'censo_inicial', 1682.6200,
  1682.6200, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  '2026-07-21 15:24:18', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0108-120-35')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0108-120-35'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0108-120-36', 'ENTRADA', 'censo_inicial', 4600.7000,
  4600.7000, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  '2026-07-21 14:30:15', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0108-120-36')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0108-120-36'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0108-084-37', 'ENTRADA', 'censo_inicial', 1840.1700,
  1840.1700, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Ing. Civil'),
  '2026-07-21 14:44:08', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0108-084-37')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0108-084-37'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0605-132-34', 'ENTRADA', 'censo_inicial', 1260.6000,
  1260.6000, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'H. Villagarcía'),
  '2026-07-24 12:43:48', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0605-132-34')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0605-132-34'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0605-132-39', 'ENTRADA', 'censo_inicial', 737.9900,
  737.9900, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Académico'),
  '2026-07-24 12:46:28', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0605-132-39')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0605-132-39'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0605-132-40', 'ENTRADA', 'censo_inicial', 1649.9000,
  1649.9000, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Alimentos'),
  '2026-07-24 11:56:57', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0605-132-40')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0605-132-40'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0605-132-41', 'ENTRADA', 'censo_inicial', 1650.8900,
  1650.8900, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Alimentos'),
  '2026-07-24 12:12:15', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0605-132-41')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0605-132-41'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0605-098-43', 'ENTRADA', 'censo_inicial', 662.5800,
  662.5800, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Alimentos'),
  '2026-07-24 00:00:00', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0605-098-43')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0605-098-43'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0702-94-08', 'ENTRADA', 'censo_inicial', 1839.9100,
  1839.9100, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Muedas'),
  '2026-07-24 12:39:37', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0702-94-08')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0702-94-08'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0702-105-09', 'ENTRADA', 'censo_inicial', 2248.0400,
  2248.0400, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Académico (lab Quimica)'),
  '2026-07-24 12:24:42', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0702-105-09')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0702-105-09'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0401-106-23', 'ENTRADA', 'censo_inicial', 1127.1200,
  1127.1200, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Académico'),
  '2026-07-24 12:17:19', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0401-106-23')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0401-106-23'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0401-125-24', 'ENTRADA', 'censo_inicial', 788.5200,
  788.5200, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'La Cruz'),
  '2026-07-24 12:00:49', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0401-125-24')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0401-125-24'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0401-125-25', 'ENTRADA', 'censo_inicial', 791.6400,
  791.6400, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'H. Villagarcía'),
  '2026-07-24 12:48:36', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0401-125-25')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0401-125-25'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0401-125-26', 'ENTRADA', 'censo_inicial', 792.7300,
  792.7300, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'H. Villagarcía'),
  '2026-07-24 12:56:27', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0401-125-26')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0401-125-26'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0613-126-02', 'ENTRADA', 'censo_inicial', 712.3100,
  712.3100, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Juan Carlos Yacono'),
  '2026-07-24 12:21:13', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0613-126-02')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0613-126-02'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0501-33-03', 'ENTRADA', 'censo_inicial', 377.5300,
  377.5300, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  '2026-08-03 00:00:00', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0501-33-03')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0501-33-03'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0501-90-06', 'ENTRADA', 'censo_inicial', 708.5500,
  708.5500, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  '2026-08-03 00:00:00', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0501-90-06')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0501-90-06'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0501-100-07', 'ENTRADA', 'censo_inicial', 706.2400,
  706.2400, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  '2026-08-03 00:00:00', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0501-100-07')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0501-100-07'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0501-100-08', 'ENTRADA', 'censo_inicial', 708.6600,
  708.6600, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  '2026-08-03 00:00:00', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0501-100-08')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0501-100-08'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0502-35-01', 'ENTRADA', 'censo_inicial', 256.4100,
  256.4100, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  '2026-08-03 00:00:00', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0502-35-01')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0502-35-01'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0502-36-02', 'ENTRADA', 'censo_inicial', 527.4500,
  527.4500, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  '2026-08-03 00:00:00', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0502-36-02')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0502-36-02'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0612-53-03', 'ENTRADA', 'censo_inicial', 501.5400,
  501.5400, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  '2026-08-03 00:00:00', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0612-53-03')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0612-53-03'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0213-19-01', 'ENTRADA', 'censo_inicial', 466.9900,
  466.9900, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  '2026-08-03 00:00:00', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0213-19-01')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0213-19-01'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0213-20-02', 'ENTRADA', 'censo_inicial', 1051.9600,
  1051.9600, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  '2026-08-03 00:00:00', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0213-20-02')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0213-20-02'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0408-03-01', 'ENTRADA', 'censo_inicial', 21.1600,
  21.1600, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  '2026-08-03 00:00:00', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0408-03-01')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0408-03-01'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0408-04-03', 'ENTRADA', 'censo_inicial', 810.7900,
  810.7900, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  '2026-08-03 00:00:00', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0408-04-03')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0408-04-03'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0408-04-04', 'ENTRADA', 'censo_inicial', 810.5500,
  810.5500, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  '2026-08-03 00:00:00', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0408-04-04')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0408-04-04'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0708-119-35', 'ENTRADA', 'censo_inicial', 337.7300,
  337.7300, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  '2026-08-05 16:04:44', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0708-119-35')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0708-119-35'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0708-119-40', 'ENTRADA', 'censo_inicial', 699.1500,
  699.1500, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  '2026-08-05 16:10:53', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0708-119-40')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0708-119-40'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0708-119-41', 'ENTRADA', 'censo_inicial', 1011.5400,
  1011.5400, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  '2026-08-05 16:26:43', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0708-119-41')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0708-119-41'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0708-119-42', 'ENTRADA', 'censo_inicial', 1005.2400,
  1005.2400, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  '2026-08-05 15:58:24', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0708-119-42')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0708-119-42'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0708-119-43', 'ENTRADA', 'censo_inicial', 1001.5900,
  1001.5900, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  '2026-08-05 15:38:56', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0708-119-43')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0708-119-43'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0708-119-44', 'ENTRADA', 'censo_inicial', 1006.1100,
  1006.1100, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  '2026-08-05 16:29:01', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0708-119-44')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0708-119-44'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0708-119-45', 'ENTRADA', 'censo_inicial', 1004.6600,
  1004.6600, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  '2026-08-05 16:08:31', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0708-119-45')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0708-119-45'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0708-119-47', 'ENTRADA', 'censo_inicial', 709.2500,
  709.2500, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Académico'),
  '2026-08-05 16:14:54', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0708-119-47')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0708-119-47'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0708-119-49', 'ENTRADA', 'censo_inicial', 1000.7000,
  1000.7000, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Académico'),
  '2026-08-05 16:25:15', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0708-119-49')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0708-119-49'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0708-119-50', 'ENTRADA', 'censo_inicial', 1000.6700,
  1000.6700, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Académico'),
  '2026-08-05 16:12:51', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0708-119-50')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0708-119-50'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF1122-95-01', 'ENTRADA', 'censo_inicial', 117.4000,
  117.4000, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  '2026-08-05 15:35:07', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF1122-95-01')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF1122-95-01'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF1122-114-03', 'ENTRADA', 'censo_inicial', 677.6600,
  677.6600, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  '2026-08-05 16:01:24', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF1122-114-03')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF1122-114-03'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF1122-130-04', 'ENTRADA', 'censo_inicial', 1003.0600,
  1003.0600, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  '2026-08-05 15:23:56', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF1122-130-04')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF1122-130-04'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF1122-130-05', 'ENTRADA', 'censo_inicial', 1003.1700,
  1003.1700, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  '2026-08-05 15:31:09', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF1122-130-05')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF1122-130-05'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF1122-130-06', 'ENTRADA', 'censo_inicial', 1002.9000,
  1002.9000, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  '2026-08-05 15:27:07', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF1122-130-06')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF1122-130-06'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF1122-133-07', 'ENTRADA', 'censo_inicial', 0.0400,
  0.0400, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Académico'),
  '2026-08-05 15:33:17', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF1122-133-07')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF1122-133-07'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF1123-27-05', 'ENTRADA', 'censo_inicial', 1009.8300,
  1009.8300, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = NULL),
  '2026-08-05 16:30:27', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF1123-27-05')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF1123-27-05'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0904-54-02', 'ENTRADA', 'censo_inicial', 1003.8100,
  1003.8100, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = NULL),
  '2026-08-05 15:42:12', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0904-54-02')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0904-54-02'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
-- IQF0106-124-32: sin tara, saldo INDETERMINADO. No se abre kardex.
-- IQF0106-124-31: sin tara, saldo INDETERMINADO. No se abre kardex.
-- IQF0106-124-33: sin tara, saldo INDETERMINADO. No se abre kardex.
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0102-123-102', 'ENTRADA', 'censo_inicial', 2952.7900,
  2952.7900, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Sanabria'),
  '2026-07-22 18:39:30', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0102-123-102')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0102-123-102'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0102-123-103', 'ENTRADA', 'censo_inicial', 2953.0300,
  2953.0300, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Sanabria'),
  '2026-07-22 18:39:27', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0102-123-103')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0102-123-103'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0408-04-05', 'ENTRADA', 'censo_inicial', 822.5300,
  822.5300, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  '2026-08-03 00:00:00', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0408-04-05')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0408-04-05'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0308-44', 'ENTRADA', 'censo_inicial', 1039.4200,
  1039.4200, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  '2026-08-03 00:00:00', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0308-44')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0308-44'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0308-43', 'ENTRADA', 'censo_inicial', 1228.1400,
  1228.1400, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  '2026-08-03 00:00:00', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0308-43')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0308-43'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0308-45', 'ENTRADA', 'censo_inicial', 3142.0000,
  3142.0000, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  '2026-08-03 00:00:00', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0308-45')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0308-45'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0308-46', 'ENTRADA', 'censo_inicial', 1411.3200,
  1411.3200, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'W. Hernández'),
  '2026-08-03 00:00:00', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0308-46')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0308-46'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0308-48', 'ENTRADA', 'censo_inicial', 1678.2800,
  1678.2800, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Académico'),
  '2026-08-03 00:00:00', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0308-48')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0308-48'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0308-41', 'ENTRADA', 'censo_inicial', 692.9200,
  692.9200, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  '2026-08-03 00:00:00', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0308-41')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0308-41'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0308-42', 'ENTRADA', 'censo_inicial', 790.5200,
  790.5200, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Chasquibol'),
  '2026-08-03 00:00:00', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0308-42')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0308-42'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0304-27', 'ENTRADA', 'censo_inicial', 350.7900,
  350.7900, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  '2026-08-04 15:19:26', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0304-27')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0304-27'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0304-33', 'ENTRADA', 'censo_inicial', 486.8100,
  486.8100, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Académico'),
  '2026-08-04 15:25:30', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0304-33')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0304-33'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0304-37', 'ENTRADA', 'censo_inicial', 1974.7900,
  1974.7900, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Montoya'),
  '2026-08-04 15:32:59', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0304-37')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0304-37'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0304-11', 'ENTRADA', 'censo_inicial', 1562.1800,
  1562.1800, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'W. Hernández'),
  '2026-08-05 15:20:53', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0304-11')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0304-11'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0304-12', 'ENTRADA', 'censo_inicial', 1973.5300,
  1973.5300, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Lab. Docimasia'),
  '2026-08-05 15:52:22', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0304-12')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0304-12'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0304-13', 'ENTRADA', 'censo_inicial', 790.7000,
  790.7000, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Abel Gutarra'),
  '2026-08-04 15:42:26', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0304-13')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0304-13'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0304-14', 'ENTRADA', 'censo_inicial', 790.8000,
  790.8000, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Abel Gutarra'),
  '2026-08-04 15:39:26', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0304-14')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0304-14'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0304-15', 'ENTRADA', 'censo_inicial', 790.7500,
  790.7500, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Abel Gutarra'),
  '2026-08-04 15:57:51', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0304-15')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0304-15'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0304-28', 'ENTRADA', 'censo_inicial', 790.7500,
  790.7500, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Abel Gutarra'),
  '2026-08-04 15:15:22', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0304-28')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0304-28'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0304-34', 'ENTRADA', 'censo_inicial', 1234.9000,
  1234.9000, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Montoya'),
  '2026-08-04 16:03:48', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0304-34')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0304-34'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0304-35', 'ENTRADA', 'censo_inicial', 1974.8300,
  1974.8300, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Montoya'),
  '2026-08-04 15:36:19', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0304-35')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0304-35'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0304-36', 'ENTRADA', 'censo_inicial', 1974.8500,
  1974.8500, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Montoya'),
  '2026-08-04 15:55:44', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0304-36')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0304-36'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, id_investigador_destinatario,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT 'IQF0708-119-21', 'ENTRADA', 'censo_inicial', 992.3900,
  992.3900, 'g',
  (SELECT id_investigador FROM investigador WHERE nombre = 'Juan Carlos Yacono'),
  '2026-08-05 16:18:41', '2026-08-05', u.id_usuario, 0
  FROM usuario u
  WHERE EXISTS (SELECT 1 FROM frasco f2
     WHERE f2.id_frasco = 'IQF0708-119-21')
    AND NOT EXISTS (SELECT 1 FROM kardex k
     WHERE k.id_frasco = 'IQF0708-119-21'
       AND k.motivo = 'censo_inicial')
  ORDER BY u.id_usuario LIMIT 1;

-- ─── informe: que entro, que no, y que no cuadra ────────────────
-- Un frasco cuya presentacion no existe en la base destino NO se
-- carga. Es deliberado: colgarlo de otra presentacion falsearia el
-- codigo con el que se declara a SUNAT.
DO $$
DECLARE
  v_falta TEXT;
  v_desborde TEXT;
BEGIN
  SELECT string_agg(x.cod, ', ') INTO v_falta FROM (VALUES
    ('IQF0102-111-98'),
    ('IQF0102-115-99'),
    ('IQF0102-112-100'),
    ('IQF0102-112-101'),
    ('IQF0102-115-105'),
    ('IQF0102-123-106'),
    ('IQF0102-123-107'),
    ('IQF0102-137-108'),
    ('IQF0102-137-109'),
    ('IQF0102-69-110'),
    ('IQF0102-69-111'),
    ('IQF0102-69-112'),
    ('IQF0102-69-113'),
    ('IQF0102-69-114'),
    ('IQF0102-69-116'),
    ('IQF0106-122-23'),
    ('IQF0106-122-24'),
    ('IQF0106-116-25'),
    ('IQF0106-134-26'),
    ('IQF0106-134-27'),
    ('IQF0108-104-27'),
    ('IQF0108-129-28'),
    ('IQF0108-129-29'),
    ('IQF0108-129-30'),
    ('IQF0108-120-34'),
    ('IQF0108-120-35'),
    ('IQF0108-120-36'),
    ('IQF0108-084-37'),
    ('IQF0605-132-34'),
    ('IQF0605-132-39'),
    ('IQF0605-132-40'),
    ('IQF0605-132-41'),
    ('IQF0605-098-43'),
    ('IQF0702-94-08'),
    ('IQF0702-105-09'),
    ('IQF0401-106-23'),
    ('IQF0401-125-24'),
    ('IQF0401-125-25'),
    ('IQF0401-125-26'),
    ('IQF0613-126-02'),
    ('IQF0501-33-03'),
    ('IQF0501-90-06'),
    ('IQF0501-100-07'),
    ('IQF0501-100-08'),
    ('IQF0502-35-01'),
    ('IQF0502-36-02'),
    ('IQF0612-53-03'),
    ('IQF0213-19-01'),
    ('IQF0213-20-02'),
    ('IQF0408-03-01'),
    ('IQF0408-04-03'),
    ('IQF0408-04-04'),
    ('IQF0708-119-35'),
    ('IQF0708-119-40'),
    ('IQF0708-119-41'),
    ('IQF0708-119-42'),
    ('IQF0708-119-43'),
    ('IQF0708-119-44'),
    ('IQF0708-119-45'),
    ('IQF0708-119-47'),
    ('IQF0708-119-49'),
    ('IQF0708-119-50'),
    ('IQF1122-95-01'),
    ('IQF1122-114-03'),
    ('IQF1122-130-04'),
    ('IQF1122-130-05'),
    ('IQF1122-130-06'),
    ('IQF1122-133-07'),
    ('IQF1123-27-05'),
    ('IQF0904-54-02'),
    ('IQF0106-124-32'),
    ('IQF0106-124-31'),
    ('IQF0106-124-33'),
    ('IQF0102-123-102'),
    ('IQF0102-123-103'),
    ('IQF0408-04-05'),
    ('IQF0308-44'),
    ('IQF0308-43'),
    ('IQF0308-45'),
    ('IQF0308-46'),
    ('IQF0308-48'),
    ('IQF0308-41'),
    ('IQF0308-42'),
    ('IQF0304-27'),
    ('IQF0304-33'),
    ('IQF0304-37'),
    ('IQF0304-11'),
    ('IQF0304-12'),
    ('IQF0304-13'),
    ('IQF0304-14'),
    ('IQF0304-15'),
    ('IQF0304-28'),
    ('IQF0304-34'),
    ('IQF0304-35'),
    ('IQF0304-36'),
    ('IQF0708-119-21')
  ) AS x(cod)
  WHERE NOT EXISTS (SELECT 1 FROM frasco f WHERE f.id_frasco = x.cod);
  IF v_falta IS NOT NULL THEN
    RAISE WARNING 'NO CARGADOS (su presentacion no existe en esta base): %',
      v_falta;
  END IF;

  SELECT string_agg(f.id_frasco || ' (' ||
           round(100 * f.peso_neto_actual_g / p.equivalencia_g) || '%%)', ', ')
    INTO v_desborde
    FROM frasco f
    JOIN lote l         ON l.id_lote = f.id_lote
    JOIN presentacion p ON p.id_presentacion = l.id_presentacion
   WHERE p.equivalencia_g > 0
     AND f.peso_neto_actual_g > p.equivalencia_g * 1.10;
  IF v_desborde IS NOT NULL THEN
    RAISE WARNING 'CONTENIDO MAYOR QUE EL NOMINAL DE SU PRESENTACION: %',
      v_desborde;
  END IF;
END;
$$;

-- ─── comprobación: la carga se revierte si algo no cuadra ─────────
DO $$
DECLARE v_malos INTEGER;
BEGIN
  SELECT count(*) INTO v_malos FROM frasco f
   WHERE f.peso_bruto_g IS NOT NULL AND f.tara_g IS NOT NULL
     AND f.peso_neto_inicial_g IS NOT NULL
     AND abs(f.peso_neto_inicial_g - (f.peso_bruto_g - f.tara_g)) > 0.05;
  IF v_malos > 0 THEN
    RAISE EXCEPTION 'ABORTADA: % frascos cuyo neto inicial no es bruto-tara',
      v_malos;
  END IF;
END;
$$;

INSERT INTO schema_migration (version, descripcion) VALUES ('012', '012_carga_censo_96_frascos.sql') ON CONFLICT DO NOTHING;

COMMIT;
