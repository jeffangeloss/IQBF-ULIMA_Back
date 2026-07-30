BEGIN;

CREATE SCHEMA IF NOT EXISTS iqbf;
SET LOCAL search_path TO iqbf, public, pg_catalog;

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;

-- Los dos códigos externos de presentación son identificadores controlados.
CREATE UNIQUE INDEX IF NOT EXISTS uq_presentacion_bf_sunat_normalizado
    ON presentacion (normalizar_busqueda(codigo_bf_sunat))
    WHERE codigo_bf_sunat IS NOT NULL;

-- Los criterios de búsqueda usan coincidencia parcial sin distinguir
-- mayúsculas ni tildes. Estos índices evitan barridos completos al crecer.
CREATE INDEX IF NOT EXISTS ix_insumo_nombre_trgm
    ON insumo USING gin (
      normalizar_busqueda(nombre_comercial) public.gin_trgm_ops
    );
CREATE INDEX IF NOT EXISTS ix_insumo_codigo_trgm
    ON insumo USING gin (
      normalizar_busqueda(id_insumo) public.gin_trgm_ops
    );
CREATE INDEX IF NOT EXISTS ix_presentacion_bf_trgm
    ON presentacion USING gin (
      normalizar_busqueda(codigo_bf_sunat) public.gin_trgm_ops
    )
    WHERE codigo_bf_sunat IS NOT NULL;
CREATE INDEX IF NOT EXISTS ix_presentacion_codigo_trgm
    ON presentacion USING gin (
      normalizar_busqueda(codigo_presentacion) public.gin_trgm_ops
    )
    WHERE codigo_presentacion IS NOT NULL;

CREATE OR REPLACE FUNCTION fn_validar_alta_presentacion_sprint1()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path TO iqbf, pg_catalog, pg_temp
AS $$
DECLARE
  v_tipo insumo.tipo%TYPE;
  v_estado insumo.estado%TYPE;
BEGIN
  SELECT tipo, estado
    INTO v_tipo, v_estado
    FROM insumo
   WHERE id_insumo = NEW.id_insumo;

  IF TG_OP = 'INSERT' AND v_estado <> 'VIGENTE' THEN
    RAISE EXCEPTION
      'No se puede crear una presentacion para el insumo inactivo %',
      NEW.id_insumo;
  END IF;
  IF v_tipo = 'LIQUIDO' AND NEW.unidad NOT IN ('mL', 'L') THEN
    RAISE EXCEPTION
      'La unidad % no es compatible con el insumo liquido %',
      NEW.unidad, NEW.id_insumo;
  END IF;
  IF v_tipo = 'SOLIDO' AND NEW.unidad NOT IN ('g', 'kg') THEN
    RAISE EXCEPTION
      'La unidad % no es compatible con el insumo solido %',
      NEW.unidad, NEW.id_insumo;
  END IF;
  IF TG_OP = 'INSERT' AND NEW.equivalencia_g IS NULL THEN
    RAISE EXCEPTION
      'Una presentacion nueva requiere equivalencia en gramos';
  END IF;
  RETURN NEW;
END
$$;

DROP TRIGGER IF EXISTS tg_presentacion_alta_sprint1 ON presentacion;
CREATE TRIGGER tg_presentacion_alta_sprint1
BEFORE INSERT OR UPDATE OF id_insumo, unidad, equivalencia_g
ON presentacion
FOR EACH ROW EXECUTE FUNCTION fn_validar_alta_presentacion_sprint1();

-- Sustituye la versión de 002 y preserva los tres lotes históricos del censo
-- cuya densidad sigue pendiente: la obligatoriedad aplica a altas nuevas.
CREATE OR REPLACE FUNCTION fn_validar_densidad_lote_core()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path TO iqbf, pg_catalog, pg_temp
AS $$
DECLARE
  v_tipo insumo.tipo%TYPE;
  v_variable insumo.densidad_variable%TYPE;
  v_estado_insumo insumo.estado%TYPE;
  v_estado_presentacion presentacion.estado%TYPE;
BEGIN
  SELECT i.tipo, i.densidad_variable, i.estado, p.estado
    INTO v_tipo, v_variable, v_estado_insumo, v_estado_presentacion
    FROM presentacion p
    JOIN insumo i ON i.id_insumo = p.id_insumo
   WHERE p.id_presentacion = NEW.id_presentacion;

  IF TG_OP = 'INSERT'
     AND (
       v_estado_insumo <> 'VIGENTE'
       OR v_estado_presentacion <> 'VIGENTE'
     ) THEN
    RAISE EXCEPTION
      'No se puede crear un lote para un insumo o presentacion inactiva';
  END IF;
  IF v_tipo = 'LIQUIDO' AND v_variable AND NEW.densidad IS NULL THEN
    RAISE EXCEPTION
      'El insumo tiene densidad variable; registre la densidad en LOTE';
  END IF;
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

CREATE OR REPLACE FUNCTION fn_exigir_motivo_estado_sprint1()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path TO iqbf, pg_catalog, pg_temp
AS $$
BEGIN
  IF NEW.estado IS DISTINCT FROM OLD.estado
     AND nullif(current_setting('iqbf.change_reason', true), '') IS NULL
  THEN
    RAISE EXCEPTION
      'El cambio de estado de % requiere un motivo', TG_TABLE_NAME;
  END IF;
  RETURN NEW;
END
$$;

DROP TRIGGER IF EXISTS tg_insumo_motivo_estado ON insumo;
CREATE TRIGGER tg_insumo_motivo_estado
BEFORE UPDATE OF estado ON insumo
FOR EACH ROW EXECUTE FUNCTION fn_exigir_motivo_estado_sprint1();

DROP TRIGGER IF EXISTS tg_presentacion_motivo_estado ON presentacion;
CREATE TRIGGER tg_presentacion_motivo_estado
BEFORE UPDATE OF estado ON presentacion
FOR EACH ROW EXECUTE FUNCTION fn_exigir_motivo_estado_sprint1();

INSERT INTO schema_migration (version, descripcion)
VALUES (
  '003',
  'Integridad de altas, estados y busqueda de maestros del Sprint 1'
)
ON CONFLICT (version) DO NOTHING;

COMMIT;
