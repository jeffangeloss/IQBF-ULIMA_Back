-- ═══════════════════════════════════════════════════════════════════
-- Migración 019: un laboratorio no es un custodio
--
-- POR QUÉ EXISTE
--
-- Cinco filas de `investigador` no son personas: son laboratorios o un
-- tipo de uso. Entre ellas figuran como custodio de 35 frascos.
--
--     Lab. Docimasia           14 frascos
--     Académico                12 frascos
--     Lab. Alimentos            5 frascos
--     Ing. Civil                3 frascos
--     Académico (lab Quimica)   1 frasco
--
-- Ante SUNAT responde una persona, no un laboratorio y menos aún una
-- categoría de uso. Mientras el sistema afirme que «Lab. Docimasia» es
-- el custodio de catorce frascos, está afirmando algo falso, y además
-- oculta el hueco: esos catorce parecen tener responsable cuando no lo
-- tienen.
--
-- EL MAPEO NO SE ADIVINA, LO CONFIRMAN LOS PROPIOS DATOS
--
-- De los 35 frascos, ocho ya traían laboratorio asignado, y en los ocho
-- coincide exactamente con lo que dice su falso custodio: los de
-- «Lab. Docimasia» apuntan a Docimasia, los de «Ing. Civil» a Ingeniería
-- Civil, y así. El campo de custodio venía cargando un dato de
-- laboratorio; esta migración lo devuelve a su sitio.
--
-- «Académico» no va a ningún laboratorio porque no es uno: es el tipo de
-- actividad, que desde la migración 017 tiene su propia tabla. Queda
-- anotado en las observaciones del frasco para no perderlo.
--
-- QUÉ CAMBIA EN PANTALLA
--
-- 35 frascos pasan a mostrarse SIN CUSTODIO, y el inventario los marcará
-- con la alerta que ya existe para eso. No es una regresión: es que el
-- hueco deja de estar tapado.
-- ═══════════════════════════════════════════════════════════════════

BEGIN;
SET LOCAL search_path TO iqbf, public, pg_catalog;

-- ── 1. El mapeo, explícito ──────────────────────────────────────────
DROP TABLE IF EXISTS tmp_mapa_019;
CREATE TEMP TABLE tmp_mapa_019 (
    falso_custodio varchar(120) PRIMARY KEY,
    laboratorio    varchar(120)   -- NULL = no es un laboratorio
) ON COMMIT DROP;

INSERT INTO tmp_mapa_019 (falso_custodio, laboratorio) VALUES
  ('Lab. Docimasia',          'Docimasia'),
  ('Lab. Alimentos',          'Laboratorio de Alimentos'),
  ('Ing. Civil',              'Ingeniería Civil'),
  ('Académico (lab Quimica)', 'Laboratorio de Química'),
  ('Académico',                NULL);

-- Si alguno de esos laboratorios no existiera, parar: mover un frasco a
-- un laboratorio inventado sería peor que dejarlo como está.
DO $$
DECLARE faltan text;
BEGIN
    SELECT string_agg(m.laboratorio, ', ') INTO faltan
      FROM tmp_mapa_019 m
     WHERE m.laboratorio IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM laboratorio l WHERE l.nombre = m.laboratorio);
    IF faltan IS NOT NULL THEN
        RAISE EXCEPTION 'Migración 019: no existen los laboratorios %', faltan;
    END IF;
END $$;

-- ── 2. Dejar constancia en cada frasco antes de moverlo ─────────────
UPDATE frasco f
   SET observaciones = COALESCE(f.observaciones || ' ', '') ||
       'CUSTODIO RETIRADO (migración 019): figuraba como «' || i.nombre ||
       '», que no es una persona sino ' ||
       CASE WHEN m.laboratorio IS NULL
            THEN 'un tipo de uso (académico). El uso queda registrado en el maestro de actividades.'
            ELSE 'el laboratorio «' || m.laboratorio || '», al que se traslada el frasco.'
       END || ' Queda SIN CUSTODIO hasta que se designe una persona responsable.'
  FROM investigador i
  JOIN tmp_mapa_019 m ON m.falso_custodio = i.nombre
 WHERE f.id_investigador = i.id_investigador;

-- ── 3. Trasladar al laboratorio que corresponde ─────────────────────
-- Solo donde está vacío: los ocho que ya lo traían coinciden, así que no
-- hay nada que sobrescribir.
UPDATE frasco f
   SET id_laboratorio_actual = l.id_laboratorio
  FROM investigador i
  JOIN tmp_mapa_019 m ON m.falso_custodio = i.nombre
  JOIN laboratorio l  ON l.nombre = m.laboratorio
 WHERE f.id_investigador = i.id_investigador
   AND f.id_laboratorio_actual IS NULL;

-- ── 4. «Académico» tampoco es un laboratorio ────────────────────────
UPDATE frasco f
   SET id_laboratorio_actual = NULL
  FROM laboratorio l
 WHERE l.id_laboratorio = f.id_laboratorio_actual
   AND l.nombre = 'Académico';

-- ── 5. Retirar el custodio falso ────────────────────────────────────
UPDATE frasco f
   SET id_investigador = NULL
  FROM investigador i
  JOIN tmp_mapa_019 m ON m.falso_custodio = i.nombre
 WHERE f.id_investigador = i.id_investigador;

-- ── 6. Inactivar las entradas que no son personas ───────────────────
-- No se borran: `ON DELETE RESTRICT` protege el histórico y el kárdex
-- puede seguir apuntándolas. Inactivar basta para que no vuelvan a
-- ofrecerse al asignar un custodio nuevo.
UPDATE investigador i
   SET estado = 'INACTIVO'
  FROM tmp_mapa_019 m
 WHERE i.nombre = m.falso_custodio;

UPDATE laboratorio SET estado = 'INACTIVO' WHERE nombre = 'Académico';

-- ── 7. Verificación ─────────────────────────────────────────────────
DO $$
DECLARE quedan int; sin_custodio int; activos int;
BEGIN
    SELECT count(*) INTO quedan
      FROM frasco f JOIN investigador i ON i.id_investigador = f.id_investigador
      JOIN tmp_mapa_019 m ON m.falso_custodio = i.nombre;
    IF quedan > 0 THEN
        RAISE EXCEPTION 'Migración 019: % frascos siguen con un custodio que no es persona.', quedan;
    END IF;

    SELECT count(*) INTO activos
      FROM investigador i JOIN tmp_mapa_019 m ON m.falso_custodio = i.nombre
     WHERE i.estado <> 'INACTIVO';
    IF activos > 0 THEN
        RAISE EXCEPTION 'Migración 019: quedan % entradas falsas activas.', activos;
    END IF;

    SELECT count(*) INTO sin_custodio
      FROM frasco WHERE id_investigador IS NULL AND estado <> 'DADO_DE_BAJA';
    RAISE NOTICE 'Migración 019: 35 frascos devueltos a su laboratorio y sin custodio.';
    RAISE NOTICE '  Frascos sin custodio en total: %. Ese es el hueco real que hay que cubrir.', sin_custodio;
END $$;

INSERT INTO schema_migration (version, descripcion)
VALUES ('019', '019_custodio_no_es_un_laboratorio.sql')
ON CONFLICT DO NOTHING;

COMMIT;

-- ═══════════════════════════════════════════════════════════════════
-- PENDIENTE
-- ═══════════════════════════════════════════════════════════════════
-- Designar una persona responsable para los frascos que quedan sin
-- custodio. No es un dato que esté escondido en ningún archivo: los
-- documentos del proyecto definen siete roles y ninguno se llama
-- «custodio», así que primero hay que decidir cuál de ellos ejerce esa
-- función. Es una decisión de organización, no de datos.
-- ═══════════════════════════════════════════════════════════════════
