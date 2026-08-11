-- ═══════════════════════════════════════════════════════════════════
-- Migración 014: los sólidos de SOLIDOS/Finales
--
-- FUENTE
--
-- Evidencia fotográfica en Drive: `IQF_evidencias/SOLIDOS/Finales/`,
-- una carpeta por frasco. De cada una se leyó:
--   · la balanza RADWAG PS 6100.X7.M — entrega BRUTO (tara = 0,00 g);
--   · la etiqueta del fabricante — producto, lote, capacidad, vencimiento;
--   · la ficha manuscrita CONTROL DE REACTIVOS — «Peso Frasco» es la tara.
--
-- Los códigos Alta SUNAT y las capacidades salen del registro oficial
-- `09.RM04 Setiembre 2025 SUNAT.xlsx`, hoja RDO, donde estos diez frascos
-- ya figuran declarados. Ese mismo archivo sirvió de contraste: el neto
-- que se obtiene de (bruto − tara) queda a menos de 7,3 g del stock
-- declarado al 30/09/2025 en los seis frascos con tara documentada. La
-- diferencia restante es consumo de once meses, no error de lectura.
--
-- OJO CON LOS CÓDIGOS
--
-- Las carpetas `IQF1126-40-01` y `IQF1127-49-05` tienen un dígito de
-- menos que la etiqueta pegada al frasco, que dice `IQF11126-40-01` y
-- `IQF11127-49-05`. Manda la etiqueta, y el RM04 la respalda.
--
-- CUATRO FRASCOS ENTRAN SIN SALDO
--
-- No se les fotografió la tara, o la evidencia se contradice. Entran con
-- `tara_g` y `peso_neto_actual_g` en NULL, es decir con saldo
-- INDETERMINADO: el frasco existe y se declara, pero `fn_kardex_antes`
-- impide moverlo hasta que el laboratorio registre su tara. Es preferible
-- a inventar un número que acabaría en una declaración a SUNAT.
-- ═══════════════════════════════════════════════════════════════════

BEGIN;
SET LOCAL search_path TO iqbf, public, pg_catalog;

SELECT setval(pg_get_serial_sequence('iqbf.lote', 'id_lote'),
              GREATEST(COALESCE((SELECT max(id_lote) FROM lote), 1), 1));

-- ── 1. Insumos nuevos ───────────────────────────────────────────────
INSERT INTO insumo (id_insumo, nombre_comercial, tipo, estado, unidad_base, densidad_variable)
SELECT v.id, v.nombre, 'SOLIDO', 'VIGENTE', 'g', FALSE
  FROM (VALUES
          ('IQF0705',  'Hidróxido De Calcio'),
          ('IQF1131',  'Cloruro De Amonio'),
          ('IQF11126', 'Permanganato De Potasio'),
          ('IQF11127', 'Sulfato De Sodio Anhidro'),
          ('IQF11128', 'Sulfato De Sodio 10-Hidrato')
       ) AS v(id, nombre)
 WHERE NOT EXISTS (SELECT 1 FROM insumo i WHERE i.id_insumo = v.id);

-- ── 2. Presentaciones ───────────────────────────────────────────────
-- Una por código Alta SUNAT, como en el resto del maestro: el id de la
-- presentación es <insumo>-<alta sin ceros> y el código va con sus seis
-- dígitos.
--
-- El id propuesto NO se da por hecho. Producción lleva cargas anteriores
-- a estas migraciones, y si ya existe una presentación con este código
-- SUNAT —aunque tenga otro id— hay que usar ESA y no crear una gemela:
-- dos presentaciones con el mismo código partirían la declaración en dos
-- filas. Por eso se resuelve el id y todo lo que sigue cuelga del
-- resuelto, no del propuesto.
DROP TABLE IF EXISTS tmp_pres_014;
CREATE TEMP TABLE tmp_pres_014 (
    id_propuesto varchar(40) PRIMARY KEY,
    id_insumo    varchar(20) NOT NULL,
    sunat        varchar(20) NOT NULL,
    capacidad    numeric(14,4) NOT NULL,
    id_resuelto  varchar(40)
) ON COMMIT DROP;

INSERT INTO tmp_pres_014 (id_propuesto, id_insumo, sunat, capacidad) VALUES
    ('IQF0705-39',  'IQF0705',  '000039', 1.0000),
    ('IQF1131-31',  'IQF1131',  '000031', 1.0000),
    ('IQF11126-40', 'IQF11126', '000040', 1.0000),
    ('IQF11126-41', 'IQF11126', '000041', 0.5000),
    ('IQF11126-42', 'IQF11126', '000042', 1.0000),
    ('IQF11126-43', 'IQF11126', '000043', 0.5000),
    ('IQF11126-44', 'IQF11126', '000044', 0.2500),
    ('IQF11127-49', 'IQF11127', '000049', 1.0000),
    ('IQF11127-96', 'IQF11127', '000096', 1.0000),
    ('IQF11128-51', 'IQF11128', '000051', 1.0000);

-- 2.a Reutilizar la presentación que ya exista, por código o por id.
UPDATE tmp_pres_014 t
   SET id_resuelto = p.id_presentacion
  FROM presentacion p
 WHERE normalizar_busqueda(p.codigo_bf_sunat) = normalizar_busqueda(t.sunat)
    OR p.id_presentacion = t.id_propuesto;

-- 2.b Crear solo las que de verdad faltan.
INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
                          codigo_presentacion, capacidad, unidad,
                          tipo_envase, peso_neto_kg, estado, equivalencia_g)
SELECT t.id_propuesto, t.id_insumo, t.sunat,
       -- `codigo_presentacion` tiene índice único propio: si el código ya
       -- está tomado por otra presentación, se deja en NULL antes que
       -- reventar la carga. El código SUNAT, que es el que declara, se
       -- conserva igual.
       CASE WHEN EXISTS (SELECT 1 FROM presentacion p
                          WHERE normalizar_busqueda(p.codigo_presentacion)
                              = normalizar_busqueda(t.sunat))
            THEN NULL ELSE t.sunat END,
       t.capacidad, 'kg', 'Botella', t.capacidad, 'VIGENTE', t.capacidad * 1000
  FROM tmp_pres_014 t
 WHERE t.id_resuelto IS NULL;

UPDATE tmp_pres_014 t SET id_resuelto = t.id_propuesto WHERE t.id_resuelto IS NULL;

-- 2.c Si algo quedó sin resolver, decirlo con nombre y apellido: un
--     despliegue no puede fallar dejando adivinar por qué.
DO $$
DECLARE sin_resolver text;
BEGIN
    SELECT string_agg(t.id_propuesto || ' (SUNAT ' || t.sunat || ')', ', ' ORDER BY t.id_propuesto)
      INTO sin_resolver
      FROM tmp_pres_014 t
     WHERE NOT EXISTS (SELECT 1 FROM presentacion p WHERE p.id_presentacion = t.id_resuelto);
    IF sin_resolver IS NOT NULL THEN
        RAISE EXCEPTION 'Migración 014: no se pudo crear ni encontrar la presentación de %', sin_resolver;
    END IF;
    RAISE NOTICE 'Migración 014: % presentaciones resueltas (% reutilizadas de las que ya había).',
        (SELECT count(*) FROM tmp_pres_014),
        (SELECT count(*) FROM tmp_pres_014 WHERE id_resuelto <> id_propuesto);
END $$;

-- Deja constancia de cada equivalencia en el log del despliegue: si algún
-- frasco acaba colgando de una presentación ajena, aquí se ve por qué.
DO $$
DECLARE fila record;
BEGIN
    FOR fila IN SELECT id_propuesto, id_resuelto, sunat FROM tmp_pres_014
                 WHERE id_resuelto <> id_propuesto ORDER BY id_propuesto
    LOOP
        RAISE NOTICE '  SUNAT % → se reutiliza % en lugar de crear %',
            fila.sunat, fila.id_resuelto, fila.id_propuesto;
    END LOOP;
END $$;

-- ── 3. Lotes ────────────────────────────────────────────────────────
-- `numero_lote` es el Charge/Lot impreso por el fabricante; donde la
-- etiqueta no lo trae queda NULL, no un marcador inventado.
DROP TABLE IF EXISTS tmp_lote_014;
CREATE TEMP TABLE tmp_lote_014 (
    id_propuesto varchar(40) NOT NULL,
    numero_lote  varchar(120),
    grado        varchar(120),
    caduca       date
) ON COMMIT DROP;

INSERT INTO tmp_lote_014 (id_propuesto, numero_lote, grado, caduca) VALUES
    ('IQF0705-39',  '82750',        'Q.P.',                          NULL),
    ('IQF1131-31',  'A136045 845',  'pro analysi ACS, ISO',          DATE '2013-08-31'),
    ('IQF11126-40', NULL,           'Q.P.',                          NULL),
    ('IQF11126-41', NULL,           'Q.P.',                          NULL),
    ('IQF11126-42', '61410',        'extra pure, 99-100,5 %',        NULL),
    ('IQF11126-43', NULL,           'Industrial / técnico',          NULL),
    ('IQF11126-44', 'S 57 VI 353',  'Industrial / técnico',          NULL),
    ('IQF11127-49', '13464',        'anhydrous, extra pure',         NULL),
    ('IQF11127-96', '1.06649.1000', 'EMSURE ACS, ISO, Reag. Ph Eur', DATE '2021-04-30'),
    ('IQF11128-51', '31449',        'für Analyse, Reag. ACS',        NULL);

INSERT INTO lote (id_presentacion, numero_lote, grado_pureza, fecha_caducidad, estado)
SELECT p.id_resuelto, t.numero_lote, t.grado, t.caduca, 'ACTIVO'
  FROM tmp_lote_014 t
  JOIN tmp_pres_014 p ON p.id_propuesto = t.id_propuesto
 WHERE NOT EXISTS (SELECT 1 FROM lote l
                    WHERE l.id_presentacion = p.id_resuelto
                      AND l.numero_lote IS NOT DISTINCT FROM t.numero_lote);

-- ── 4. Frascos ──────────────────────────────────────────────────────
-- Los seis con tara documentada nacen con saldo 0 y lo sube el kardex.
-- Los cuatro sin tara nacen con tara y saldo en NULL: saldo indeterminado.
INSERT INTO frasco (id_frasco, id_lote, peso_bruto_g, tara_g,
                    peso_neto_inicial_g, peso_neto_actual_g,
                    fuente_tara, fecha_pesaje, condicion_envase,
                    existe, estado, observaciones)
SELECT v.id_frasco, l.id_lote, v.bruto, v.tara,
       CASE WHEN v.tara IS NULL THEN NULL ELSE v.bruto - v.tara END,
       CASE WHEN v.tara IS NULL THEN NULL ELSE 0 END,
       v.fuente, TIMESTAMPTZ '2026-08-11 00:00:00-05', v.condicion,
       TRUE, 'EN_USO', v.nota
  FROM (VALUES
          ('IQF11126-40-01', 'IQF11126-40', 933.61::numeric,  759.1::numeric,
           'Ficha CONTROL DE REACTIVOS «Peso Frasco» / evidencia fotográfica',
           NULL::varchar,
           'Balanza RADWAG: bruto 933,61 g (tara 0,00). Ficha manuscrita nº 1111-1A, '
           'peso frasco 759,1 g. Neto 174,51 g, contra 173,03 g declarados en el RM04 '
           'de setiembre de 2025.'),

          ('IQF11126-41-02', 'IQF11126-41', 469.93,  97.7,
           'Ficha CONTROL DE REACTIVOS «Peso Frasco» / evidencia fotográfica',
           NULL,
           'Balanza RADWAG: bruto 469,93 g. Ficha nº 24, peso frasco 97,7 g. Neto '
           '372,23 g contra 372,10 g del RM04 de setiembre de 2025: 0,13 g de '
           'diferencia, la tara queda confirmada por partida doble.'),

          ('IQF11126-42-03', 'IQF11126-42', 1036.78, NULL,
           NULL,
           'Sellado',
           'SIN TARA. Frasco precintado con cinta, sin ficha de consumo abierta: no '
           'hay «Peso Frasco» que leer. Balanza RADWAG: bruto 1036,78 g. El RM04 de '
           'setiembre de 2025 lo declara con 929,00 g, así que la tara no puede ser '
           'menor de 107,78 g. Entra con saldo indeterminado hasta que se pese la tara.'),

          ('IQF11126-43-01', 'IQF11126-43', 669.79,  279.4,
           'Ficha CONTROL DE REACTIVOS «Peso Frasco» / evidencia fotográfica',
           NULL,
           'Permanganato TÉCNICO (ficha nº 1111-1B). Balanza RADWAG: bruto 669,79 g, '
           'peso frasco 279,4 g. Neto 390,39 g contra 388,60 g del RM04 de setiembre '
           'de 2025.'),

          ('IQF11126-44-02', 'IQF11126-44', 260.22,  NULL,
           NULL,
           NULL,
           'SIN TARA POR CONTRADICCIÓN. La ficha nº 1111-2D dice «Peso Frasco 69,4» y '
           'sobre la misma etiqueta hay escrito a mano «ENVASE 80.0»; el RM04 de '
           'setiembre de 2025 (197,50 g) implicaría 62,72 g. Tres cifras distintas. '
           'Balanza RADWAG: bruto 260,22 g. Entra con saldo indeterminado.'),

          ('IQF11127-49-05', 'IQF11127-49', 859.24,  NULL,
           NULL,
           NULL,
           'SIN TARA. No se fotografió la ficha de consumo. Balanza RADWAG: bruto '
           '859,24 g. El RM04 de setiembre de 2025 lo declara con 751,23 g, así que la '
           'tara no puede ser menor de 108,01 g. Hay un papel adhesivo amarillo con una '
           'cifra manuscrita que NO se pudo leer con seguridad. Saldo indeterminado.'),

          ('IQF11127-96-01', 'IQF11127-96', 1081.86, NULL,
           NULL,
           NULL,
           'SIN TARA. No se fotografió la ficha de consumo. Balanza RADWAG: bruto '
           '1081,86 g. El RM04 de setiembre de 2025 lo declara con 986,15 g, así que la '
           'tara no puede ser menor de 95,71 g. VENCIDO: la etiqueta Merck EMSURE '
           '1.06649.1000 marca vida útil mínima hasta 2021/04/30. Saldo indeterminado.'),

          ('IQF11128-51-02', 'IQF11128-51', 1156.91, 159.4,
           'Ficha CONTROL DE REACTIVOS «Peso Frasco» / evidencia fotográfica',
           NULL,
           'Sulfato de sodio hidratado (ficha nº 1112-2B). Balanza RADWAG: bruto '
           '1156,91 g, peso frasco 159,4 g. Neto 997,51 g contra 1000 g del RM04 de '
           'setiembre de 2025. ATENCIÓN: el RM04 lo lista como IQF11127-51-02; la '
           'etiqueta del frasco dice IQF11128-51-02 y es la que manda.'),

          ('IQF1131-31-03', 'IQF1131-31', 604.25, 200.5,
           'Ficha CONTROL DE REACTIVOS «Peso Frasco» / evidencia fotográfica',
           NULL,
           'Cloruro de amonio Merck (ficha nº 1116-3). Balanza RADWAG: bruto 604,25 g, '
           'peso frasco 200,5 g. Neto 403,75 g contra 411,04 g del RM04 de setiembre de '
           '2025. VENCIDO: la etiqueta marca 31.08.13.'),

          ('IQF0705-39-02', 'IQF0705-39', 745.76, 359.5,
           'Ficha CONTROL DE REACTIVOS «Peso Frasco» / evidencia fotográfica',
           NULL,
           'Hidróxido de calcio (ficha nº 2, lote 82750). Balanza RADWAG: bruto '
           '745,76 g, peso frasco 359,5 g. Neto 386,26 g contra 556,44 g del RM04 de '
           'setiembre de 2025: 170,18 g consumidos en once meses sin registrar.')
       ) AS v(id_frasco, id_pres, bruto, tara, fuente, condicion, nota)
  -- El lote se busca por presentación RESUELTA y por su número, no solo por
  -- la presentación: si ya había otros lotes colgando de ella, un join laxo
  -- daría un frasco por lote.
  JOIN tmp_pres_014 p ON p.id_propuesto = v.id_pres
  JOIN tmp_lote_014 t ON t.id_propuesto = v.id_pres
  JOIN lote l ON l.id_presentacion = p.id_resuelto
             AND l.numero_lote IS NOT DISTINCT FROM t.numero_lote
 WHERE NOT EXISTS (SELECT 1 FROM frasco f WHERE f.id_frasco = v.id_frasco);

-- ── 5. Saldo inicial de los que sí tienen tara ──────────────────────
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, curso,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT f.id_frasco, 'ENTRADA', 'censo_inicial',
       f.peso_bruto_g - f.tara_g, f.peso_bruto_g - f.tara_g, 'g',
       'CENSO_SOLIDOS_FINALES_014',
       now(), CURRENT_DATE, u.id_usuario, 0
  FROM frasco f
  CROSS JOIN LATERAL (SELECT id_usuario FROM usuario ORDER BY id_usuario LIMIT 1) u
 WHERE f.id_frasco IN ('IQF11126-40-01', 'IQF11126-41-02', 'IQF11126-43-01',
                       'IQF11128-51-02', 'IQF1131-31-03', 'IQF0705-39-02')
   AND f.tara_g IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM kardex k
                    WHERE k.id_frasco = f.id_frasco AND k.motivo = 'censo_inicial');

-- ── 6. Verificación ─────────────────────────────────────────────────
DO $$
DECLARE
    faltan       text;
    mal_saldo    text;
    indeterminados int;
    total        int;
BEGIN
    SELECT string_agg(v.id_frasco, ', ' ORDER BY v.id_frasco) INTO faltan
      FROM (VALUES ('IQF11126-40-01'), ('IQF11126-41-02'), ('IQF11126-42-03'),
                   ('IQF11126-43-01'), ('IQF11126-44-02'), ('IQF11127-49-05'),
                   ('IQF11127-96-01'), ('IQF11128-51-02'), ('IQF1131-31-03'),
                   ('IQF0705-39-02')) AS v(id_frasco)
     WHERE NOT EXISTS (SELECT 1 FROM frasco f WHERE f.id_frasco = v.id_frasco);
    IF faltan IS NOT NULL THEN
        RAISE EXCEPTION 'Migración 014: no se dieron de alta %. Falta lote o presentación.', faltan;
    END IF;

    SELECT string_agg(f.id_frasco, ', ' ORDER BY f.id_frasco) INTO mal_saldo
      FROM frasco f
     WHERE f.id_frasco IN ('IQF11126-40-01', 'IQF11126-41-02', 'IQF11126-43-01',
                           'IQF11128-51-02', 'IQF1131-31-03', 'IQF0705-39-02')
       AND f.peso_neto_actual_g IS DISTINCT FROM f.peso_bruto_g - f.tara_g;
    IF mal_saldo IS NOT NULL THEN
        RAISE EXCEPTION 'Migración 014: el saldo no coincide con la pesada en %', mal_saldo;
    END IF;

    SELECT count(*) INTO indeterminados
      FROM frasco
     WHERE id_frasco IN ('IQF11126-42-03', 'IQF11126-44-02',
                         'IQF11127-49-05', 'IQF11127-96-01')
       AND saldo_indeterminado;
    IF indeterminados <> 4 THEN
        RAISE EXCEPTION 'Migración 014: se esperaban 4 frascos con saldo indeterminado, hay %', indeterminados;
    END IF;

    SELECT count(*) INTO total FROM frasco;
    RAISE NOTICE 'Migración 014: 10 sólidos de Finales incorporados (4 sin tara). Inventario en % frascos.', total;
END $$;

INSERT INTO schema_migration (version, descripcion)
VALUES ('014', '014_solidos_finales_evidencia.sql')
ON CONFLICT DO NOTHING;

COMMIT;

-- ═══════════════════════════════════════════════════════════════════
-- PENDIENTE DEL LABORATORIO
-- ═══════════════════════════════════════════════════════════════════
-- 1. Pesar la tara de IQF11126-42-03, IQF11126-44-02, IQF11127-49-05 y
--    IQF11127-96-01. Hasta entonces no se les puede registrar consumo.
-- 2. IQF11126-44-02: decidir cuál de las tres cifras vale (69,4 / 80,0 / 62,72).
-- 3. IQF11128-51-02 vs IQF11127-51-02: corregir el RM04 o la etiqueta.
-- 4. Custodio: la evidencia fotográfica no lo registra en ninguno de los diez.
-- 5. IQF1131-31-05 aparece declarado en el RM04 de setiembre de 2025 y no
--    tiene carpeta de evidencia: ¿existe todavía?
-- 6. IQF0705-39-02 acumula 170,18 g de consumo no registrado desde 2025.
-- ═══════════════════════════════════════════════════════════════════
