BEGIN;

SET LOCAL search_path TO iqbf, public, pg_catalog;

-- ═══════════════════════════════════════════════════════════════════════════
-- 009 · Cierra los pendientes pequeños de la verificación HU por HU
--   US-005 · el custodio se asocia a carrera o laboratorio
--   US-008 · un maestro inactivo no admite operaciones nuevas
--   US-010 · una presentación necesita al menos un código
--   US-036 · el movimiento guarda de dónde salió el factor de conversión
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── US-005 · El custodio pertenece a algún sitio ──────────────────────────
-- El criterio pide «se asocian carrera/laboratorio y estado», pero la regla
-- solo vivía en la API: por SQL directo —la vía por la que entró el censo—
-- entraba un custodio suelto. NOT VALID a propósito: las filas que ya están no
-- se rechazan, pero ninguna nueva puede quedar sin adscripción.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'ck_investigador_adscripcion'
  ) THEN
    ALTER TABLE investigador ADD CONSTRAINT ck_investigador_adscripcion
      CHECK (id_carrera IS NOT NULL OR id_laboratorio IS NOT NULL)
      NOT VALID;
  END IF;
END;
$$;

-- Juan Carlos Yacono sí tiene evidencia: sus frascos IQF0102-137-108 y -109
-- llevan «ING. CIVIL» en el rótulo, y el IQF0102-115-105 lleva «Prof. Yacono».
-- La Cruz y Muedas NO la tienen: se quedan sin adscripción a propósito, y
-- salen en la consulta de pendientes de más abajo. Inferir el departamento de
-- una persona por dónde está su frasco es exactamente el atajo que este
-- proyecto ya pagó caro una vez.
UPDATE investigador i
   SET id_laboratorio = (SELECT id_laboratorio FROM laboratorio
                          WHERE nombre = 'Ingeniería Civil')
 WHERE i.nombre = 'Juan Carlos Yacono'
   AND i.id_laboratorio IS NULL
   AND EXISTS (SELECT 1 FROM laboratorio WHERE nombre = 'Ingeniería Civil');

CREATE OR REPLACE VIEW v_custodios_incompletos AS
SELECT i.id_investigador, i.nombre, i.tipo,
       (i.codigo_institucional IS NULL) AS sin_codigo,
       (i.id_carrera IS NULL AND i.id_laboratorio IS NULL) AS sin_adscripcion,
       count(f.id_frasco) AS frascos_a_su_cargo
  FROM investigador i
  LEFT JOIN frasco f ON f.id_investigador = i.id_investigador
 WHERE i.estado = 'ACTIVO'
   AND (i.codigo_institucional IS NULL
        OR (i.id_carrera IS NULL AND i.id_laboratorio IS NULL))
 GROUP BY i.id_investigador, i.nombre, i.tipo, i.codigo_institucional,
          i.id_carrera, i.id_laboratorio;

COMMENT ON VIEW v_custodios_incompletos IS
  'US-005. Custodios a los que les falta código institucional o adscripción. '
  'Se completan preguntando al laboratorio, no deduciendo.';


-- ─── US-010 · Una presentación sin ningún código no se puede declarar ──────
-- Entraba en estado VIGENTE sin código SUNAT ni código de presentación, y una
-- presentación sin código fiscal queda fuera del rollup de US-021 sin que
-- nadie se entere.

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'ck_presentacion_algun_codigo'
  ) THEN
    ALTER TABLE presentacion ADD CONSTRAINT ck_presentacion_algun_codigo
      CHECK (codigo_bf_sunat IS NOT NULL OR codigo_presentacion IS NOT NULL)
      NOT VALID;
  END IF;
END;
$$;


-- ─── US-008 · Un maestro inactivo no admite operaciones nuevas ─────────────
-- Hoy un consumo sobre un frasco cuyo insumo o presentación está INACTIVO se
-- registraba sin aviso. Se bloquea, y el mensaje dice cómo salir: reactivar.
-- Es deliberado que la salida exista — el producto físico sigue en la balda y
-- hay que poder agotarlo —, pero exige una acción consciente y auditada en
-- lugar de ocurrir por descuido.
--
-- El censo inicial se exceptúa: es la carga que RETRATA lo que ya existe, y
-- tiene que poder retratar también lo retirado.

CREATE OR REPLACE FUNCTION fn_kardex_maestro_vigente() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
  v_pres    VARCHAR(30);
  v_estado  VARCHAR(20);
  v_insumo  VARCHAR(20);
  v_est_ins VARCHAR(20);
BEGIN
  IF NEW.motivo = 'censo_inicial' THEN
    RETURN NEW;
  END IF;

  SELECT p.id_presentacion, p.estado, i.id_insumo, i.estado
    INTO v_pres, v_estado, v_insumo, v_est_ins
    FROM frasco f
    JOIN lote l         ON l.id_lote = f.id_lote
    JOIN presentacion p ON p.id_presentacion = l.id_presentacion
    JOIN insumo i       ON i.id_insumo = p.id_insumo
   WHERE f.id_frasco = NEW.id_frasco;

  IF v_estado <> 'VIGENTE' OR v_est_ins <> 'VIGENTE' THEN
    RAISE EXCEPTION
      'Maestro inactivo: el insumo % o la presentacion % estan retirados y no '
      'admiten movimientos nuevos. Reactivelos si hay que agotar el stock '
      'existente.', v_insumo, v_pres
      USING ERRCODE = 'check_violation';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_kardex_maestro_vigente ON kardex;
CREATE TRIGGER tg_kardex_maestro_vigente
BEFORE INSERT ON kardex
FOR EACH ROW EXECUTE FUNCTION fn_kardex_maestro_vigente();


-- ─── US-036 · De dónde salió el factor de conversión ───────────────────────
-- El kardex guardaba el NÚMERO de la densidad pero no su procedencia, y
-- `densidad_vigencia.fuente` tiene contenido real («Etiqueta del fabricante»,
-- «Censo fotográfico 2026-08-05»). Al mirar un movimiento no se sabía si el
-- 1,18 venía de la etiqueta del fabricante o de una tabla de referencia — y en
-- una declaración fiscalizada esa diferencia es la que se defiende.

ALTER TABLE kardex
    ADD COLUMN IF NOT EXISTS id_densidad_aplicada BIGINT
        REFERENCES densidad_vigencia(id_densidad),
    ADD COLUMN IF NOT EXISTS fuente_densidad VARCHAR(200),
    ADD COLUMN IF NOT EXISTS formula_conversion TEXT;

COMMENT ON COLUMN kardex.fuente_densidad IS
  'De dónde salió la densidad usada: etiqueta, ficha técnica, medición. '
  'Se congela aquí porque la fuente puede cambiar después.';
COMMENT ON COLUMN kardex.formula_conversion IS
  'La cuenta que se hizo, escrita. Ej.: «250 mL x 1.180000 g/mL = 295.0000 g». '
  'Reconstruible a mano, pero declarada es defendible sin recalcular.';

-- La conversión se escribe sola cuando el movimiento no la trae: así también
-- queda registrada en los movimientos hechos por SQL directo.
CREATE OR REPLACE FUNCTION fn_kardex_formula() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.formula_conversion IS NULL AND NEW.cantidad_registrada IS NOT NULL THEN
    NEW.formula_conversion :=
      CASE
        WHEN NEW.bruto_antes_g IS NOT NULL THEN
          format('%s g (peso 1) - %s g (peso 2) = %s g',
                 NEW.bruto_antes_g, NEW.bruto_despues_g, NEW.cantidad_g)
        WHEN NEW.unidad_registrada IN ('mL', 'L') THEN
          format('%s %s x %s g/mL = %s g',
                 NEW.cantidad_registrada, NEW.unidad_registrada,
                 NEW.densidad_aplicada, NEW.cantidad_g)
        WHEN NEW.unidad_registrada = 'kg' THEN
          format('%s kg x 1000 = %s g', NEW.cantidad_registrada, NEW.cantidad_g)
        ELSE format('%s g (sin conversion)', NEW.cantidad_g)
      END;
  END IF;

  IF NEW.fuente_densidad IS NULL AND NEW.densidad_aplicada IS NOT NULL THEN
    SELECT dv.fuente, dv.id_densidad
      INTO NEW.fuente_densidad, NEW.id_densidad_aplicada
      FROM frasco f
      JOIN lote l              ON l.id_lote = f.id_lote
      JOIN densidad_vigencia dv ON dv.id_presentacion = l.id_presentacion
     WHERE f.id_frasco = NEW.id_frasco
       AND dv.valor = NEW.densidad_aplicada
       AND dv.vigencia_desde <= COALESCE(NEW.fecha_operacion, CURRENT_DATE)
       AND (dv.vigencia_hasta IS NULL
            OR dv.vigencia_hasta >= COALESCE(NEW.fecha_operacion, CURRENT_DATE))
     ORDER BY dv.vigencia_desde DESC
     LIMIT 1;

    -- Sin versión de densidad que la respalde, se dice de dónde vino igual:
    -- «no consta» es información, y dejarlo en blanco no lo es.
    IF NEW.fuente_densidad IS NULL THEN
      NEW.fuente_densidad := 'Densidad del lote o de la presentación (sin versión registrada)';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_kardex_formula ON kardex;
CREATE TRIGGER tg_kardex_formula
BEFORE INSERT ON kardex
FOR EACH ROW EXECUTE FUNCTION fn_kardex_formula();


-- CREATE OR REPLACE no admite reordenar columnas: hay que soltarla.
DROP VIEW IF EXISTS v_kardex_detalle;
CREATE VIEW v_kardex_detalle AS
SELECT k.id_movimiento, k.id_frasco, k.tipo_movimiento, k.motivo,
       k.cantidad_g, k.cantidad_kg, k.cantidad_registrada, k.unidad_registrada,
       k.densidad_aplicada,
       -- El histórico NO se rellena con UPDATE: el kardex es inmutable por
       -- trigger y hace bien en serlo. La cuenta de los movimientos ya
       -- escritos se DERIVA aquí de lo que sí quedó guardado; los nuevos la
       -- congelan al insertarse, que es lo correcto — refleja la cuenta que se
       -- hizo entonces, aunque la densidad cambie después.
       COALESCE(k.fuente_densidad, dvig.fuente,
                CASE WHEN k.densidad_aplicada IS NOT NULL
                     THEN 'Densidad del lote o de la presentación'
                          ' (sin versión registrada)' END) AS fuente_densidad,
       COALESCE(k.formula_conversion,
         CASE
           WHEN k.bruto_antes_g IS NOT NULL THEN
             format('%s g (peso 1) - %s g (peso 2) = %s g',
                    k.bruto_antes_g, k.bruto_despues_g, k.cantidad_g)
           WHEN k.unidad_registrada IN ('mL','L') THEN
             format('%s %s x %s g/mL = %s g', k.cantidad_registrada,
                    k.unidad_registrada, k.densidad_aplicada, k.cantidad_g)
           WHEN k.unidad_registrada = 'kg' THEN
             format('%s kg x 1000 = %s g', k.cantidad_registrada, k.cantidad_g)
           WHEN k.cantidad_registrada IS NOT NULL THEN
             format('%s g (sin conversion)', k.cantidad_g)
         END) AS formula_conversion,
       k.bruto_antes_g, k.bruto_despues_g,
       k.peso_antes_g AS saldo_antes_g, k.saldo_resultante_g AS saldo_despues_g,
       k.fecha_hora, k.fecha_operacion, k.curso, k.usuario_final,
       u.nombre AS registrado_por,
       COALESCE(dest.nombre, orig.nombre) AS investigador,
       CASE
         WHEN k.bruto_antes_g IS NOT NULL THEN 'pesada'
         WHEN k.unidad_registrada IN ('mL','L') THEN 'volumen convertido'
         WHEN k.unidad_registrada IS NOT NULL   THEN 'cantidad declarada'
         ELSE 'sin origen'
       END AS origen_cantidad
  FROM kardex k
  LEFT JOIN usuario u        ON u.id_usuario = k.registrado_por
  LEFT JOIN investigador dest ON dest.id_investigador = k.id_investigador_destinatario
  LEFT JOIN investigador orig ON orig.id_investigador = k.id_investigador_origen
  LEFT JOIN LATERAL (
        SELECT dv.fuente
          FROM frasco f
          JOIN lote l               ON l.id_lote = f.id_lote
          JOIN densidad_vigencia dv ON dv.id_presentacion = l.id_presentacion
         WHERE f.id_frasco = k.id_frasco
           AND dv.valor = k.densidad_aplicada
         ORDER BY dv.vigencia_desde DESC
         LIMIT 1
  ) dvig ON TRUE;


INSERT INTO schema_migration (version, descripcion)
VALUES ('009', 'Pendientes pequenos: adscripcion de custodio, codigo de '
               'presentacion, maestros inactivos y procedencia del factor')
ON CONFLICT (version) DO NOTHING;

COMMIT;
