BEGIN;

SET LOCAL search_path TO iqbf, public, pg_catalog;

-- Reconciliación con la entrega madre Core V3 del 24-07-2026. Se conservan
-- las extensiones posteriores de identidad, alcance y auditoría, pero se
-- recuperan las reglas químicas y atributos que no podían perderse.
ALTER TABLE insumo
    ADD COLUMN IF NOT EXISTS densidad_variable BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE lote
    ADD COLUMN IF NOT EXISTS numero_factura VARCHAR(80);

DO $$
BEGIN
  IF NOT EXISTS (
      SELECT 1 FROM pg_constraint
       WHERE conrelid = 'insumo'::regclass
         AND conname = 'ck_insumo_densidad_variable'
  ) THEN
    ALTER TABLE insumo
      ADD CONSTRAINT ck_insumo_densidad_variable
      CHECK (NOT densidad_variable OR tipo = 'LIQUIDO');
  END IF;
END
$$;

UPDATE insumo
   SET densidad_variable = id_insumo IN ('IQF0102', 'IQF0106')
 WHERE id_insumo IN ('IQF0102', 'IQF0106')
    OR densidad_variable;

-- Densidades de lote verificadas en IQBF Core V3. La clave técnica y la
-- presentación se verifican juntas para no aplicar un valor a otro lote.
UPDATE lote l
   SET densidad = fuente.densidad
  FROM (
    VALUES
      (1,  'IQF0102-107', 1.180000::numeric),
      (2,  'IQF0102-107', 1.180000::numeric),
      (3,  'IQF0102-110', 1.180000::numeric),
      (4,  'IQF0102-111', 1.180000::numeric),
      (5,  'IQF0102-112', 1.180000::numeric),
      (6,  'IQF0102-112', 1.180000::numeric),
      (7,  'IQF0102-112', 1.180000::numeric),
      (8,  'IQF0102-115', 1.192000::numeric),
      (9,  'IQF0102-115', 1.192000::numeric),
      (10, 'IQF0102-115', 1.192000::numeric),
      (11, 'IQF0102-137', 1.180000::numeric),
      (12, 'IQF0102-140', 1.180000::numeric),
      (13, 'IQF0102-143', 1.180000::numeric),
      (14, 'IQF0102-69',  1.180000::numeric),
      (15, 'IQF0102-69',  1.180000::numeric),
      (16, 'IQF0106-109', 1.392000::numeric),
      (17, 'IQF0106-116', 1.390000::numeric),
      (18, 'IQF0106-116', 1.390000::numeric),
      (19, 'IQF0106-122', 1.410000::numeric),
      (20, 'IQF0106-122', 1.410000::numeric),
      (24, 'IQF0106-134', 1.392000::numeric),
      (25, 'IQF0106-134', 1.392000::numeric),
      (26, 'IQF0106-138', 1.410000::numeric),
      (27, 'IQF0106-138', 1.410000::numeric)
  ) AS fuente(id_lote, id_presentacion, densidad)
 WHERE l.id_lote = fuente.id_lote
   AND l.id_presentacion = fuente.id_presentacion;

-- Las versiones creadas por la interpretación anterior no se borran:
-- quedan cerradas y auditables, pero dejan de ser valores vigentes.
UPDATE densidad_vigencia d
   SET vigencia_hasta = DATE '2026-07-23'
  FROM presentacion p
  JOIN insumo i ON i.id_insumo = p.id_insumo
 WHERE d.id_presentacion = p.id_presentacion
   AND (i.tipo = 'SOLIDO' OR i.densidad_variable)
   AND d.vigencia_desde <= DATE '2026-07-23'
   AND (d.vigencia_hasta IS NULL
        OR d.vigencia_hasta > DATE '2026-07-23');

UPDATE presentacion p
   SET densidad = NULL,
       actualizado_en = now()
  FROM insumo i
 WHERE i.id_insumo = p.id_insumo
   AND (i.tipo = 'SOLIDO' OR i.densidad_variable)
   AND p.densidad IS NOT NULL;

CREATE OR REPLACE FUNCTION fn_validar_densidad_presentacion_core()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path TO iqbf, pg_catalog, pg_temp
AS $$
DECLARE
  v_tipo insumo.tipo%TYPE;
  v_variable insumo.densidad_variable%TYPE;
BEGIN
  SELECT tipo, densidad_variable
    INTO v_tipo, v_variable
    FROM insumo
   WHERE id_insumo = NEW.id_insumo;

  IF v_tipo = 'SOLIDO' AND NEW.densidad IS NOT NULL THEN
    RAISE EXCEPTION 'Un solido no debe tener densidad en PRESENTACION';
  END IF;
  IF v_tipo = 'LIQUIDO' AND v_variable AND NEW.densidad IS NOT NULL THEN
    RAISE EXCEPTION
      'El insumo % tiene densidad variable; registre la densidad en LOTE',
      NEW.id_insumo;
  END IF;
  IF v_tipo = 'LIQUIDO' AND NOT v_variable AND NEW.densidad IS NULL THEN
    RAISE EXCEPTION
      'El liquido % requiere densidad fija en PRESENTACION',
      NEW.id_insumo;
  END IF;
  RETURN NEW;
END
$$;

DROP TRIGGER IF EXISTS tg_presentacion_densidad_core ON presentacion;
CREATE TRIGGER tg_presentacion_densidad_core
BEFORE INSERT OR UPDATE OF id_insumo, densidad ON presentacion
FOR EACH ROW EXECUTE FUNCTION fn_validar_densidad_presentacion_core();

CREATE OR REPLACE FUNCTION fn_validar_densidad_lote_core()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path TO iqbf, pg_catalog, pg_temp
AS $$
DECLARE
  v_tipo insumo.tipo%TYPE;
  v_variable insumo.densidad_variable%TYPE;
BEGIN
  SELECT i.tipo, i.densidad_variable
    INTO v_tipo, v_variable
    FROM presentacion p
    JOIN insumo i ON i.id_insumo = p.id_insumo
   WHERE p.id_presentacion = NEW.id_presentacion;

  IF (v_tipo = 'SOLIDO' OR NOT v_variable) AND NEW.densidad IS NOT NULL THEN
    RAISE EXCEPTION
      'La densidad del lote solo aplica a liquidos con densidad variable';
  END IF;
  RETURN NEW;
END
$$;

DROP TRIGGER IF EXISTS tg_lote_densidad_core ON lote;
CREATE TRIGGER tg_lote_densidad_core
BEFORE INSERT OR UPDATE OF id_presentacion, densidad ON lote
FOR EACH ROW EXECUTE FUNCTION fn_validar_densidad_lote_core();

CREATE OR REPLACE FUNCTION fn_validar_densidad_vigencia_core()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path TO iqbf, pg_catalog, pg_temp
AS $$
DECLARE
  v_tipo insumo.tipo%TYPE;
  v_variable insumo.densidad_variable%TYPE;
BEGIN
  SELECT i.tipo, i.densidad_variable
    INTO v_tipo, v_variable
    FROM presentacion p
    JOIN insumo i ON i.id_insumo = p.id_insumo
   WHERE p.id_presentacion = NEW.id_presentacion;

  IF v_tipo = 'SOLIDO' THEN
    RAISE EXCEPTION
      'Un solido no admite versiones de densidad en PRESENTACION';
  END IF;
  IF v_variable THEN
    RAISE EXCEPTION
      'El insumo tiene densidad variable; registre la densidad en LOTE';
  END IF;
  RETURN NEW;
END
$$;

DROP TRIGGER IF EXISTS tg_densidad_vigencia_core ON densidad_vigencia;
CREATE TRIGGER tg_densidad_vigencia_core
BEFORE INSERT OR UPDATE OF id_presentacion, valor ON densidad_vigencia
FOR EACH ROW EXECUTE FUNCTION fn_validar_densidad_vigencia_core();

-- Vigencias y unicidad normalizada de los catálogos controlados.
ALTER TABLE carrera ALTER COLUMN codigo SET NOT NULL;
ALTER TABLE laboratorio ALTER COLUMN codigo SET NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS uq_establecimiento_codigo_normalizado
    ON establecimiento (normalizar_busqueda(codigo));
CREATE UNIQUE INDEX IF NOT EXISTS uq_ubicacion_codigo_normalizado
    ON ubicacion (normalizar_busqueda(codigo));
CREATE UNIQUE INDEX IF NOT EXISTS uq_usuario_email_normalizado
    ON usuario (normalizar_busqueda(email));

DO $$
BEGIN
  IF NOT EXISTS (
      SELECT 1 FROM pg_constraint
       WHERE conrelid = 'carrera'::regclass
         AND conname = 'ck_carrera_vigencia'
  ) THEN
    ALTER TABLE carrera ADD CONSTRAINT ck_carrera_vigencia
      CHECK (vigencia_hasta IS NULL OR vigencia_hasta >= vigencia_desde);
  END IF;
  IF NOT EXISTS (
      SELECT 1 FROM pg_constraint
       WHERE conrelid = 'laboratorio'::regclass
         AND conname = 'ck_laboratorio_vigencia'
  ) THEN
    ALTER TABLE laboratorio ADD CONSTRAINT ck_laboratorio_vigencia
      CHECK (vigencia_hasta IS NULL OR vigencia_hasta >= vigencia_desde);
  END IF;
  IF NOT EXISTS (
      SELECT 1 FROM pg_constraint
       WHERE conrelid = 'investigador'::regclass
         AND conname = 'ck_investigador_vigencia'
  ) THEN
    ALTER TABLE investigador ADD CONSTRAINT ck_investigador_vigencia
      CHECK (vigencia_hasta IS NULL OR vigencia_hasta >= vigencia_desde);
  END IF;
  IF NOT EXISTS (
      SELECT 1 FROM pg_constraint
       WHERE conrelid = 'presentacion'::regclass
         AND conname = 'ck_presentacion_vigencia'
  ) THEN
    ALTER TABLE presentacion ADD CONSTRAINT ck_presentacion_vigencia
      CHECK (vigencia_hasta IS NULL OR vigencia_hasta >= vigencia_desde);
  END IF;
END
$$;

-- Motivo de cambios sensibles: se captura junto con actor, fecha y request.
ALTER TABLE bitacora ADD COLUMN IF NOT EXISTS motivo TEXT;

CREATE OR REPLACE FUNCTION fn_auditar_sprint1()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO iqbf, pg_catalog, pg_temp
AS $$
DECLARE
  v_actor_text TEXT := current_setting('iqbf.actor_id', true);
  v_request_text TEXT := current_setting('iqbf.request_id', true);
  v_motivo TEXT := nullif(current_setting('iqbf.change_reason', true), '');
  v_old JSONB;
  v_new JSONB;
  v_id TEXT;
BEGIN
  v_old := CASE
    WHEN TG_OP IN ('UPDATE', 'DELETE') THEN to_jsonb(OLD) - 'contrasena'
  END;
  v_new := CASE
    WHEN TG_OP IN ('INSERT', 'UPDATE') THEN to_jsonb(NEW) - 'contrasena'
  END;
  v_id := COALESCE(
      v_new ->> ('id_' || TG_TABLE_NAME),
      v_old ->> ('id_' || TG_TABLE_NAME),
      v_new ->> 'codigo',
      v_old ->> 'codigo',
      v_new ->> 'id_presentacion',
      v_old ->> 'id_presentacion',
      v_new ->> 'id_insumo',
      v_old ->> 'id_insumo',
      v_new ->> 'id_usuario',
      v_old ->> 'id_usuario'
  );

  INSERT INTO bitacora (
      id_usuario, accion, entidad, entidad_id,
      valores_antes, valores_despues, request_id, origen, motivo
  ) VALUES (
      CASE WHEN v_actor_text ~ '^[0-9]+$' THEN v_actor_text::integer END,
      TG_OP, TG_TABLE_NAME, v_id, v_old, v_new,
      CASE
        WHEN v_request_text ~
          '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$'
        THEN v_request_text::uuid
      END,
      CASE WHEN v_actor_text ~ '^[0-9]+$' THEN 'API' ELSE 'BD' END,
      v_motivo
  );

  RETURN COALESCE(NEW, OLD);
END
$$;

-- Vistas del Core V3 reconciliadas. No sustituyen las tablas de evidencia:
-- únicamente exponen el núcleo operacional para consulta y demo.
CREATE OR REPLACE VIEW v_inventario_core AS
SELECT f.id_frasco,
       i.id_insumo,
       i.nombre_comercial,
       i.tipo,
       i.densidad_variable,
       p.id_presentacion,
       p.concentracion,
       p.capacidad,
       p.unidad,
       p.tipo_envase,
       l.numero_lote,
       l.numero_factura,
       pr.nombre AS proveedor,
       l.fecha_ingreso,
       l.fecha_caducidad,
       f.peso_bruto_g,
       f.tara_g,
       f.peso_neto_inicial_g,
       f.peso_neto_actual_g,
       COALESCE(l.densidad, p.densidad) AS densidad_aplicable,
       CASE
         WHEN i.tipo = 'LIQUIDO'
              AND COALESCE(l.densidad, p.densidad) IS NOT NULL
           THEN round(
             f.peso_neto_actual_g / COALESCE(l.densidad, p.densidad),
             4
           )
       END AS volumen_actual_ml,
       COALESCE(lab.nombre, 'DOCIMASIA / SIN ASIGNAR') AS laboratorio_actual,
       f.estado AS estado_frasco,
       l.estado AS estado_lote,
       CASE
         WHEN l.fecha_caducidad IS NULL THEN 'POR_CONFIRMAR'
         WHEN l.fecha_caducidad < CURRENT_DATE THEN 'VENCIDO'
         ELSE 'VIGENTE'
       END AS estado_caducidad
  FROM frasco f
  JOIN lote l         ON l.id_lote = f.id_lote
  JOIN presentacion p ON p.id_presentacion = l.id_presentacion
  JOIN insumo i       ON i.id_insumo = p.id_insumo
  LEFT JOIN proveedor pr ON pr.id_proveedor = l.id_proveedor
  LEFT JOIN laboratorio lab
    ON lab.id_laboratorio = f.id_laboratorio_actual;

CREATE OR REPLACE VIEW v_alertas_core AS
SELECT v.*,
       CASE
         WHEN estado_caducidad = 'VENCIDO' THEN '1-VENCIDO'
         WHEN tipo = 'LIQUIDO' AND densidad_aplicable IS NULL
           THEN '2-DENSIDAD_PENDIENTE'
         WHEN laboratorio_actual IN (
           'Docimasia', 'DOCIMASIA / SIN ASIGNAR'
         ) THEN '3-SIN_ASIGNACION'
         WHEN peso_neto_actual_g = 0 AND estado_frasco <> 'AGOTADO'
           THEN '4-REVISAR_ESTADO'
         ELSE '5-SIN_ALERTA_PRIORITARIA'
       END AS alerta_prioritaria
  FROM v_inventario_core v;

CREATE OR REPLACE VIEW v_panel_core_sprint1 AS
SELECT
  (SELECT count(*) FROM frasco) AS frascos,
  (SELECT count(*) FROM insumo WHERE tipo = 'LIQUIDO') AS insumos_liquidos,
  (SELECT count(*) FROM insumo WHERE tipo = 'SOLIDO') AS insumos_solidos,
  (SELECT count(*) FROM kardex) AS movimientos_registrados,
  (
    SELECT count(*) FROM kardex
     WHERE tipo_movimiento = 'TRANSFERENCIA' OR cantidad_g > 0
  ) AS movimientos_efectivos,
  (
    SELECT count(*) FROM v_inventario_core
     WHERE estado_caducidad = 'VENCIDO'
  ) AS frascos_vencidos,
  (
    SELECT count(*) FROM v_inventario_core
     WHERE laboratorio_actual IN (
       'Docimasia', 'DOCIMASIA / SIN ASIGNAR'
     )
  ) AS stock_docimasia_sin_asignar,
  (
    SELECT count(*) FROM v_inventario_core
     WHERE tipo = 'LIQUIDO' AND densidad_aplicable IS NULL
  ) AS liquidos_sin_densidad,
  (
    SELECT count(*) FROM frasco WHERE peso_neto_actual_g > 0
  ) AS frascos_con_saldo;

CREATE TABLE IF NOT EXISTS seed_migration (
    version      VARCHAR(80) PRIMARY KEY,
    descripcion TEXT NOT NULL,
    aplicado_en TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO seed_migration (version, descripcion) VALUES
  ('roles-v1', 'Seis roles canonicos del Product Backlog'),
  ('establecimientos-v1', 'Establecimiento base Universidad de Lima'),
  (
    'core-v3-densidades-v1',
    'Politica y densidades verificadas de IQBF Core V3 2026-07-24'
  )
ON CONFLICT (version) DO NOTHING;

INSERT INTO schema_migration (version, descripcion)
VALUES (
  '002',
  'Criterios de aceptacion Sprint 1 y reconciliacion IQBF Core V3'
)
ON CONFLICT (version) DO NOTHING;

COMMIT;
