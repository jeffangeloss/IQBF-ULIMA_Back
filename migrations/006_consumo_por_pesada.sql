BEGIN;

SET LOCAL search_path TO iqbf, public, pg_catalog;

-- ═══════════════════════════════════════════════════════════════════════════
-- 006 · Consumo por doble pesada, merma e inventario
--
-- Alinea el kardex con la forma en que el laboratorio registra de verdad,
-- documentada en `IQBF Y PRODUCE/ALL.DATA/6.2026 IQBF LÍQUIDOS.xlsx`
-- (101 fichas «CONTROL DE REACTIVOS», 811 movimientos).
--
-- Alli el consumo NO se apunta: se deriva de dos pesadas del frasco entero.
--
--     CONSUMO EN PESO = PESO 1 − PESO 2
--
-- Y el libro se autocomprueba, porque el PESO 1 de una fila tiene que ser el
-- PESO 2 de la anterior. En sus datos encadenan 688 de 713 pares (96,5 %); los
-- 25 que no, son producto que salio del frasco sin registrarse. Ese hueco es
-- justo lo que una base de datos puede cerrar en el momento en vez de en el
-- siguiente inventario.
--
-- Ademas, su columna CURSO mezcla tres cosas en texto libre: quien consume,
-- para que, y de que clase de movimiento se trata. Las dos primeras ya estan
-- separadas (id_investigador_origen, curso); faltaban dos motivos suyos.
-- ═══════════════════════════════════════════════════════════════════════════


-- ─── 1 · La lectura de la balanza se guarda tal cual ───────────────────────
-- peso_antes_g / peso_despues_g llevan el SALDO (neto) y lo escribe el
-- trigger. Estas dos columnas llevan lo que marco la BALANZA: el frasco
-- entero, tara incluida. Son la evidencia, y no se derivan de nada.

ALTER TABLE kardex
    ADD COLUMN IF NOT EXISTS bruto_antes_g   NUMERIC(14,4),
    ADD COLUMN IF NOT EXISTS bruto_despues_g NUMERIC(14,4),
    ADD COLUMN IF NOT EXISTS usuario_final_es_tercero BOOLEAN NOT NULL DEFAULT FALSE;

COMMENT ON COLUMN kardex.bruto_antes_g IS
  'PESO 1: lectura de la balanza con el frasco lleno, antes de servir. '
  'Debe coincidir con tara + saldo; si no, hubo uso sin registrar.';
COMMENT ON COLUMN kardex.bruto_despues_g IS
  'PESO 2: lectura de la balanza despues de servir. El consumo es la resta.';

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ck_kardex_pesadas') THEN
    ALTER TABLE kardex ADD CONSTRAINT ck_kardex_pesadas CHECK (
      (bruto_antes_g IS NULL AND bruto_despues_g IS NULL)
      OR (bruto_antes_g IS NOT NULL AND bruto_despues_g IS NOT NULL
          AND bruto_antes_g >= 0 AND bruto_despues_g >= 0)
    );
  END IF;
END;
$$;


-- ─── 2 · Los dos motivos que el laboratorio ya usa ─────────────────────────
--   merma       33 filas en sus libros: producto perdido, no consumido.
--   inventario  156 filas («INV.» / «Inventariado»): una pesada de
--               verificacion que confirma el saldo sin moverlo.
--
-- Cuando esa pesada NO confirma el saldo, la diferencia no se absorbe en
-- silencio: entra como `ajuste_inventario`, que ya existia, con su propio
-- movimiento auditable.

ALTER TABLE kardex DROP CONSTRAINT IF EXISTS kardex_motivo_check;
ALTER TABLE kardex ADD CONSTRAINT kardex_motivo_check CHECK (
  motivo IN ('compra', 'entrega_directa', 'consumo_laboratorio', 'transferencia',
             'censo_inicial', 'ajuste_inventario', 'correccion',
             'merma', 'inventario')
);

-- Una verificacion no es entrada ni salida: no mueve saldo. El trigger ya
-- asigna signo 0 a todo lo que no sea ENTRADA/SALIDA.
ALTER TABLE kardex DROP CONSTRAINT IF EXISTS kardex_tipo_movimiento_check;
ALTER TABLE kardex ADD CONSTRAINT kardex_tipo_movimiento_check CHECK (
  tipo_movimiento IN ('ENTRADA', 'SALIDA', 'TRANSFERENCIA', 'AJUSTE')
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ck_kardex_merma') THEN
    ALTER TABLE kardex ADD CONSTRAINT ck_kardex_merma
      CHECK (motivo <> 'merma' OR (tipo_movimiento = 'SALIDA' AND cantidad_g > 0));
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'ck_kardex_inventario') THEN
    ALTER TABLE kardex ADD CONSTRAINT ck_kardex_inventario
      CHECK (motivo <> 'inventario' OR (tipo_movimiento = 'AJUSTE' AND cantidad_g = 0));
  END IF;
END;
$$;


-- ─── 3 · La cadena de pesadas, comprobada por la base ──────────────────────
-- Si se declara una pesada inicial, tiene que cuadrar con lo que el sistema
-- cree que hay dentro. Un descuadre significa que alguien uso el frasco sin
-- apuntarlo: se rechaza y se obliga a registrar antes el ajuste, en vez de
-- dejar que la diferencia se pierda dentro de un consumo.
--
-- La tolerancia es de 0.05 g, la resolucion util de la RADWAG PS 6100.X7.M.

CREATE OR REPLACE FUNCTION fn_kardex_antes() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
  v_saldo      NUMERIC(14,4);
  v_capacidad  NUMERIC(14,4);
  v_tipo       VARCHAR(10);
  v_custodio   INTEGER;
  v_tara       NUMERIC(14,4);
  v_esperado   NUMERIC(14,4);
  v_signo      INTEGER;
BEGIN
  SELECT f.peso_neto_actual_g, f.peso_neto_inicial_g, i.tipo,
         f.id_investigador, f.tara_g
    INTO v_saldo, v_capacidad, v_tipo, v_custodio, v_tara
    FROM frasco f
    JOIN lote l         ON l.id_lote = f.id_lote
    JOIN presentacion p ON p.id_presentacion = l.id_presentacion
    JOIN insumo i       ON i.id_insumo = p.id_insumo
   WHERE f.id_frasco = NEW.id_frasco
   FOR UPDATE OF f;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'El frasco % no existe', NEW.id_frasco;
  END IF;

  IF v_saldo IS NULL THEN
    RAISE EXCEPTION
      'El frasco % tiene saldo indeterminado (falta la tara): registre la tara '
      'antes de mover producto', NEW.id_frasco
      USING ERRCODE = 'check_violation';
  END IF;

  -- NUEVA · la pesada inicial tiene que cuadrar con el saldo conocido.
  IF NEW.bruto_antes_g IS NOT NULL AND v_tara IS NOT NULL THEN
    v_esperado := v_tara + v_saldo;
    IF abs(NEW.bruto_antes_g - v_esperado) > 0.05 THEN
      RAISE EXCEPTION
        'La pesada no cuadra en el frasco %: la balanza marca % g y deberia '
        'marcar % g (tara % + saldo %). Diferencia de % g: hubo uso sin '
        'registrar. Regularicelo con un ajuste de inventario antes de '
        'continuar.',
        NEW.id_frasco, NEW.bruto_antes_g, v_esperado, v_tara, v_saldo,
        round(NEW.bruto_antes_g - v_esperado, 4)
        USING ERRCODE = 'check_violation';
    END IF;
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

  -- US-13 · un consumo solo descuenta de los frascos de su custodio.
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


-- ─── 4 · La vista de movimientos, con la pesada visible ────────────────────

CREATE OR REPLACE VIEW v_kardex_detalle AS
SELECT k.id_movimiento, k.id_frasco, k.tipo_movimiento, k.motivo,
       k.cantidad_g, k.cantidad_kg, k.cantidad_registrada, k.unidad_registrada,
       k.densidad_aplicada, k.bruto_antes_g, k.bruto_despues_g,
       k.peso_antes_g AS saldo_antes_g, k.saldo_resultante_g AS saldo_despues_g,
       k.fecha_hora, k.fecha_operacion, k.curso, k.usuario_final,
       u.nombre AS registrado_por,
       COALESCE(dest.nombre, orig.nombre) AS investigador,
       -- Como se obtuvo la cifra: es lo que distingue una medicion de una
       -- estimacion cuando alguien pregunte de donde sale el kilo declarado.
       CASE
         WHEN k.bruto_antes_g IS NOT NULL THEN 'pesada'
         WHEN k.unidad_registrada IN ('mL','L') THEN 'volumen convertido'
         WHEN k.unidad_registrada IS NOT NULL   THEN 'cantidad declarada'
         ELSE 'sin origen'
       END AS origen_cantidad
  FROM kardex k
  LEFT JOIN usuario u        ON u.id_usuario = k.registrado_por
  LEFT JOIN investigador dest ON dest.id_investigador = k.id_investigador_destinatario
  LEFT JOIN investigador orig ON orig.id_investigador = k.id_investigador_origen;


INSERT INTO schema_migration (version, descripcion)
VALUES ('006', 'Consumo por doble pesada, motivos merma e inventario')
ON CONFLICT (version) DO NOTHING;

COMMIT;
