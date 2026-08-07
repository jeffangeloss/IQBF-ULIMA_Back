BEGIN;

SET LOCAL search_path TO iqbf, public, pg_catalog;

-- ═══════════════════════════════════════════════════════════════════════════
-- 007 · El porcentaje de llenado no puede inventarse
--
-- `fraccion_llenado` se calculaba como saldo / equivalencia_g sin comprobar
-- que esa equivalencia fuera creible. Cuando el nominal de la presentacion no
-- corresponde al frasco, sale un porcentaje que PARECE correcto y no lo es.
--
-- El caso que lo destapo: IQF0108-120-35 mostraba «91 %» y condicion «A la
-- mitad» a la vez. Los tres frascos IQF0108-120-34/35/36 son botellas de
-- 2,5 L (4600 g de sulfurico: 2500 mL x 1,84), pero cuelgan de la unica
-- presentacion que el catalogo tiene para el codigo SUNAT 000120, que es de
-- 1 L / 1840 g. De ahi: 1682,62 / 1840 = 91 %, cuando lo real es
-- 1682,62 / 4600 = 37 %.
--
-- El censo usa ese mismo codigo SUNAT para los dos formatos (IQF0108-120-25
-- es de 1 L; -26, -34, -35 y -36 son de 2,5 L), asi que al catalogo le falta
-- la presentacion de 2,5 L. Esa alta es una decision de maestro y no se toma
-- desde aqui.
--
-- Lo que si corresponde arreglar es la vista: un 91 % junto a «A la mitad» es
-- peor que no mostrar nada, porque el 238 % del frasco -34 se ve absurdo a
-- simple vista y este no. Un dato que se contradice se marca, no se pinta.
--
-- La declaracion a SUNAT NO se ve afectada: suma peso_neto_actual_g y nunca
-- usa equivalencia_g.
-- ═══════════════════════════════════════════════════════════════════════════

DROP VIEW IF EXISTS v_alertas_v4 CASCADE;
DROP VIEW IF EXISTS v_declaracion_sunat CASCADE;
DROP VIEW IF EXISTS v_saldo_investigador_v4 CASCADE;
DROP VIEW IF EXISTS v_saldo_laboratorio CASCADE;
DROP VIEW IF EXISTS v_inventario_v4 CASCADE;

CREATE VIEW v_inventario_v4 AS
WITH nominal_dudoso AS (
    -- Un nominal es indefendible si ALGUN frasco de esa presentacion llego a
    -- contener mas de lo que la presentacion dice que cabe. Se evalua por
    -- presentacion y no por frasco: un frasco medio vacio no prueba nada por
    -- si solo, pero uno lleno de sus hermanos delata el nominal de todos.
    SELECT l.id_presentacion
      FROM frasco f
      JOIN lote l ON l.id_lote = f.id_lote
      JOIN presentacion p ON p.id_presentacion = l.id_presentacion
     WHERE p.equivalencia_g > 0
       AND f.peso_neto_inicial_g > p.equivalencia_g * 1.02
     GROUP BY l.id_presentacion
)
SELECT
    f.id_frasco, i.id_insumo, i.nombre_comercial, i.tipo,
    p.id_presentacion, p.codigo_bf_sunat, p.concentracion, p.capacidad,
    p.unidad, p.tipo_envase, p.equivalencia_g AS contenido_nominal_g,
    l.id_lote, l.numero_lote, l.grado_pureza, l.fecha_ingreso, l.fecha_caducidad,
    f.peso_bruto_g, f.tara_g, f.peso_neto_inicial_g, f.peso_neto_actual_g,
    f.saldo_indeterminado, f.fuente_tara, f.fecha_pesaje, f.condicion_envase,
    f.estado AS estado_frasco, f.observaciones,
    inv.id_investigador, inv.nombre AS custodio,
    lab.id_laboratorio, lab.nombre AS laboratorio,
    u.id_ubicacion, u.nombre AS ubicacion, u.casillero, u.nombre_puerta,
    u.nivel, u.posicion, f.precision_ubicacion,
    COALESCE(l.densidad, p.densidad) AS densidad_aplicable,
    CASE
      WHEN i.tipo = 'LIQUIDO' AND COALESCE(l.densidad, p.densidad) IS NOT NULL
       AND f.peso_neto_actual_g IS NOT NULL
      THEN round(f.peso_neto_actual_g / COALESCE(l.densidad, p.densidad), 4)
    END AS volumen_actual_ml,
    (nd.id_presentacion IS NOT NULL) AS nominal_dudoso,
    CASE
      WHEN nd.id_presentacion IS NOT NULL THEN NULL      -- no se inventa
      WHEN p.equivalencia_g IS NULL OR p.equivalencia_g = 0 THEN NULL
      WHEN f.peso_neto_actual_g IS NULL THEN NULL
      ELSE round(f.peso_neto_actual_g / p.equivalencia_g, 4)
    END AS fraccion_llenado,
    CASE
      WHEN l.fecha_caducidad IS NULL             THEN 'POR_CONFIRMAR'
      WHEN l.fecha_caducidad < CURRENT_DATE      THEN 'VENCIDO'
      WHEN l.fecha_caducidad < CURRENT_DATE + 90 THEN 'POR_VENCER'
      ELSE 'VIGENTE'
    END AS estado_caducidad,
    mov.ultimo_movimiento,
    CASE WHEN mov.ultimo_movimiento IS NULL THEN NULL
         ELSE (CURRENT_DATE - mov.ultimo_movimiento::date) END AS dias_sin_movimiento
  FROM frasco f
  JOIN lote l                ON l.id_lote = f.id_lote
  JOIN presentacion p        ON p.id_presentacion = l.id_presentacion
  JOIN insumo i              ON i.id_insumo = p.id_insumo
  LEFT JOIN nominal_dudoso nd ON nd.id_presentacion = p.id_presentacion
  LEFT JOIN investigador inv ON inv.id_investigador = f.id_investigador
  LEFT JOIN ubicacion u      ON u.id_ubicacion = f.id_ubicacion
  LEFT JOIN laboratorio lab
         ON lab.id_laboratorio = COALESCE(f.id_laboratorio_actual, inv.id_laboratorio)
  LEFT JOIN LATERAL (
        SELECT max(k.fecha_hora) AS ultimo_movimiento
          FROM kardex k WHERE k.id_frasco = f.id_frasco
  ) mov ON TRUE;

CREATE VIEW v_alertas_v4 AS
SELECT v.*,
       CASE
         WHEN v.saldo_indeterminado              THEN '0-SALDO_INDETERMINADO'
         WHEN v.estado_caducidad = 'VENCIDO'     THEN '1-VENCIDO'
         WHEN v.tipo = 'LIQUIDO'
          AND v.densidad_aplicable IS NULL       THEN '2-DENSIDAD_PENDIENTE'
         WHEN v.codigo_bf_sunat IS NULL          THEN '3-SIN_CODIGO_SUNAT'
         -- Va aqui a proposito: no impide declarar (la declaracion suma
         -- gramos), pero es un maestro que no describe al frasco que cuelga
         -- de el, y eso hay que resolverlo con el laboratorio.
         WHEN v.nominal_dudoso                   THEN '4-PRESENTACION_NO_CORRESPONDE'
         WHEN v.id_investigador IS NULL          THEN '5-SIN_CUSTODIO'
         WHEN v.estado_caducidad = 'POR_VENCER'  THEN '6-POR_VENCER'
         WHEN v.dias_sin_movimiento >= 730       THEN '7-DORMIDO'
         WHEN v.peso_neto_actual_g = 0
          AND v.estado_frasco <> 'AGOTADO'       THEN '8-REVISAR_ESTADO'
         ELSE '9-SIN_ALERTA'
       END AS alerta_prioritaria
  FROM v_inventario_v4 v;

CREATE VIEW v_declaracion_sunat AS
SELECT v.codigo_bf_sunat, v.id_insumo,
       max(v.nombre_comercial) AS nombre_comercial,
       max(v.tipo)             AS tipo,
       count(*)                AS frascos,
       count(*) FILTER (WHERE v.saldo_indeterminado) AS frascos_indeterminados,
       round(sum(v.peso_neto_actual_g) / 1000.0, 4)  AS saldo_kg,
       round(sum(v.peso_neto_actual_g)
               FILTER (WHERE v.estado_caducidad = 'VENCIDO') / 1000.0, 4)
                                                     AS saldo_vencido_kg
  FROM v_inventario_v4 v
 WHERE v.estado_frasco <> 'DADO_DE_BAJA'
   AND v.codigo_bf_sunat IS NOT NULL
 GROUP BY v.codigo_bf_sunat, v.id_insumo;

CREATE VIEW v_saldo_investigador_v4 AS
SELECT inv.id_investigador, inv.nombre AS custodio,
       count(v.id_frasco)                                      AS frascos,
       count(*) FILTER (WHERE v.estado_caducidad = 'VENCIDO')  AS frascos_vencidos,
       count(*) FILTER (WHERE v.saldo_indeterminado)           AS frascos_indeterminados,
       round(COALESCE(sum(v.peso_neto_actual_g), 0) / 1000.0, 4) AS saldo_kg
  FROM investigador inv
  LEFT JOIN v_inventario_v4 v
         ON v.id_investigador = inv.id_investigador
        AND v.estado_frasco <> 'DADO_DE_BAJA'
 GROUP BY inv.id_investigador, inv.nombre;

CREATE VIEW v_saldo_laboratorio AS
SELECT COALESCE(v.id_laboratorio, -1)              AS id_laboratorio,
       COALESCE(v.laboratorio, 'SIN ASIGNAR')      AS laboratorio,
       v.id_insumo, v.nombre_comercial,
       count(*)                                    AS frascos,
       count(*) FILTER (WHERE v.estado_caducidad = 'VENCIDO') AS frascos_vencidos,
       round(sum(v.peso_neto_actual_g) / 1000.0, 4) AS saldo_kg
  FROM v_inventario_v4 v
 WHERE v.estado_frasco <> 'DADO_DE_BAJA'
 GROUP BY 1, 2, v.id_insumo, v.nombre_comercial;

INSERT INTO schema_migration (version, descripcion)
VALUES ('007', 'El llenado no se calcula contra un nominal que el frasco desmiente')
ON CONFLICT (version) DO NOTHING;

COMMIT;
