BEGIN;

SET LOCAL search_path TO iqbf, public, pg_catalog;

-- ═══════════════════════════════════════════════════════════════════════════
-- 008 · Cierra los huecos que encontró la verificación HU por HU del backlog
--
-- Cada bloque referencia la historia cuyo criterio no se cumplía. Todos se
-- reprodujeron antes de escribir esto; ninguno es preventivo.
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── US-004 · Un catálogo en uso no se borra en silencio ───────────────────
-- `frasco_id_ubicacion_fkey` estaba en ON DELETE SET NULL: borrar una ubicación
-- usada por 18 frascos los dejaba sin ubicación, sin error y sin rastro del
-- frasco en la bitácora. El criterio pide lo contrario: «un valor usado
-- históricamente se inactiva en lugar de borrarse». Con RESTRICT, el borrado
-- falla y hay que inactivar, que es la vía correcta.

ALTER TABLE frasco DROP CONSTRAINT IF EXISTS frasco_id_ubicacion_fkey;
ALTER TABLE frasco ADD CONSTRAINT frasco_id_ubicacion_fkey
  FOREIGN KEY (id_ubicacion) REFERENCES ubicacion(id_ubicacion)
  ON DELETE RESTRICT;


-- ─── US-011 · La inactivación tiene que impedir nuevas altas de verdad ─────
-- Dos agujeros reproducidos:
--   (a) `fn_validar_densidad_lote_core` solo comprobaba el estado en INSERT,
--       aunque el trigger está cableado también a UPDATE OF id_presentacion:
--       un UPDATE podía re-apuntar un lote entero, con todos sus frascos, a
--       una presentación retirada.
--   (b) Nada impedía dar de alta un FRASCO sobre un lote cuya presentación o
--       cuyo insumo estuvieran inactivos — y esa es la vía real de alta de
--       este proyecto, porque el cargador del censo inserta por SQL.

CREATE OR REPLACE FUNCTION fn_validar_lote_maestro_vigente() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
  v_estado_pres   VARCHAR(20);
  v_estado_insumo VARCHAR(20);
BEGIN
  SELECT p.estado, i.estado
    INTO v_estado_pres, v_estado_insumo
    FROM presentacion p
    JOIN insumo i ON i.id_insumo = p.id_insumo
   WHERE p.id_presentacion = NEW.id_presentacion;

  IF v_estado_pres IS NULL THEN
    RAISE EXCEPTION 'La presentacion % no existe', NEW.id_presentacion;
  END IF;

  -- Se comprueba en INSERT y en UPDATE: re-apuntar es tan alta como crear.
  IF v_estado_pres <> 'VIGENTE' OR v_estado_insumo <> 'VIGENTE' THEN
    RAISE EXCEPTION
      'Insumo o presentacion inactiva: la presentacion % no admite nuevos '
      'lotes ni frascos. Reactivela antes de dar de alta.', NEW.id_presentacion
      USING ERRCODE = 'check_violation';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_lote_maestro_vigente ON lote;
CREATE TRIGGER tg_lote_maestro_vigente
BEFORE INSERT OR UPDATE OF id_presentacion ON lote
FOR EACH ROW EXECUTE FUNCTION fn_validar_lote_maestro_vigente();


CREATE OR REPLACE FUNCTION fn_validar_frasco_maestro_vigente() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
  v_estado_pres   VARCHAR(20);
  v_estado_insumo VARCHAR(20);
  v_presentacion  VARCHAR(30);
BEGIN
  SELECT p.id_presentacion, p.estado, i.estado
    INTO v_presentacion, v_estado_pres, v_estado_insumo
    FROM lote l
    JOIN presentacion p ON p.id_presentacion = l.id_presentacion
    JOIN insumo i       ON i.id_insumo = p.id_insumo
   WHERE l.id_lote = NEW.id_lote;

  IF v_estado_pres IS NULL THEN
    RAISE EXCEPTION 'El lote % no existe', NEW.id_lote;
  END IF;

  IF v_estado_pres <> 'VIGENTE' OR v_estado_insumo <> 'VIGENTE' THEN
    RAISE EXCEPTION
      'Insumo o presentacion inactiva: no se pueden dar de alta frascos de %. '
      'Reactivela antes.', v_presentacion
      USING ERRCODE = 'check_violation';
  END IF;
  RETURN NEW;
END;
$$;

-- Solo en el alta y al mover un frasco de lote. Un frasco YA existente sobre
-- una presentacion inactivada sigue vivo y se puede consumir: eso es
-- exactamente lo que US-011 promete conservar.
DROP TRIGGER IF EXISTS tg_frasco_maestro_vigente ON frasco;
CREATE TRIGGER tg_frasco_maestro_vigente
BEFORE INSERT OR UPDATE OF id_lote ON frasco
FOR EACH ROW EXECUTE FUNCTION fn_validar_frasco_maestro_vigente();


-- ─── US-033 · El saldo negativo por INSERT multifila ───────────────────────
-- `fn_kardex_antes` es BEFORE ROW y lee `frasco.peso_neto_actual_g`, que solo
-- refresca el AFTER ROW. Dentro de una misma sentencia, todas las filas leen
-- el mismo saldo rancio: un único INSERT con dos SALIDAS de 3000 g sobre un
-- frasco de 4601 g se aceptaba entero y dejaba el kardex sumando −1398 g.
--
-- Ningún endpoint lo dispara hoy (todos insertan de a una fila), pero la
-- corrección de datos por SQL directo sí, y es donde más falta hace la red.
--
-- El arreglo: el AFTER ROW deja de escribir el saldo calculado por el BEFORE y
-- lo aplica de forma RELATIVA. Así cada fila parte del saldo ya actualizado
-- por la anterior, y el CHECK peso_neto_actual_g >= 0 corta la sentencia.

CREATE OR REPLACE FUNCTION fn_kardex_despues() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
  v_signo  INTEGER;
  v_saldo  NUMERIC(14,4);
BEGIN
  v_signo := CASE NEW.tipo_movimiento
               WHEN 'ENTRADA' THEN 1
               WHEN 'SALIDA' THEN -1
               ELSE 0
             END;

  PERFORM set_config('iqbf.mov', '1', true);
  UPDATE frasco
     SET peso_neto_actual_g = peso_neto_actual_g + (v_signo * NEW.cantidad_g),
         id_laboratorio_actual = CASE
           WHEN NEW.tipo_movimiento = 'TRANSFERENCIA'
                AND NEW.id_laboratorio_destino IS NOT NULL
             THEN NEW.id_laboratorio_destino
           ELSE id_laboratorio_actual
         END,
         id_investigador = CASE
           WHEN NEW.tipo_movimiento = 'TRANSFERENCIA'
                AND NEW.id_investigador_destinatario IS NOT NULL
             THEN NEW.id_investigador_destinatario
           ELSE id_investigador
         END
   WHERE id_frasco = NEW.id_frasco
   RETURNING peso_neto_actual_g INTO v_saldo;

  -- El estado depende del saldo YA aplicado, no del que calculó el BEFORE.
  UPDATE frasco
     SET estado = CASE
           WHEN v_saldo = 0 AND estado = 'EN_USO'   THEN 'AGOTADO'
           WHEN v_saldo > 0 AND estado = 'AGOTADO'  THEN 'EN_USO'
           ELSE estado
         END
   WHERE id_frasco = NEW.id_frasco;
  PERFORM set_config('iqbf.mov', '0', true);
  RETURN NULL;
END;
$$;


-- ─── EN-008 · La semilla no puede mentir ───────────────────────────────────
-- `seed_migration` registraba 'core-v3-densidades-v1' como aplicada aunque su
-- INSERT ... SELECT insertara CERO filas por correr sobre una base vacía. En
-- producción esa versión figura aplicada y `densidad_vigencia` está vacía con
-- 61 presentaciones: el registro afirma que la política de densidades está
-- cargada cuando no hay ni una densidad.
--
-- Se borra el registro falso para que la semilla vuelva a poder ejecutarse
-- cuando existan datos, y se deja constancia de por qué.

DELETE FROM seed_migration
 WHERE version = 'core-v3-densidades-v1'
   AND NOT EXISTS (SELECT 1 FROM densidad_vigencia);

COMMENT ON TABLE seed_migration IS
  'Semillas de catálogo aplicadas. Una versión solo debe registrarse si '
  'realmente insertó datos: registrarla tras insertar cero filas hace que no '
  'se reintente nunca y que el registro afirme algo falso.';


INSERT INTO schema_migration (version, descripcion)
VALUES ('008', 'Cierra huecos de la verificacion: FK de ubicacion, altas sobre '
               'maestros inactivos, saldo negativo multifila y semilla falsa')
ON CONFLICT (version) DO NOTHING;

COMMIT;
