-- ═══════════════════════════════════════════════════════════════════
-- Migración 015: las cuatro taras que faltaban
--
-- QUÉ DESTRABA
--
-- La 014 dejó cuatro frascos con `tara_g` y `peso_neto_actual_g` en NULL
-- —saldo INDETERMINADO— porque su tara no constaba en la evidencia
-- fotográfica. Mientras siga en NULL, `fn_kardex_antes` calcula un
-- `saldo_resultante_g` nulo y el frasco no admite ningún movimiento: no
-- se puede consumir ni transferir. Esta migración les pone la tara y les
-- asienta el censo inicial.
--
-- FUENTE
--
-- Las hojas «CONTROL DE REACTIVOS FISCALIZADOS» de la Universidad de
-- Lima, campo «Peso del Frasco». Son las fichas en Excel, distintas de la
-- etiqueta manuscrita pegada al envase: por eso la 014 no las tuvo: no
-- estaban fotografiadas.
--
-- POR QUÉ SE CONFÍA EN ESTAS CIFRAS
--
-- Cada ficha se comprueba sola. El «Peso del Reactivo + Peso del Frasco»
-- del ingreso menos la tara tiene que dar el nominal del envase, y en las
-- cuatro da EXACTO:
--
--   IQF11126-42-03   1107.6 − 107.6 = 1000 g   (nominal 1 kg)
--   IQF11126-44-02    311.9 −  61.9 =  250 g   (nominal 250 g)
--   IQF11127-49-05   1111.1 − 111.1 = 1000 g   (nominal 1 kg)
--   IQF11127-96-01   1095.7 −  95.7 = 1000 g   (nominal 1 kg)
--
-- Y contra el RM04 de setiembre de 2025, restando la tara al bruto que
-- midió la RADWAG el 11/08/2026:
--
--   42-03   929.18 g  vs  929.00   (+0.18)
--   44-02   198.32 g  vs  197.50   (+0.82)
--   49-05   748.14 g  vs  751.23   (−3.09)  ← consumo real de once meses
--   96-01   986.16 g  vs  986.15   (+0.01)
--
-- Las diferencias positivas de décimas son humedad: el sulfato de sodio
-- anhidro y el permanganato son higroscópicos. No son consumo.
--
-- DOS CIFRAS QUE LA 014 DIO POR DUDOSAS Y AHORA SE CIERRAN
--
--   · 44-02: la 014 barajaba 69,4 / 80,0 / 62,72 g. Ninguna era. La ficha
--     oficial dice 61,9 g. Las cifras anteriores salían de la hoja
--     nº 1111-2D; esta ficha es la 1111-2B, que es la de este frasco.
--   · 96-01: la 014 dedujo «la tara no puede ser menor de 95,71 g».
--     La ficha dice 95,7 g. La deducción era correcta.
--
-- EL CASO IQF11126-42-03  (decisión del laboratorio, 14/08/2026)
--
-- Su ficha cierra en 901,36 g netos, pero la balanza y el RM04 coinciden
-- en ~929 g. La diferencia —27,82 g— es casi exactamente el consumo de
-- 27,64 g anotado el 4/6/2021, que el propio RM04 oficial no recogió:
-- declaró el PESO 1 de esa fila, no el PESO 2.
--
-- Se carga 929,18 g, que es lo que el frasco pesa hoy y lo que ya está
-- declarado. La fila de 2021 queda como consumo anotado y no ejecutado.
-- No se registra un ajuste de 27,64 g porque no hubo tal salida: inventar
-- el movimiento sería peor que dejar constancia del desajuste, y la
-- constancia queda en `observaciones` y aquí.
--
-- CÓMO ENTRA EL SALDO
--
-- Igual que en la 012 y la 014: el saldo no se escribe, lo sube un
-- movimiento 'censo_inicial' del kardex. `fn_frasco_guardia` prohíbe
-- tocar `peso_neto_actual_g` a mano, así que para sacarlo de NULL y
-- dejarlo en 0 se usa el mismo interruptor que usa `fn_kardex_despues`
-- (`iqbf.mov`), y se apaga acto seguido para que el resto de la
-- transacción vuelva a estar bajo guardia.
-- ═══════════════════════════════════════════════════════════════════

BEGIN;
SET LOCAL search_path TO iqbf, public, pg_catalog;

-- ── 1. Las taras leídas de las fichas ───────────────────────────────
DROP TABLE IF EXISTS tmp_tara_015;
CREATE TEMP TABLE tmp_tara_015 (
    id_frasco     varchar(40) PRIMARY KEY,
    tara          numeric(14,4) NOT NULL,
    bruto_ingreso numeric(14,4) NOT NULL,  -- para la autocomprobación
    nominal       numeric(14,4) NOT NULL,
    nota          text NOT NULL
) ON COMMIT DROP;

INSERT INTO tmp_tara_015 VALUES
    ('IQF11126-42-03', 107.6, 1107.6, 1000,
     'Tara 107,6 g de la ficha CONTROL DE REACTIVOS FISCALIZADOS nº 1111-3A '
     '(lote 61410, ingreso 1999). Neto 929,18 g con el bruto RADWAG de '
     '1036,78 g; el RM04 de setiembre de 2025 declara 929,00 g. ATENCIÓN: la '
     'ficha cierra en 901,36 g porque anota un consumo de 27,64 g el '
     '4/6/2021 que ni el RM04 ni la balanza reflejan. Se carga lo que pesa '
     'el frasco. Queda por aclarar con el laboratorio si esa salida existió.'),

    ('IQF11126-44-02', 61.9, 311.9, 250,
     'Tara 61,9 g de la ficha nº 1111-2B (presentación 250 g, ingreso 1999). '
     'Neto 198,32 g con el bruto RADWAG de 260,22 g; el RM04 de setiembre de '
     '2025 declara 197,50 g. Deja sin efecto las tres cifras contradictorias '
     'que registró la 014 (69,4 / 80,0 / 62,72): salían de la ficha 1111-2D, '
     'que es de otro frasco.'),

    ('IQF11127-49-05', 111.1, 1111.1, 1000,
     'Tara 111,1 g de la ficha nº 1112-5 (Riedel-de Haën, SUNAT 000049). '
     'Neto 748,14 g con el bruto RADWAG de 859,24 g; el RM04 de setiembre de '
     '2025 declara 751,23 g. Los 3,09 g de diferencia son consumo de once '
     'meses. La ficha registra a Alarcón en la mayoría de sus salidas.'),

    ('IQF11127-96-01', 95.7, 1095.7, 1000,
     'Tara 95,7 g de la ficha del frasco Merck (proveedor MERCK PERUANA '
     'S.A., ingreso 20/03/2018, solicitado por ALARCON). Neto 986,16 g con '
     'el bruto RADWAG de 1081,86 g; el RM04 de setiembre de 2025 declara '
     '986,15 g. SIGUE VENCIDO desde el 30/04/2021.');

-- ── 2. La autocomprobación es bloqueante ────────────────────────────
-- Si una tara no reconstruye el nominal del envase, es que se leyó mal.
-- Antes de que entre a un inventario fiscalizado, para el despliegue.
DO $$
DECLARE malas text;
BEGIN
    SELECT string_agg(t.id_frasco || ' (' || t.bruto_ingreso || ' − ' || t.tara
                      || ' = ' || (t.bruto_ingreso - t.tara)
                      || ', se esperaba ' || t.nominal || ')', '; ' ORDER BY t.id_frasco)
      INTO malas
      FROM tmp_tara_015 t
     WHERE t.bruto_ingreso - t.tara <> t.nominal;
    IF malas IS NOT NULL THEN
        RAISE EXCEPTION 'Migración 015: la tara no reconstruye el nominal en %', malas;
    END IF;
END $$;

-- Y la tara no puede ser mayor que lo que el frasco pesa hoy.
DO $$
DECLARE malas text;
BEGIN
    SELECT string_agg(f.id_frasco, ', ' ORDER BY f.id_frasco) INTO malas
      FROM frasco f JOIN tmp_tara_015 t ON t.id_frasco = f.id_frasco
     WHERE f.peso_bruto_g IS NULL OR f.peso_bruto_g < t.tara;
    IF malas IS NOT NULL THEN
        RAISE EXCEPTION 'Migración 015: la tara supera al bruto medido en %', malas;
    END IF;
END $$;

-- ── 3. Tara y saldo en cero ─────────────────────────────────────────
-- `peso_neto_inicial_g` hace de capacidad en `fn_kardex_antes`: si se
-- dejara por debajo del neto, la ENTRADA del censo sería rechazada. Se
-- fija al neto medido, misma convención que la 014.
SELECT set_config('iqbf.mov', '1', true);

UPDATE frasco f
   SET tara_g              = t.tara,
       peso_neto_inicial_g = f.peso_bruto_g - t.tara,
       peso_neto_actual_g  = 0,
       fuente_tara         = 'Ficha CONTROL DE REACTIVOS FISCALIZADOS, '
                             'campo «Peso del Frasco»',
       observaciones       = COALESCE(f.observaciones || ' — ', '') || t.nota
  FROM tmp_tara_015 t
 WHERE f.id_frasco = t.id_frasco
   AND f.tara_g IS NULL;          -- idempotencia: no repisa una tara ya puesta

-- Se apaga en cuanto termina el UPDATE: el resto de la transacción vuelve
-- a estar bajo `fn_frasco_guardia`.
SELECT set_config('iqbf.mov', '0', true);

-- ── 4. Censo inicial ────────────────────────────────────────────────
INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
  cantidad_registrada, unidad_registrada, curso,
  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)
SELECT f.id_frasco, 'ENTRADA', 'censo_inicial',
       f.peso_bruto_g - f.tara_g, f.peso_bruto_g - f.tara_g, 'g',
       'CENSO_TARAS_FICHAS_015',
       now(), CURRENT_DATE, u.id_usuario, 0
  FROM frasco f
  JOIN tmp_tara_015 t ON t.id_frasco = f.id_frasco
  CROSS JOIN LATERAL (SELECT id_usuario FROM usuario ORDER BY id_usuario LIMIT 1) u
 WHERE f.tara_g IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM kardex k
                    WHERE k.id_frasco = f.id_frasco AND k.motivo = 'censo_inicial');

-- ── 5. El lote de IQF11127-96-01 no era un lote ─────────────────────
-- La 014 guardó '1.06649.1000', que es el número de catálogo de Merck
-- impreso en la etiqueta. El lote real, según la ficha, es 'AM1023349 708'.
UPDATE lote l
   SET numero_lote = 'AM1023349 708'
  FROM frasco f
 WHERE f.id_frasco = 'IQF11127-96-01'
   AND l.id_lote = f.id_lote
   AND l.numero_lote = '1.06649.1000'
   AND NOT EXISTS (SELECT 1 FROM lote x
                    WHERE x.id_presentacion = l.id_presentacion
                      AND x.numero_lote = 'AM1023349 708');

-- ── 6. Verificación ─────────────────────────────────────────────────
DO $$
DECLARE
    sin_tara   text;
    mal_saldo  text;
    quedan     int;
BEGIN
    SELECT string_agg(t.id_frasco, ', ' ORDER BY t.id_frasco) INTO sin_tara
      FROM tmp_tara_015 t
      JOIN frasco f ON f.id_frasco = t.id_frasco
     WHERE f.tara_g IS NULL;
    IF sin_tara IS NOT NULL THEN
        RAISE EXCEPTION 'Migración 015: se quedaron sin tara %', sin_tara;
    END IF;

    -- El saldo tiene que ser exactamente bruto − tara, y lo tiene que
    -- haber puesto el kardex, no este script.
    SELECT string_agg(f.id_frasco || ' (' || COALESCE(f.peso_neto_actual_g::text, 'NULL')
                      || ' ≠ ' || (f.peso_bruto_g - f.tara_g) || ')', ', ' ORDER BY f.id_frasco)
      INTO mal_saldo
      FROM frasco f JOIN tmp_tara_015 t ON t.id_frasco = f.id_frasco
     WHERE f.peso_neto_actual_g IS DISTINCT FROM f.peso_bruto_g - f.tara_g;
    IF mal_saldo IS NOT NULL THEN
        RAISE EXCEPTION 'Migración 015: el saldo no cuadra con la pesada en %', mal_saldo;
    END IF;

    SELECT count(*) INTO quedan FROM frasco WHERE saldo_indeterminado;
    RAISE NOTICE 'Migración 015: 4 taras cargadas. Frascos con saldo indeterminado: %.', quedan;
END $$;

INSERT INTO schema_migration (version, descripcion)
VALUES ('015', '015_taras_de_las_fichas_fiscalizadas.sql')
ON CONFLICT DO NOTHING;

COMMIT;

-- ═══════════════════════════════════════════════════════════════════
-- PENDIENTE DEL LABORATORIO
-- ═══════════════════════════════════════════════════════════════════
-- 1. IQF11126-42-03: confirmar si el consumo de 27,64 g del 4/6/2021
--    ocurrió. Si ocurrió, falta explicar por qué el frasco pesa hoy lo
--    que pesaba antes de esa fila.
-- 2. IQF11126-42-03 figura con condicion_envase = 'Sellado', pero su
--    ficha registra consumos hasta 2021. Revisar la condición.
-- 3. IQF11127-96-01 sigue VENCIDO desde el 30/04/2021: decidir si se
--    declara para baja en vez de para uso.
-- 4. Custodio: las fichas apuntan a ALARCON en 96-01 (solicitante) y en
--    la mayoría de las salidas de 49-05. No se asigna aquí porque haría
--    falta confirmar a qué registro de `investigador` corresponde.
-- 5. Sigue sin cargarse IQF1413-1, único frasco con carpeta de evidencia
--    y sin registro. Falta leer sus fotos.
-- ═══════════════════════════════════════════════════════════════════
