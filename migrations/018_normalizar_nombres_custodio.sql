-- ═══════════════════════════════════════════════════════════════════
-- Migración 018: normalizar los nombres de custodio
--
-- POR QUÉ EXISTE
--
-- Filtrar el inventario por custodio hoy no agrupa bien. En las fuentes
-- del laboratorio el mismo apellido aparece de hasta siete formas
-- distintas —«Ponce», «PONCE», «SILVIA PONCE»; «Yacono», «Prof. Yacono»,
-- «JUAN CARLOS YACONO»— y la tabla `investigador` heredó la grafía que
-- venía en el censo, que no siempre es la más completa.
--
-- Un filtro por «Chasquibol» debe devolver los 21 frascos, no partirlos
-- en dos listas según cómo se escribió el nombre ese día.
--
-- QUÉ HACE
--
--   1. Renombra a la forma canónica, que es LA MÁS COMPLETA hallada en
--      alguna fuente. Dos de ellas salieron de los comentarios de celda
--      de las fichas «CONTROL DE REACTIVOS», que nadie había leído:
--
--        Sanabria   → Jorge Sanabria      («Soporte: Solicitado por
--                                           Jorge Sanabria», 9 celdas)
--        La Cruz    → Jonatan La Cruz     (10 celdas; una lo escribe
--                                           «Jonaran», errata)
--
--   2. Crea `investigador_alias`, para que la grafía vieja siga
--      encontrando a la persona. Mismo patrón que `insumo_alias`: la
--      búsqueda se resuelve en la base, no en el cliente.
--
-- QUÉ NO HACE, Y POR QUÉ
--
-- No toca las cinco filas de `investigador` que NO son personas:
-- «Académico», «Académico (lab Quimica)», «Ing. Civil», «Lab. Alimentos»
-- y «Lab. Docimasia», que entre ellas tienen 35 frascos asignados.
--
-- Esas cinco no se arreglan renombrando: hay que mover esos frascos a su
-- laboratorio y dejar el custodio VACÍO, porque un laboratorio no
-- responde ante SUNAT por un bien fiscalizado —responde una persona—.
-- Eso hace que 35 frascos pasen a mostrarse sin custodio, que es la
-- verdad pero es un cambio visible, y va en su propia migración con su
-- propia decisión detrás.
-- ═══════════════════════════════════════════════════════════════════

BEGIN;
SET LOCAL search_path TO iqbf, public, pg_catalog;

-- ── 1. Alias: la grafía vieja sigue encontrando a la persona ────────
CREATE TABLE IF NOT EXISTS investigador_alias (
    alias            VARCHAR(120) PRIMARY KEY,
    id_investigador  INTEGER NOT NULL
      REFERENCES investigador(id_investigador) ON DELETE CASCADE,
    fuente           VARCHAR(60)
);

COMMENT ON TABLE investigador_alias IS
  'Grafías históricas de cada custodio. Permite que una búsqueda por '
  '«Chasquibol» o «CHASQUIBOL» encuentre a N. Chasquibol.';

-- ── 2. Renombrar a la forma canónica ────────────────────────────────
-- El alias se guarda ANTES del rename, con el nombre que había.
DROP TABLE IF EXISTS tmp_canon_018;
CREATE TEMP TABLE tmp_canon_018 (
    actual   varchar(120),
    canonico varchar(120),
    fuente   varchar(60)
) ON COMMIT DROP;

INSERT INTO tmp_canon_018 (actual, canonico, fuente) VALUES
  ('Chasquibol', 'N. Chasquibol',      'etiqueta del frasco y ficha del laboratorio'),
  ('Sanabria',   'Jorge Sanabria',     'comentario de celda de la ficha'),
  ('La Cruz',    'Jonatan La Cruz',    'comentario de celda de la ficha'),
  ('Quino',      'Javier Quino',       'etiqueta del frasco y comentario de la ficha');

-- 2.a Guardar la grafía vieja como alias, y también las variantes
--     conocidas en mayúscula que aparecen en las fuentes.
INSERT INTO investigador_alias (alias, id_investigador, fuente)
SELECT t.actual, i.id_investigador, t.fuente
  FROM tmp_canon_018 t JOIN investigador i ON i.nombre = t.actual
 WHERE NOT EXISTS (SELECT 1 FROM investigador_alias a WHERE a.alias = t.actual);

INSERT INTO investigador_alias (alias, id_investigador, fuente)
SELECT upper(t.actual), i.id_investigador, t.fuente
  FROM tmp_canon_018 t JOIN investigador i ON i.nombre = t.actual
 WHERE upper(t.actual) <> t.actual
   AND NOT EXISTS (SELECT 1 FROM investigador_alias a WHERE a.alias = upper(t.actual));

-- 2.b Renombrar.
UPDATE investigador i
   SET nombre = t.canonico
  FROM tmp_canon_018 t
 WHERE i.nombre = t.actual
   AND NOT EXISTS (SELECT 1 FROM investigador x WHERE x.nombre = t.canonico);

-- ── 3. Alias de las que ya estaban bien ─────────────────────────────
-- No cambian de nombre, pero sus variantes deben encontrarlas igual.
INSERT INTO investigador_alias (alias, id_investigador, fuente)
SELECT v.alias, i.id_investigador, 'variantes halladas en las fuentes'
  FROM (VALUES
          ('PONCE',              'Silvia Ponce'),
          ('Ponce',              'Silvia Ponce'),
          ('SILVIA PONCE',       'Silvia Ponce'),
          ('CHASQUIBOL',         'N. Chasquibol'),
          ('N. CHASQUIBOL',      'N. Chasquibol'),
          ('CHASQUIBOLL',        'N. Chasquibol'),
          ('YACONO',             'Juan Carlos Yacono'),
          ('Yacono',             'Juan Carlos Yacono'),
          ('Prof. Yacono',       'Juan Carlos Yacono'),
          ('PROF. YACONO',       'Juan Carlos Yacono'),
          ('Juan Yacono',        'Juan Carlos Yacono'),
          ('ABEL GUTARRA',       'Abel Gutarra'),
          ('A. GUTARRA',         'Abel Gutarra'),
          ('Gutarra',            'Abel Gutarra'),
          ('VILLAGARCIA',        'H. Villagarcía'),
          ('Villagarcía',        'H. Villagarcía'),
          ('H. VILLAGARCIA',     'H. Villagarcía'),
          ('HERNANDEZ',          'W. Hernández'),
          ('Hernandez',          'W. Hernández'),
          ('W. Hernandez',       'W. Hernández'),
          ('SANABRIA',           'Jorge Sanabria'),
          ('Jonaran La Cruz',    'Jonatan La Cruz'),
          ('LA CRUZ',            'Jonatan La Cruz'),
          ('QUINO',              'Javier Quino'),
          ('JAVIER QUINO',       'Javier Quino'),
          ('MONTOYA',            'Montoya'),
          ('MUEDAS',             'Muedas')
       ) AS v(alias, canonico)
  JOIN investigador i ON i.nombre = v.canonico
 WHERE NOT EXISTS (SELECT 1 FROM investigador_alias a WHERE a.alias = v.alias);

-- ── 4. Búsqueda por custodio, con alias ─────────────────────────────
-- Devuelve el investigador tanto si se escribe su nombre canónico como
-- cualquiera de sus grafías históricas, ignorando mayúsculas y tildes.
CREATE OR REPLACE FUNCTION fn_investigador_coincide(
    p_id_investigador integer, p_nombre varchar, p_buscar text
) RETURNS boolean
LANGUAGE sql STABLE
SET search_path TO iqbf, pg_catalog
AS $$
  SELECT p_buscar IS NULL OR p_buscar = ''
      OR normalizar_busqueda(p_nombre) LIKE '%' || normalizar_busqueda(p_buscar) || '%'
      OR EXISTS (
           SELECT 1 FROM investigador_alias a
            WHERE a.id_investigador = p_id_investigador
              AND normalizar_busqueda(a.alias) LIKE '%' || normalizar_busqueda(p_buscar) || '%'
         );
$$;

-- ── 5. Verificación ─────────────────────────────────────────────────
DO $$
DECLARE sin_canon text; n_alias int; dup int;
BEGIN
    SELECT string_agg(t.actual, ', ') INTO sin_canon
      FROM tmp_canon_018 t
     WHERE EXISTS (SELECT 1 FROM investigador i WHERE i.nombre = t.actual);
    IF sin_canon IS NOT NULL THEN
        RAISE EXCEPTION 'Migración 018: no se renombraron %', sin_canon;
    END IF;

    SELECT count(*) INTO dup FROM (
        SELECT nombre FROM investigador GROUP BY nombre HAVING count(*) > 1
    ) d;
    IF dup > 0 THEN
        RAISE EXCEPTION 'Migración 018: el rename dejó % nombres duplicados.', dup;
    END IF;

    SELECT count(*) INTO n_alias FROM investigador_alias;
    RAISE NOTICE 'Migración 018: 4 custodios renombrados, % alias registrados.', n_alias;
    RAISE NOTICE '  Siguen pendientes 5 filas de investigador que no son personas (35 frascos).';
END $$;

INSERT INTO schema_migration (version, descripcion)
VALUES ('018', '018_normalizar_nombres_custodio.sql')
ON CONFLICT DO NOTHING;

COMMIT;

-- ═══════════════════════════════════════════════════════════════════
-- PENDIENTE
-- ═══════════════════════════════════════════════════════════════════
-- 1. Las cinco filas de `investigador` que son áreas o usos, con sus
--    frascos, esperan decisión:
--
--      Lab. Docimasia          14 frascos  → laboratorio «Docimasia»
--      Académico               12 frascos  → no es lab: es tipo de uso
--      Lab. Alimentos           5 frascos  → «Laboratorio de Alimentos»
--      Ing. Civil               3 frascos  → «Ingeniería Civil»
--      Académico (lab Quimica)  1 frasco   → «Laboratorio de Química»
--
--    Los cuatro laboratorios ya existen en la tabla `laboratorio`.
-- 2. `laboratorio` tiene el mismo problema al revés: «Académico» figura
--    como laboratorio y no lo es.
-- 3. Completar el nombre de pila de Montoya, Muedas, H. Villagarcía,
--    W. Hernández y N. Chasquibol con la relación de personal.
-- ═══════════════════════════════════════════════════════════════════
