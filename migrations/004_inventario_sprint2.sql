BEGIN;

SET LOCAL search_path TO iqbf, public, pg_catalog;

-- ═══════════════════════════════════════════════════════════════════════════
-- 004 · Inventario físico y trazabilidad de consumo (Sprint 2)
--
-- Cierra las brechas que MODELO_DATOS_IQBF_V4.md §4 detectó entre el esquema
-- vigente y las historias P0 del backlog. Es incremental y repetible: no borra
-- frascos, movimientos, censo ni evidencias.
--
--   D1  el saldo desconocido se guardaba como 0            → US-26, US-28
--   D3  el kardex no congelaba la unidad registrada        → US-20
--   D5  el estado del frasco mezclaba inventario y física  → US-03, US-27
--   --  la ubicación no era consultable                    → US-03, US-11
--   --  nada impedía consumir del frasco ajeno             → US-13
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── 1 · Ubicación con la estructura real del almacén ──────────────────────
-- El cuadrito naranja numerado del hombro del frasco es la POSICIÓN en el
-- armario, no un código de fabricante. La ubicación se lee siempre por el
-- nombre de la puerta («ÁCIDOS FUERTES»), nunca por «la del medio».

ALTER TABLE ubicacion
    ADD COLUMN IF NOT EXISTS casillero     INTEGER,
    ADD COLUMN IF NOT EXISTS nombre_puerta VARCHAR(80),
    ADD COLUMN IF NOT EXISTS nivel         INTEGER,
    ADD COLUMN IF NOT EXISTS posicion      VARCHAR(20);

COMMENT ON COLUMN ubicacion.posicion IS
  'Adhesivo naranja del hombro del frasco: posición dentro del armario.';

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'uq_ubicacion_fisica'
  ) THEN
    ALTER TABLE ubicacion ADD CONSTRAINT uq_ubicacion_fisica
      UNIQUE (id_establecimiento, casillero, nivel, posicion);
  END IF;
END;
$$;


-- ─── 2 · El frasco: ubicación, condición física y linaje del peso ──────────

ALTER TABLE frasco
    ADD COLUMN IF NOT EXISTS id_ubicacion        INTEGER
        REFERENCES ubicacion(id_ubicacion) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS precision_ubicacion VARCHAR(80),
    ADD COLUMN IF NOT EXISTS condicion_envase    VARCHAR(20),
    ADD COLUMN IF NOT EXISTS fecha_pesaje        TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS fuente_tara         VARCHAR(200),
    ADD COLUMN IF NOT EXISTS existe              BOOLEAN;

-- D5: la condición del envase es cosa distinta del estado de inventario.
-- Un frasco «Sellado» puede estar «DADO_DE_BAJA» por vencido.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'ck_frasco_condicion_envase'
  ) THEN
    ALTER TABLE frasco ADD CONSTRAINT ck_frasco_condicion_envase
      CHECK (condicion_envase IS NULL OR condicion_envase IN
        ('Sellado', 'Abierto', 'A la mitad', 'Agotado', 'Dañado', 'Residuo'));
  END IF;
END;
$$;

COMMENT ON COLUMN frasco.condicion_envase IS
  'Condición física del envase (lista cerrada del censo). No es el estado de '
  'inventario: ese es frasco.estado.';
COMMENT ON COLUMN frasco.fuente_tara IS
  'De dónde salió la tara. Orden de confianza: ficha manuscrita del frasco, '
  'fichas CONTROL DE REACTIVOS, columna del censo. Nunca la de otro frasco.';


-- ─── 3 · D1 · el saldo desconocido deja de ser cero ────────────────────────
-- Sin tara el neto es INDETERMINADO, nunca 0. Un 0 afirma «no queda nada» y
-- acaba en una declaración a SUNAT; un NULL es una pregunta abierta.

ALTER TABLE frasco ALTER COLUMN peso_neto_actual_g DROP NOT NULL;
ALTER TABLE frasco ALTER COLUMN peso_neto_actual_g DROP DEFAULT;

ALTER TABLE frasco
    ADD COLUMN IF NOT EXISTS saldo_indeterminado BOOLEAN
        GENERATED ALWAYS AS (peso_neto_actual_g IS NULL) STORED;

COMMENT ON COLUMN frasco.peso_neto_actual_g IS
  'Saldo vigente. NULL = indeterminado (falta la tara). Solo lo escribe el '
  'trigger de kardex.';


-- ─── 4 · D3 · el kardex congela la conversión ──────────────────────────────
-- US-20 pide literalmente «guarda el valor usado». Si mañana se corrige la
-- densidad de un lote, los consumos históricos no pueden reinterpretarse.

ALTER TABLE kardex
    ADD COLUMN IF NOT EXISTS cantidad_registrada   NUMERIC(14,4),
    ADD COLUMN IF NOT EXISTS unidad_registrada     VARCHAR(4),
    ADD COLUMN IF NOT EXISTS id_investigador_origen INTEGER
        REFERENCES investigador(id_investigador),
    ADD COLUMN IF NOT EXISTS cantidad_kg           NUMERIC(14,6)
        GENERATED ALWAYS AS (cantidad_g / 1000.0) STORED;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'ck_kardex_unidad_registrada'
  ) THEN
    ALTER TABLE kardex ADD CONSTRAINT ck_kardex_unidad_registrada
      CHECK (unidad_registrada IS NULL
             OR unidad_registrada IN ('g', 'kg', 'mL', 'L'));
  END IF;

  -- Si se registró en volumen, la densidad aplicada es obligatoria: sin ella
  -- la conversión a kg no es auditable.
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'ck_kardex_volumen_exige_densidad'
  ) THEN
    ALTER TABLE kardex ADD CONSTRAINT ck_kardex_volumen_exige_densidad
      CHECK (unidad_registrada IS NULL
             OR unidad_registrada NOT IN ('mL', 'L')
             OR densidad_aplicada IS NOT NULL);
  END IF;
END;
$$;

COMMENT ON COLUMN kardex.cantidad_registrada IS
  'Cantidad tal como la tecleó el operario, en su unidad. cantidad_g es su '
  'conversión con densidad_aplicada, congelada en este movimiento.';


-- ─── 5 · Guardia de saldo indeterminado ────────────────────────────────────
-- Sustituye a fn_kardex_antes añadiendo dos reglas y conservando las tres que
-- ya tenía (densidad obligatoria en líquidos, saldo insuficiente, capacidad).

CREATE OR REPLACE FUNCTION fn_kardex_antes() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
  v_saldo      NUMERIC(14,4);
  v_capacidad  NUMERIC(14,4);
  v_tipo       VARCHAR(10);
  v_custodio   INTEGER;
  v_signo      INTEGER;
BEGIN
  SELECT f.peso_neto_actual_g, f.peso_neto_inicial_g, i.tipo, f.id_investigador
    INTO v_saldo, v_capacidad, v_tipo, v_custodio
    FROM frasco f
    JOIN lote l         ON l.id_lote = f.id_lote
    JOIN presentacion p ON p.id_presentacion = l.id_presentacion
    JOIN insumo i       ON i.id_insumo = p.id_insumo
   WHERE f.id_frasco = NEW.id_frasco
   FOR UPDATE OF f;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'El frasco % no existe', NEW.id_frasco;
  END IF;

  -- NUEVA · D1: no se mueve lo que no se sabe cuánto es.
  IF v_saldo IS NULL THEN
    RAISE EXCEPTION
      'El frasco % tiene saldo indeterminado (falta la tara): registre la tara '
      'antes de mover producto', NEW.id_frasco
      USING ERRCODE = 'check_violation';
  END IF;

  IF NEW.densidad_aplicada IS NULL THEN
    SELECT COALESCE(l.densidad, p.densidad)
      INTO NEW.densidad_aplicada
      FROM frasco f
      JOIN lote l         ON l.id_lote = f.id_lote
      JOIN presentacion p ON p.id_presentacion = l.id_presentacion
     WHERE f.id_frasco = NEW.id_frasco;
  END IF;

  IF v_tipo = 'LIQUIDO' AND NEW.densidad_aplicada IS NULL THEN
    RAISE EXCEPTION 'Falta la densidad para el frasco % (liquido).',
      NEW.id_frasco;
  END IF;

  -- NUEVA · US-13: un consumo solo descuenta de los frascos de su custodio.
  IF NEW.tipo_movimiento = 'SALIDA'
     AND NEW.motivo = 'consumo_laboratorio'
     AND NEW.id_investigador_origen IS NOT NULL
     AND v_custodio IS NOT NULL
     AND NEW.id_investigador_origen <> v_custodio THEN
    RAISE EXCEPTION
      'El frasco % está bajo custodia de otro investigador: use una '
      'transferencia de custodia antes de consumirlo', NEW.id_frasco
      USING ERRCODE = 'check_violation';
  END IF;

  v_signo := CASE NEW.tipo_movimiento
               WHEN 'ENTRADA' THEN 1
               WHEN 'SALIDA' THEN -1
               ELSE 0
             END;

  IF v_signo = -1 AND NEW.cantidad_g > v_saldo THEN
    RAISE EXCEPTION
      'Saldo insuficiente en el frasco %: quedan % g y se intentan retirar % g',
      NEW.id_frasco, v_saldo, NEW.cantidad_g;
  END IF;

  NEW.peso_antes_g  := v_saldo;
  NEW.saldo_resultante_g := v_saldo + (v_signo * NEW.cantidad_g);
  NEW.peso_despues_g := NEW.saldo_resultante_g;

  IF v_signo = 1
     AND v_capacidad IS NOT NULL
     AND NEW.saldo_resultante_g > v_capacidad THEN
    RAISE EXCEPTION
      'El frasco % no admite % g: quedaria con % g y su capacidad es % g',
      NEW.id_frasco, NEW.cantidad_g, NEW.saldo_resultante_g, v_capacidad;
  END IF;

  RETURN NEW;
END;
$$;


-- ─── 6 · Código SUNAT sin ambigüedad de ceros ──────────────────────────────
-- `0000122` y `000122` son DOS grupos distintos en el rollup de US-21: parten
-- la declaración en dos mitades y ninguna cuadra con el registro de SUNAT. En
-- el censo aparecen 17 filas con esa errata.
--
-- La regla ataca ese fallo y solo ese: un código **numérico** debe tener
-- exactamente 6 dígitos. Los códigos con letras no se tocan — el proyecto
-- admite códigos internos alfanuméricos y los compara sin distinguir
-- mayúsculas, y esta migración no está para cambiar esa decisión.
--
-- NOT VALID a propósito: no rechaza las filas que ya estaban, sí las nuevas.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'ck_presentacion_sunat_6'
  ) THEN
    ALTER TABLE presentacion ADD CONSTRAINT ck_presentacion_sunat_6
      CHECK (
        codigo_bf_sunat IS NULL
        OR codigo_bf_sunat !~ '^[0-9]+$'   -- lleva letras: no es un código SUNAT
        OR codigo_bf_sunat ~ '^[0-9]{6}$'  -- es numérico: exactamente 6 dígitos
      )
      NOT VALID;
  END IF;
END;
$$;


-- ─── 7 · Vistas de explotación ─────────────────────────────────────────────

CREATE OR REPLACE VIEW v_inventario_v4 AS
SELECT
    f.id_frasco,
    i.id_insumo,
    i.nombre_comercial,
    i.tipo,
    p.id_presentacion,
    p.codigo_bf_sunat,
    p.concentracion,
    p.capacidad,
    p.unidad,
    p.tipo_envase,
    p.equivalencia_g               AS contenido_nominal_g,
    l.id_lote,
    l.numero_lote,
    l.grado_pureza,
    l.fecha_ingreso,
    l.fecha_caducidad,
    f.peso_bruto_g,
    f.tara_g,
    f.peso_neto_inicial_g,
    f.peso_neto_actual_g,
    f.saldo_indeterminado,
    f.fuente_tara,
    f.fecha_pesaje,
    f.condicion_envase,
    f.estado                       AS estado_frasco,
    f.observaciones,
    inv.id_investigador,
    inv.nombre                     AS custodio,
    u.id_ubicacion,
    u.nombre                       AS ubicacion,
    u.casillero,
    u.nombre_puerta,
    u.nivel,
    u.posicion,
    f.precision_ubicacion,
    COALESCE(l.densidad, p.densidad) AS densidad_aplicable,
    CASE
      WHEN i.tipo = 'LIQUIDO'
       AND COALESCE(l.densidad, p.densidad) IS NOT NULL
       AND f.peso_neto_actual_g IS NOT NULL
      THEN round(f.peso_neto_actual_g / COALESCE(l.densidad, p.densidad), 4)
    END                            AS volumen_actual_ml,
    CASE
      WHEN p.equivalencia_g IS NULL OR p.equivalencia_g = 0 THEN NULL
      WHEN f.peso_neto_actual_g IS NULL THEN NULL
      ELSE round(f.peso_neto_actual_g / p.equivalencia_g, 4)
    END                            AS fraccion_llenado,
    CASE
      WHEN l.fecha_caducidad IS NULL           THEN 'POR_CONFIRMAR'
      WHEN l.fecha_caducidad < CURRENT_DATE    THEN 'VENCIDO'
      WHEN l.fecha_caducidad < CURRENT_DATE + 90 THEN 'POR_VENCER'
      ELSE 'VIGENTE'
    END                            AS estado_caducidad,
    mov.ultimo_movimiento,
    CASE
      WHEN mov.ultimo_movimiento IS NULL THEN NULL
      ELSE (CURRENT_DATE - mov.ultimo_movimiento::date)
    END                            AS dias_sin_movimiento
  FROM frasco f
  JOIN lote l              ON l.id_lote = f.id_lote
  JOIN presentacion p      ON p.id_presentacion = l.id_presentacion
  JOIN insumo i            ON i.id_insumo = p.id_insumo
  LEFT JOIN investigador inv ON inv.id_investigador = f.id_investigador
  LEFT JOIN ubicacion u      ON u.id_ubicacion = f.id_ubicacion
  LEFT JOIN LATERAL (
        SELECT max(k.fecha_hora) AS ultimo_movimiento
          FROM kardex k
         WHERE k.id_frasco = f.id_frasco
  ) mov ON TRUE;

COMMENT ON VIEW v_inventario_v4 IS
  'Inventario operativo: frasco, custodio, ubicación, saldo y vigencia.';


-- La alerta de saldo indeterminado va POR DELANTE de la de vencido: un saldo
-- que no se conoce es peor que uno vencido, porque el vencido al menos se sabe.
CREATE OR REPLACE VIEW v_alertas_v4 AS
SELECT v.*,
       CASE
         WHEN v.saldo_indeterminado                        THEN '0-SALDO_INDETERMINADO'
         WHEN v.estado_caducidad = 'VENCIDO'               THEN '1-VENCIDO'
         WHEN v.tipo = 'LIQUIDO'
          AND v.densidad_aplicable IS NULL                 THEN '2-DENSIDAD_PENDIENTE'
         WHEN v.codigo_bf_sunat IS NULL                    THEN '3-SIN_CODIGO_SUNAT'
         WHEN v.id_investigador IS NULL                    THEN '4-SIN_CUSTODIO'
         WHEN v.estado_caducidad = 'POR_VENCER'            THEN '5-POR_VENCER'
         WHEN v.dias_sin_movimiento >= 730                 THEN '6-DORMIDO'
         WHEN v.peso_neto_actual_g = 0
          AND v.estado_frasco <> 'AGOTADO'                 THEN '7-REVISAR_ESTADO'
         ELSE '8-SIN_ALERTA'
       END AS alerta_prioritaria
  FROM v_inventario_v4 v;


-- US-21 · el rollup que produce la declaración, en kg y por código SUNAT.
CREATE OR REPLACE VIEW v_declaracion_sunat AS
SELECT
    v.codigo_bf_sunat,
    v.id_insumo,
    max(v.nombre_comercial)                    AS nombre_comercial,
    max(v.tipo)                                AS tipo,
    count(*)                                   AS frascos,
    count(*) FILTER (WHERE v.saldo_indeterminado) AS frascos_indeterminados,
    round(sum(v.peso_neto_actual_g) / 1000.0, 4)  AS saldo_kg,
    round(sum(v.peso_neto_actual_g)
            FILTER (WHERE v.estado_caducidad = 'VENCIDO') / 1000.0, 4)
                                               AS saldo_vencido_kg
  FROM v_inventario_v4 v
 WHERE v.estado_frasco <> 'DADO_DE_BAJA'
   AND v.codigo_bf_sunat IS NOT NULL
 GROUP BY v.codigo_bf_sunat, v.id_insumo;

COMMENT ON VIEW v_declaracion_sunat IS
  'US-21. frascos_indeterminados advierte cuántos frascos NO están sumados en '
  'saldo_kg por faltarles la tara: la cifra es un mínimo, no un total.';


CREATE OR REPLACE VIEW v_saldo_investigador_v4 AS
SELECT
    inv.id_investigador,
    inv.nombre                                 AS custodio,
    count(v.id_frasco)                         AS frascos,
    count(*) FILTER (WHERE v.estado_caducidad = 'VENCIDO') AS frascos_vencidos,
    count(*) FILTER (WHERE v.saldo_indeterminado)          AS frascos_indeterminados,
    round(COALESCE(sum(v.peso_neto_actual_g), 0) / 1000.0, 4) AS saldo_kg
  FROM investigador inv
  LEFT JOIN v_inventario_v4 v
         ON v.id_investigador = inv.id_investigador
        AND v.estado_frasco <> 'DADO_DE_BAJA'
 GROUP BY inv.id_investigador, inv.nombre;


CREATE INDEX IF NOT EXISTS ix_frasco_investigador ON frasco (id_investigador);
CREATE INDEX IF NOT EXISTS ix_frasco_ubicacion    ON frasco (id_ubicacion);
CREATE INDEX IF NOT EXISTS ix_kardex_frasco_fecha ON kardex (id_frasco, fecha_hora DESC);
CREATE INDEX IF NOT EXISTS ix_lote_presentacion   ON lote (id_presentacion);


INSERT INTO schema_migration (version, descripcion)
VALUES (
  '004',
  'Inventario fisico: ubicacion, condicion de envase, saldo indeterminado, '
  'kardex trazable y vistas de declaracion'
)
ON CONFLICT (version) DO NOTHING;

COMMIT;
