-- ═══════════════════════════════════════════════════════════════════════════
-- 011 · Los alias que la 005 no llegó a sembrar
--
-- POR QUÉ HACE FALTA ESTA MIGRACIÓN
--
-- La 005 siembra los alias con `JOIN insumo i ON i.id_insumo = v.id_insumo`:
-- solo inserta el alias SI EL INSUMO YA EXISTE. Cuando se aplicó, la base
-- tenía ocho insumos —los ácidos del primer censo— y los demás no existían
-- todavía. Sus alias se descartaron en silencio, y una migración aplicada no
-- vuelve a ejecutarse nunca.
--
-- El resultado es que el 2026-08-07, tras cargar el censo entero, DIEZ insumos
-- con 39 frascos entre ellos —más de la mitad del inventario— no se podían
-- encontrar por alias: el etanol, el metanol, el ácido nítrico, el acetato de
-- etilo, el anhídrido acético, el éter sulfúrico, el xileno, el óxido de
-- calcio y los dos carbonatos.
--
-- No es un fallo de la 005: es el patrón «semilla condicionada a un dato que
-- llega después, ejecutada una sola vez». Cada vez que entren insumos nuevos
-- hará falta una migración como esta, así que conviene que la lista viva
-- entera aquí y sea idempotente: se puede volver a aplicar sin duplicar nada.
--
-- De dónde salen los alias: de cómo escriben la sustancia el censo, la
-- etiqueta del fabricante y las fichas CONTROL DE REACTIVOS de ALL.DATA. No
-- se inventa ninguno — cada uno aparece literalmente en alguna de esas tres
-- fuentes, o es el nombre común con el que se pide en el laboratorio.
-- ═══════════════════════════════════════════════════════════════════════════

BEGIN;

SET LOCAL search_path TO iqbf, public, pg_catalog;

-- DISTINCT ON sobre la forma normalizada: «Anhidrido acetico» y «Anhídrido
-- acético» son el mismo alias para el buscador —normalizar_busqueda quita
-- tildes y mayúsculas— y el índice único lo rechazaría. El NOT EXISTS de abajo
-- solo mira lo que YA está en la tabla, no los duplicados de este mismo lote.
-- Se listan las dos grafías a propósito, para que se lean como las escribe el
-- laboratorio, y aquí se queda una.
INSERT INTO insumo_alias (id_insumo, alias, origen)
SELECT DISTINCT ON (v.id_insumo, normalizar_busqueda(v.alias))
       v.id_insumo, v.alias, 'censo'
  FROM (VALUES
    -- ── Los que la 005 ya contemplaba y no llegaron a entrar ──────────────
    ('IQF0106', 'HNO3'),
    ('IQF0106', 'Acido Nitrico'),
    ('IQF0106', 'Nítrico'),
    ('IQF0106', 'Nitric acid'),
    ('IQF0106', 'Acido Nitrico Ultrex'),

    ('IQF0304', 'Etanol'),
    ('IQF0304', 'Ethanol'),
    ('IQF0304', 'Etanol absoluto'),
    ('IQF0304', 'Alcohol etílico'),
    ('IQF0304', 'Alcohol Etílico Absoluto'),
    ('IQF0304', 'Ethanol absolute'),
    ('IQF0304', 'Etanolo'),
    ('IQF0304', 'Alcohol'),

    ('IQF0308', 'Metanol'),
    ('IQF0308', 'Methanol'),
    ('IQF0308', 'Alcohol metílico'),
    -- Las tres grafías con que ALL.DATA titula sus fichas de metanol.
    ('IQF0308', 'Alcohol metilico anhidro'),
    ('IQF0308', 'Alcohol metilico para análisis'),
    ('IQF0308', 'Metanol ACS'),

    -- ── Insumos que la 005 no contemplaba: entraron con el censo ──────────
    ('IQF0213', 'Anhidrido acetico'),
    ('IQF0213', 'Anhídrido acético'),
    ('IQF0213', 'Acetic anhydride'),

    ('IQF0408', 'Acetato de etilo'),
    ('IQF0408', 'Ethyl acetate'),
    ('IQF0408', 'Etilo acetato'),

    ('IQF0502', 'Eter sulfurico'),
    ('IQF0502', 'Éter sulfúrico'),
    -- Ojo: en el laboratorio «éter sulfúrico» y «éter dietílico» nombran la
    -- misma sustancia, pero aquí son DOS insumos con códigos SUNAT distintos
    -- (IQF0501 e IQF0502). El alias se pone en cada uno por separado: no se
    -- fusionan, porque lo que se declara es el código.
    ('IQF0502', 'Eter etilico'),

    ('IQF0612', 'Xileno'),
    ('IQF0612', 'Xylene'),
    ('IQF0612', 'Xylol'),

    ('IQF0904', 'Oxido de calcio'),
    ('IQF0904', 'Óxido de calcio'),
    ('IQF0904', 'Cal viva'),
    ('IQF0904', 'CaO'),

    ('IQF1122', 'Carbonato de sodio'),
    ('IQF1122', 'Carbonato de sodio anhidro'),
    ('IQF1122', 'Na2CO3'),
    ('IQF1122', 'Carbonato sódico'),

    ('IQF1123', 'Carbonato de potasio'),
    ('IQF1123', 'K2CO3'),
    ('IQF1123', 'Carbonato potásico')
  ) AS v(id_insumo, alias)
  JOIN insumo i ON i.id_insumo = v.id_insumo
 WHERE NOT EXISTS (
   SELECT 1 FROM insumo_alias a
    WHERE a.id_insumo = v.id_insumo
      AND normalizar_busqueda(a.alias) = normalizar_busqueda(v.alias)
 )
 ORDER BY v.id_insumo, normalizar_busqueda(v.alias), v.alias;

-- Deja constancia de los que SIGUEN sin alias, si los hay. No aborta: un
-- insumo sin alias se busca igual por su nombre y su código, solo que con
-- menos grafías. Pero conviene enterarse aquí y no cuando alguien no encuentre
-- un frasco que sí está.
DO $$
DECLARE
  v_sin_alias TEXT;
BEGIN
  SELECT string_agg(i.id_insumo || ' (' || i.nombre_comercial || ')', ', ')
    INTO v_sin_alias
    FROM insumo i
   WHERE i.estado = 'VIGENTE'
     AND NOT EXISTS (SELECT 1 FROM insumo_alias a WHERE a.id_insumo = i.id_insumo);

  IF v_sin_alias IS NOT NULL THEN
    RAISE WARNING 'Insumos vigentes SIN NINGUN ALIAS: %', v_sin_alias;
  END IF;
END
$$;

INSERT INTO schema_migration (version, descripcion)
VALUES ('011', 'Alias de los insumos que la 005 no llego a sembrar')
ON CONFLICT (version) DO NOTHING;

COMMIT;
