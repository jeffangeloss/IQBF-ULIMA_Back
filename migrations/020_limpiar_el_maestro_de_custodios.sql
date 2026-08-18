-- ═══════════════════════════════════════════════════════════════════
-- Migración 020: dejar el maestro de custodios en una sola grafía
--
-- POR QUÉ EXISTE
--
-- El desplegable de custodios ofrece hoy veinte opciones, y nueve de
-- ellas no deberían estar. Conviven duplicados de la misma persona
-- escritos de dos formas —«PONCE» y «Silvia Ponce», «QUINO» y «Javier
-- Quino»— junto a cuatro filas que no son personas sino laboratorios o
-- un tipo de uso. Ninguna de las nueve tiene frascos: son residuo de
-- cargas anteriores.
--
-- Elegir custodio en una lista donde la mitad está en versales y la otra
-- no, y donde la misma persona sale dos veces, es una invitación al
-- error. Y el error aquí acaba en una declaración a SUNAT.
--
-- POR QUÉ NO LO ARREGLARON LA 018 NI LA 019
--
-- Ambas se escribieron contra los nombres de la base local, que NO son
-- los de producción: aquí figura «Lab. Docimasia» y allí «DOCIMASIA»;
-- aquí «Académico» y allí «ACADÉMICO». Al no coincidir el texto, esas
-- filas quedaron intactas. Esta migración se escribe contra los nombres
-- REALES de producción, y contempla además los locales para que aplique
-- igual en ambos sitios.
--
-- QUÉ NO TOCA
--
-- Ningún frasco cambia de custodio: los 109 ya cuelgan de la grafía
-- canónica. Si alguna de las nueve tuviera frascos —no los tiene en
-- producción, pero la migración no lo da por hecho— se trasladan antes
-- de inactivarla, nunca se pierden.
-- ═══════════════════════════════════════════════════════════════════

BEGIN;
SET LOCAL search_path TO iqbf, public, pg_catalog;

-- `ck_investigador_adscripcion` es NOT VALID desde la 009 y vuelve a
-- evaluarse en cada UPDATE. Ver la 018: se retira y se repone igual.
ALTER TABLE investigador DROP CONSTRAINT IF EXISTS ck_investigador_adscripcion;

DROP TABLE IF EXISTS tmp_limpieza_020;
CREATE TEMP TABLE tmp_limpieza_020 (
    nombre_actual varchar(120) PRIMARY KEY,
    accion        varchar(12) NOT NULL,   -- FUSIONAR | RENOMBRAR | INACTIVAR
    destino       varchar(120)
) ON COMMIT DROP;

INSERT INTO tmp_limpieza_020 (nombre_actual, accion, destino) VALUES
  -- duplicados en versales de una persona que ya existe con su nombre
  ('PONCE',                   'FUSIONAR',  'Silvia Ponce'),
  ('QUINO',                   'FUSIONAR',  'Javier Quino'),
  ('HERNANDEZ',               'FUSIONAR',  'W. Hernández'),
  ('VILLAGARCIA',             'FUSIONAR',  'H. Villagarcía'),
  ('CHASQUIBOL',              'FUSIONAR',  'N. Chasquibol'),
  ('SANABRIA',                'FUSIONAR',  'Jorge Sanabria'),
  -- persona sin duplicado: solo hay que escribirla bien
  ('ALARCON',                 'RENOMBRAR', 'Rafael Alarcón'),
  -- no son personas
  ('ACADÉMICO',               'INACTIVAR', NULL),
  ('ACADEMICO',               'INACTIVAR', NULL),
  ('Académico',               'INACTIVAR', NULL),
  ('Académico (lab Quimica)', 'INACTIVAR', NULL),
  ('DOCIMASIA',               'INACTIVAR', NULL),
  ('Lab. Docimasia',          'INACTIVAR', NULL),
  ('Lab Alimentos',           'INACTIVAR', NULL),
  ('Lab. Alimentos',          'INACTIVAR', NULL),
  ('ING. CIVIL',              'INACTIVAR', NULL),
  ('Ing. Civil',              'INACTIVAR', NULL);

-- ── 1. Guardar la grafía vieja como alias antes de retirarla ────────
INSERT INTO investigador_alias (alias, id_investigador, fuente)
SELECT t.nombre_actual, d.id_investigador, 'grafía retirada por la 020'
  FROM tmp_limpieza_020 t
  JOIN investigador v ON v.nombre = t.nombre_actual
  JOIN investigador d ON d.nombre = t.destino
 WHERE t.accion = 'FUSIONAR'
   AND NOT EXISTS (SELECT 1 FROM investigador_alias a WHERE a.alias = t.nombre_actual);

-- ── 2. Trasladar lo que cuelgue del duplicado ───────────────────────
-- En producción no cuelga nada, pero no se da por hecho.
UPDATE frasco f
   SET id_investigador = d.id_investigador
  FROM tmp_limpieza_020 t
  JOIN investigador v ON v.nombre = t.nombre_actual
  JOIN investigador d ON d.nombre = t.destino
 WHERE t.accion = 'FUSIONAR' AND f.id_investigador = v.id_investigador;

-- El KÁRDEX NO SE TOCA. `fn_kardex_inmutable` lo prohíbe, y con razón: un
-- asiento registra lo que ocurrió, incluido a qué ficha de investigador
-- se entregó el producto ese día. Reescribirlo para que apunte al nombre
-- nuevo sería falsear el histórico de un inventario fiscalizado.
--
-- Los asientos que apunten a una grafía retirada siguen apuntándola. Por
-- eso las filas se INACTIVAN y no se borran: la fila permanece, deja de
-- ofrecerse en el desplegable, y el kárdex conserva su referencia intacta.
-- Este intento de UPDATE tumbó el despliegue anterior.

-- ── 3. Renombrar a quien solo está mal escrito ──────────────────────
INSERT INTO investigador_alias (alias, id_investigador, fuente)
SELECT t.nombre_actual, i.id_investigador, 'grafía anterior al renombrado de la 020'
  FROM tmp_limpieza_020 t JOIN investigador i ON i.nombre = t.nombre_actual
 WHERE t.accion = 'RENOMBRAR'
   AND NOT EXISTS (SELECT 1 FROM investigador_alias a WHERE a.alias = t.nombre_actual);

UPDATE investigador i
   SET nombre = t.destino
  FROM tmp_limpieza_020 t
 WHERE t.accion = 'RENOMBRAR' AND i.nombre = t.nombre_actual
   AND NOT EXISTS (SELECT 1 FROM investigador x WHERE x.nombre = t.destino);

-- ── 4. Retirar del desplegable ──────────────────────────────────────
-- Inactivar, no borrar: el kárdex y el histórico pueden seguir
-- apuntándolas, y `ON DELETE RESTRICT` lo protege.
UPDATE investigador i
   SET estado = 'INACTIVO'
  FROM tmp_limpieza_020 t
 WHERE i.nombre = t.nombre_actual
   AND t.accion IN ('FUSIONAR', 'INACTIVAR')
   AND i.estado <> 'INACTIVO';

-- Los laboratorios colados en el maestro de laboratorios, igual.
UPDATE laboratorio SET estado = 'INACTIVO'
 WHERE nombre IN ('Académico', 'ACADÉMICO') AND estado <> 'INACTIVO';

-- ── 5. Reponer el check tal como estaba ─────────────────────────────
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ck_investigador_adscripcion') THEN
    ALTER TABLE investigador ADD CONSTRAINT ck_investigador_adscripcion
      CHECK (id_carrera IS NOT NULL OR id_laboratorio IS NOT NULL) NOT VALID;
  END IF;
END $$;

-- ── 6. Verificación ─────────────────────────────────────────────────
DO $$
DECLARE huerfanos int; activos_malos text; act int;
BEGIN
    SELECT count(*) INTO huerfanos
      FROM frasco f JOIN investigador i ON i.id_investigador = f.id_investigador
      JOIN tmp_limpieza_020 t ON t.nombre_actual = i.nombre;
    IF huerfanos > 0 THEN
        RAISE EXCEPTION 'Migración 020: % frascos siguen colgando de una grafía retirada.', huerfanos;
    END IF;

    SELECT string_agg(i.nombre, ', ') INTO activos_malos
      FROM investigador i JOIN tmp_limpieza_020 t ON t.nombre_actual = i.nombre
     WHERE i.estado = 'ACTIVO' AND t.accion IN ('FUSIONAR','INACTIVAR');
    IF activos_malos IS NOT NULL THEN
        RAISE EXCEPTION 'Migración 020: siguen activas %', activos_malos;
    END IF;

    SELECT count(*) INTO act FROM investigador WHERE estado = 'ACTIVO';
    RAISE NOTICE 'Migración 020: el desplegable queda en % custodios activos, todos personas y en una sola grafía.', act;
END $$;

INSERT INTO schema_migration (version, descripcion)
VALUES ('020', '020_limpiar_el_maestro_de_custodios.sql')
ON CONFLICT DO NOTHING;

COMMIT;
