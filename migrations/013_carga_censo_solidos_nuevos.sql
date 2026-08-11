-- ═══════════════════════════════════════════════════════════════════
-- Migración 013: cierre del censo — los últimos frascos
--
-- POR QUÉ EXISTE ESTA MIGRACIÓN
--
-- La 012 quedó registrada en `schema_migration` de producción antes de
-- que se le añadiera el frasco IQF0304-31. El runner (`app/cli.py`)
-- omite toda migración ya registrada, así que ese frasco nunca llegó a
-- la nube: por eso el inventario desplegado muestra 96 y no 97. Una
-- migración aplicada es inmutable en la práctica; lo que falta se agrega
-- en una migración nueva, no editando la anterior.
--
-- QUÉ AGREGA
--
--   1. IQF0304-31  — Etanol absoluto EMSURE 2.5 L (Docimasia, W. Hernández).
--                    Varado en la 012 por lo dicho arriba.
--   2. IQF0708-141-01 — Hidróxido de sodio, sólido. Presentación nueva.
--   3. IQF1138-128-03 — Cloruro de calcio dihidrato. Insumo nuevo.
--
-- Con estos tres el censo queda CERRADO: no hay más sólidos ni más
-- líquidos por incorporar.
--
-- CÓMO ENTRA EL SALDO
--
-- Los frascos nacen con peso_neto_actual_g = 0 y es un movimiento
-- 'censo_inicial' del kardex el que sube el saldo, porque
-- `fn_frasco_guardia` prohíbe escribirlo a mano. Mismo patrón que la 012:
-- si la carga falla a medias no queda inventario fantasma.
-- ═══════════════════════════════════════════════════════════════════

BEGIN;
SET LOCAL search_path TO iqbf, public, pg_catalog;

-- ── 0. Las secuencias vienen desalineadas de cargas anteriores.
SELECT setval(pg_get_serial_sequence('iqbf.lote', 'id_lote'),
              GREATEST(COALESCE((SELECT max(id_lote) FROM lote), 1), 1));

-- ── 1. Insumo nuevo: cloruro de calcio dihidrato ────────────────────
INSERT INTO insumo (id_insumo, nombre_comercial, tipo, estado,
                    unidad_base, densidad_variable)
SELECT 'IQF1138', 'Cloruro De Calcio Dihidrato', 'SOLIDO', 'VIGENTE', 'g', FALSE
 WHERE NOT EXISTS (SELECT 1 FROM insumo WHERE id_insumo = 'IQF1138');

-- ── 2. Presentaciones nuevas ────────────────────────────────────────
-- Los índices únicos son sobre el código normalizado, no sobre la
-- columna: por eso se comprueba con NOT EXISTS y no con ON CONFLICT.
--
-- Nota para el laboratorio: el censo trae IQF0708-141 en litros pese a
-- ser un sólido. Se declara en kg para no romper la conversión ni
-- quedar desalineada con IQF0708-119, que es el mismo insumo. La
-- equivalencia en gramos —que es la que manda— no cambia: 1000 g.
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
                          codigo_presentacion, capacidad, unidad,
                          tipo_envase, peso_neto_kg, estado, equivalencia_g)
SELECT 'IQF0708-141', 'IQF0708', '000141', '000141', 1.0000, 'kg',
       'botella de PLASTICO', 1.00000, 'VIGENTE', 1000.0000
 WHERE NOT EXISTS (SELECT 1 FROM presentacion WHERE id_presentacion = 'IQF0708-141')
   AND NOT EXISTS (SELECT 1 FROM presentacion
                    WHERE normalizar_busqueda(codigo_bf_sunat) = normalizar_busqueda('000141')
                       OR normalizar_busqueda(codigo_presentacion) = normalizar_busqueda('000141'));

INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
                          codigo_presentacion, capacidad, unidad,
                          tipo_envase, peso_neto_kg, estado, equivalencia_g)
SELECT 'IQF1138-128', 'IQF1138', NULL, '000128', 2.5000, 'kg',
       'envase de plástico', 2.50000, 'VIGENTE', 2500.0000
 WHERE NOT EXISTS (SELECT 1 FROM presentacion WHERE id_presentacion = 'IQF1138-128')
   AND NOT EXISTS (SELECT 1 FROM presentacion
                    WHERE normalizar_busqueda(codigo_presentacion) = normalizar_busqueda('000128'));

-- ── 3. Lotes de los dos sólidos nuevos ──────────────────────────────
INSERT INTO lote (id_presentacion, numero_lote, fecha_ingreso, estado)
SELECT 'IQF0708-141', 'HC28806541', DATE '2024-06-26', 'ACTIVO'
 WHERE NOT EXISTS (SELECT 1 FROM lote
                    WHERE id_presentacion = 'IQF0708-141'
                      AND numero_lote IS NOT DISTINCT FROM 'HC28806541');

INSERT INTO lote (id_presentacion, numero_lote, fecha_ingreso, estado)
SELECT 'IQF1138-128', 'K55311478 326', DATE '2025-02-06', 'ACTIVO'
 WHERE NOT EXISTS (SELECT 1 FROM lote
                    WHERE id_presentacion = 'IQF1138-128'
                      AND numero_lote IS NOT DISTINCT FROM 'K55311478 326');

-- ── 4. Frascos, con saldo en 0 ──────────────────────────────────────

-- 4.a IQF0304-31 · el que se quedó varado en la 012.
INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,
  id_laboratorio_actual, precision_ubicacion, peso_bruto_g, tara_g,
  peso_neto_inicial_g, peso_neto_actual_g, volumen_inicial_ml,
  fuente_tara, fecha_pesaje, condicion_envase, existe, estado, observaciones)
SELECT 'IQF0304-31', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'W. Hernández'),
  (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'C1-N2-P20'),
  (SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Docimasia'),
  'exacta — por adhesivo naranja', 3220.5500, 1247.8000, 1972.7500, 0,
  2497.1519, 'Etiqueta interna / evidencia fotográfica',
  TIMESTAMPTZ '2026-08-05 00:00:00-05', 'Sellado', TRUE, 'EN_USO',
  'Etanol absoluto EMSURE 2.5 L, catálogo 1.00983.2500, asignado al laboratorio '
  'DOCIMASIA (etiqueta blanca manuscrita en el hombro). Evidencia fotográfica '
  'conciliada: Sellado. Bruto 3220.55 g, tara 1247.79 g, neto físico 1972.76 g. '
  'Incorporado por la migración 013 porque la 012 ya estaba registrada en producción.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0304-2-5L'
   AND l.numero_lote IS NOT DISTINCT FROM 'I1366383 433'
   AND NOT EXISTS (SELECT 1 FROM frasco WHERE id_frasco = 'IQF0304-31');

-- 4.b IQF0708-141-01 · hidróxido de sodio, sólido.
INSERT INTO frasco (id_frasco, id_lote, id_investigador, peso_bruto_g, tara_g,
  peso_neto_inicial_g, peso_neto_actual_g, fuente_tara, fecha_pesaje,
  condicion_envase, existe, estado, observaciones)
SELECT 'IQF0708-141-01', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Académico'),
  1109.9400, 109.4000, 1000.5400, 0,
  'Etiqueta manuscrita / evidencia fotográfica día 2',
  TIMESTAMPTZ '2026-08-11 00:00:00-05', 'Sellado', TRUE, 'EN_USO',
  'Censo día 2. La balanza RADWAG entrega bruto (tara = 0); la tara procede de '
  'la etiqueta. Bruto 1109.94 g, tara 109.40 g, neto 1000.54 g.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF0708-141'
   AND l.numero_lote IS NOT DISTINCT FROM 'HC28806541'
   AND NOT EXISTS (SELECT 1 FROM frasco WHERE id_frasco = 'IQF0708-141-01');

-- 4.c IQF1138-128-03 · cloruro de calcio dihidrato.
INSERT INTO frasco (id_frasco, id_lote, id_investigador, peso_bruto_g, tara_g,
  peso_neto_inicial_g, peso_neto_actual_g, fuente_tara, fecha_pesaje,
  condicion_envase, existe, estado, observaciones)
SELECT 'IQF1138-128-03', l.id_lote,
  (SELECT id_investigador FROM investigador WHERE nombre = 'Silvia Ponce'),
  2899.0700, 406.1000, 2492.9700, 0,
  'Etiqueta manuscrita / evidencia fotográfica día 2',
  TIMESTAMPTZ '2026-08-11 00:00:00-05', 'Sellado', TRUE, 'EN_USO',
  'Censo día 2. La balanza RADWAG entrega bruto (tara = 0); la tara procede de '
  'la etiqueta. Bruto 2899.07 g, tara 406.10 g, neto 2492.97 g. La presentación '
  'no tiene código SUNAT asignado: queda fuera de v_declaracion_sunat hasta que '
  'el laboratorio lo confirme.'
  FROM lote l
 WHERE l.id_presentacion = 'IQF1138-128'
   AND l.numero_lote IS NOT DISTINCT FROM 'K55311478 326'
   AND NOT EXISTS (SELECT 1 FROM frasco WHERE id_frasco = 'IQF1138-128-03');

-- ── 5. Saldo inicial: un movimiento de censo por frasco ─────────────
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, curso,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT v.id_frasco, 'ENTRADA', 'censo_inicial', v.neto_g, v.neto_g, 'g',
       'CIERRE_CENSO_013', now(), CURRENT_DATE, u.id_usuario, 0
  FROM (VALUES
          ('IQF0304-31',     1972.7500::numeric),
          ('IQF0708-141-01', 1000.5400::numeric),
          ('IQF1138-128-03', 2492.9700::numeric)
       ) AS v(id_frasco, neto_g)
  CROSS JOIN LATERAL (SELECT id_usuario FROM usuario ORDER BY id_usuario LIMIT 1) u
 WHERE EXISTS (SELECT 1 FROM frasco f WHERE f.id_frasco = v.id_frasco)
   AND NOT EXISTS (SELECT 1 FROM kardex k
                    WHERE k.id_frasco = v.id_frasco
                      AND k.motivo = 'censo_inicial');

-- ── 6. Verificación: los tres frascos con su saldo puesto ───────────
DO $$
DECLARE
    faltan   text;
    descuadre text;
    total    int;
BEGIN
    SELECT string_agg(v.id_frasco, ', ' ORDER BY v.id_frasco) INTO faltan
      FROM (VALUES ('IQF0304-31'), ('IQF0708-141-01'), ('IQF1138-128-03')) AS v(id_frasco)
     WHERE NOT EXISTS (SELECT 1 FROM frasco f WHERE f.id_frasco = v.id_frasco);
    IF faltan IS NOT NULL THEN
        RAISE EXCEPTION 'Migración 013: no se pudo dar de alta %. Falta su lote o presentación.', faltan;
    END IF;

    SELECT string_agg(v.id_frasco, ', ' ORDER BY v.id_frasco) INTO descuadre
      FROM (VALUES
              ('IQF0304-31',     1972.7500::numeric),
              ('IQF0708-141-01', 1000.5400::numeric),
              ('IQF1138-128-03', 2492.9700::numeric)
           ) AS v(id_frasco, neto_g)
      JOIN frasco f ON f.id_frasco = v.id_frasco
     WHERE f.peso_neto_actual_g IS DISTINCT FROM v.neto_g;
    IF descuadre IS NOT NULL THEN
        RAISE EXCEPTION 'Migración 013: saldo distinto al pesado en %', descuadre;
    END IF;

    SELECT count(*) INTO total FROM frasco;
    RAISE NOTICE 'Migración 013: censo cerrado. Inventario en % frascos.', total;
END $$;

INSERT INTO schema_migration (version, descripcion)
VALUES ('013', '013_carga_censo_solidos_nuevos.sql')
ON CONFLICT DO NOTHING;

COMMIT;

-- ═══════════════════════════════════════════════════════════════════
-- Frascos del día 2 que NO entran aquí porque la 012 ya los cargó con
-- estas mismas pesadas: IQF0708-119-{21,35,40,41,42,43,44,45,47,49,50},
-- IQF0904-54-02, IQF1122-{114-03,130-04,130-05,130-06,133-07,95-01},
-- IQF1123-27-05. Verificado contra una réplica de producción levantada
-- con las migraciones 000→012.
-- ═══════════════════════════════════════════════════════════════════
