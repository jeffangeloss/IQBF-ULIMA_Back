-- ═══════════════════════════════════════════════════════════════════
-- Migración 017: maestros de actividad y curso
--
-- POR QUÉ EXISTE
--
-- `kardex.curso` es VARCHAR(160) de texto libre. En los archivos de
-- trabajo del laboratorio esa misma columna acumula 144 grafías
-- distintas que pertenecen a CINCO dominios diferentes:
--
--     tipo de movimiento   529 usos (28 %)  INGRESO, INV., MERMA
--     persona             1053 usos (56 %)  Chasquibol, Ponce, Bedriñana
--     curso                142 usos ( 7 %)  Q. General, Q. Industrial
--     laboratorio          115 usos ( 6 %)  Docimasia, Lab Alimentos
--     actividad             38 usos ( 2 %)  ACADÉMICO, INVESTIGACIÓN
--
-- Más de la mitad de una columna llamada «CURSO» contiene nombres de
-- personas, y un 28 % contiene tipos de movimiento que ya tienen su
-- propia columna al lado. Solo un 7 % contiene lo que el nombre promete.
--
-- Cuatro de esos cinco dominios YA están bien modelados en el esquema:
-- `tipo_movimiento` y `motivo` con CHECK, `id_laboratorio_origen/destino`
-- e `id_investigador_destinatario` con clave foránea. Los que faltaban
-- son actividad y curso, y son los que esta migración incorpora.
--
-- LA JERARQUÍA
--
-- «Académico» y «Química General» no son valores alternativos: son padre
-- e hijo. El primero dice «esto fue para clases»; el segundo dice para
-- CUÁL clase. Por eso `curso` cuelga de `actividad`.
--
-- POR QUÉ LA CLASIFICACIÓN VA EN SU PROPIA TABLA Y NO EN EL KÁRDEX
--
-- El primer intento añadía `id_actividad` e `id_curso` como columnas del
-- kárdex. No funciona: `fn_kardex_inmutable` prohíbe todo UPDATE sobre
-- esa tabla, así que esas columnas habrían nacido muertas para los
-- movimientos ya registrados —que son justamente los que hay que
-- reclasificar—.
--
-- Y la regla es correcta: el kárdex es el libro, y un libro no se
-- reescribe. La clasificación es una LECTURA POSTERIOR del movimiento,
-- no un hecho del movimiento, y por eso vive aparte, con su propio
-- rastro de quién la hizo y cuándo. Si mañana se reclasifica distinto,
-- cambia la interpretación; el hecho registrado sigue intacto.
-- ═══════════════════════════════════════════════════════════════════

BEGIN;
SET LOCAL search_path TO iqbf, public, pg_catalog;

-- ── 1. Actividad: para qué se usó el insumo ─────────────────────────
-- Son las «bolsas» que el laboratorio ya usa de facto en sus fichas.
CREATE TABLE IF NOT EXISTS actividad (
    id_actividad  VARCHAR(20) PRIMARY KEY,
    nombre        VARCHAR(80) NOT NULL,
    descripcion   TEXT,
    estado        VARCHAR(10) NOT NULL DEFAULT 'VIGENTE'
      CHECK (estado IN ('VIGENTE', 'INACTIVO'))
);

INSERT INTO actividad (id_actividad, nombre, descripcion) VALUES
  ('ACADEMICO',     'Académico',        'Uso en clases de pregrado. Agrupa los cursos del maestro de cursos.'),
  ('INVESTIGACION', 'Investigación',    'Uso en proyectos de investigación.'),
  ('TESIS',         'Tesis',            'Uso por tesistas en su trabajo de titulación.'),
  ('SERVICIO',      'Servicio externo', 'Uso en servicios prestados a terceros.'),
  ('MANTENIMIENTO', 'Mantenimiento',    'Uso en mantenimiento o calibración de equipos.')
ON CONFLICT (id_actividad) DO NOTHING;

-- ── 2. Curso ────────────────────────────────────────────────────────
-- La pareja (id_curso, id_actividad) lleva índice único a propósito: es
-- lo que permite que la clasificación referencie AMBOS a la vez y que la
-- base garantice que el curso pertenece a la actividad declarada, sin
-- necesidad de un CHECK que habría que mantener a mano.
CREATE TABLE IF NOT EXISTS curso (
    id_curso      VARCHAR(20) PRIMARY KEY,
    nombre        VARCHAR(120) NOT NULL,
    id_actividad  VARCHAR(20) NOT NULL DEFAULT 'ACADEMICO'
      REFERENCES actividad(id_actividad) ON DELETE RESTRICT,
    estado        VARCHAR(10) NOT NULL DEFAULT 'VIGENTE'
      CHECK (estado IN ('VIGENTE', 'INACTIVO')),
    UNIQUE (id_curso, id_actividad)
);

INSERT INTO curso (id_curso, nombre, id_actividad) VALUES
  ('QG',   'Química General',              'ACADEMICO'),
  ('QI',   'Química Industrial',           'ACADEMICO'),
  ('QAN',  'Química Analítica',            'ACADEMICO'),
  ('QAP',  'Química Aplicada',             'ACADEMICO'),
  ('Q2',   'Química II',                   'ACADEMICO'),
  ('QYT',  'Química y Tecnología',         'ACADEMICO'),
  ('MIC',  'Microbiología',                'ACADEMICO'),
  ('SEM',  'Seminario',                    'ACADEMICO'),
  ('MAT',  'Materiales de Ingeniería',     'ACADEMICO'),
  ('LGEN', 'Laboratorio General',          'ACADEMICO'),
  ('S300', 'Curso S-300',                  'ACADEMICO'),
  ('S340', 'Curso S-340',                  'ACADEMICO'),
  ('PI2',  'Proyecto de Investigación II', 'INVESTIGACION')
ON CONFLICT (id_curso) DO NOTHING;

-- ── 3. Alias: cada grafía histórica apunta a su curso ───────────────
-- Mismo patrón que `insumo_alias`: la reclasificación se resuelve en la
-- base, no a mano. El alias se guarda ya normalizado (mayúsculas, sin
-- tildes ni puntuación) para que «Q. General», «QUIMICA GENERAL» y
-- «Quím. General» caigan todos en la misma fila.
CREATE TABLE IF NOT EXISTS curso_alias (
    alias     VARCHAR(60) PRIMARY KEY,
    id_curso  VARCHAR(20) NOT NULL
      REFERENCES curso(id_curso) ON DELETE CASCADE
);

INSERT INTO curso_alias (alias, id_curso) VALUES
  ('Q GENERAL', 'QG'), ('QUIM GENERAL', 'QG'), ('QUIMICA GENERAL', 'QG'),
  ('QCA GENERAL', 'QG'), ('LAB QUIMICA GENERAL', 'QG'), ('LAB Q GENERAL', 'QG'),
  ('QUIMICA', 'QG'),
  ('Q INDUSTRIAL', 'QI'), ('QUIMICA INDUSTRIAL', 'QI'), ('QI', 'QI'), ('Q I', 'QI'),
  ('Q ANALITICA', 'QAN'), ('QUIMICA ANALITICA', 'QAN'),
  ('Q APLICADA', 'QAP'), ('QUIMICA APLICADA', 'QAP'),
  ('Q II', 'Q2'), ('Q II HIDRO', 'Q2'), ('Q II RC', 'Q2'),
  ('Q Y T', 'QYT'),
  ('MICROBIOLOGIA', 'MIC'),
  ('SEM', 'SEM'), ('SEM BA', 'SEM'), ('SEM II REY', 'SEM'), ('SEM RUBIO', 'SEM'),
  ('MAT ING', 'MAT'),
  ('LAB GENERAL', 'LGEN'), ('LABORATORIO', 'LGEN'),
  ('S 300', 'S300'), ('S 340', 'S340'),
  ('PROY INV II', 'PI2')
ON CONFLICT (alias) DO NOTHING;

-- ── 4. Clasificación de un movimiento ───────────────────────────────
-- Una fila por movimiento clasificado. El kárdex no se toca.
--
-- La clave foránea compuesta contra `curso(id_curso, id_actividad)` es
-- la que impide declarar «Química General» con actividad TESIS: el curso
-- solo se acepta junto a la actividad de la que cuelga.
CREATE TABLE IF NOT EXISTS kardex_clasificacion (
    id_movimiento    INTEGER PRIMARY KEY
      REFERENCES kardex(id_movimiento) ON DELETE RESTRICT,
    id_actividad     VARCHAR(20) NOT NULL
      REFERENCES actividad(id_actividad) ON DELETE RESTRICT,
    id_curso         VARCHAR(20),
    origen           VARCHAR(30) NOT NULL
      CHECK (origen IN ('alias_automatico', 'revision_manual', 'registro_en_origen')),
    clasificado_por  INTEGER
      REFERENCES usuario(id_usuario) ON DELETE RESTRICT,
    clasificado_en   TIMESTAMPTZ NOT NULL DEFAULT now(),
    nota             TEXT,
    CONSTRAINT fk_clasificacion_curso
      FOREIGN KEY (id_curso, id_actividad)
      REFERENCES curso(id_curso, id_actividad) ON DELETE RESTRICT
);

CREATE INDEX IF NOT EXISTS ix_clasificacion_actividad
  ON kardex_clasificacion (id_actividad);
CREATE INDEX IF NOT EXISTS ix_clasificacion_curso
  ON kardex_clasificacion (id_curso) WHERE id_curso IS NOT NULL;

COMMENT ON TABLE kardex_clasificacion IS
  'Lectura posterior de un movimiento: para qué actividad y, si fue '
  'docencia, para qué curso. Vive aparte porque el kardex es inmutable.';
COMMENT ON COLUMN kardex.curso IS
  'HISTÓRICO, texto libre. Conserva lo que escribió el laboratorio, con '
  'sus 144 grafías. Para consultar por actividad o curso use '
  'kardex_clasificacion.';

-- ── 5. Vista de consulta ────────────────────────────────────────────
-- Deja el join resuelto: quien consulte no tiene que saber que la
-- clasificación vive en otra tabla.
CREATE OR REPLACE VIEW v_kardex_clasificado AS
SELECT k.id_movimiento, k.id_frasco, k.tipo_movimiento, k.motivo,
       k.cantidad_g, k.fecha_operacion, k.curso AS curso_texto_original,
       c.id_actividad, a.nombre AS actividad,
       c.id_curso, cu.nombre AS curso, c.origen AS origen_clasificacion
  FROM kardex k
  LEFT JOIN kardex_clasificacion c ON c.id_movimiento = k.id_movimiento
  LEFT JOIN actividad a           ON a.id_actividad  = c.id_actividad
  LEFT JOIN curso cu              ON cu.id_curso     = c.id_curso;

-- ── 6. Verificación ─────────────────────────────────────────────────
DO $$
DECLARE n_act int; n_cur int; n_ali int; huerfanos int;
BEGIN
    SELECT count(*) INTO n_act FROM actividad;
    SELECT count(*) INTO n_cur FROM curso;
    SELECT count(*) INTO n_ali FROM curso_alias;
    IF n_act < 5 OR n_cur < 13 THEN
        RAISE EXCEPTION 'Migración 017: maestros incompletos (% actividades, % cursos).', n_act, n_cur;
    END IF;
    SELECT count(*) INTO huerfanos
      FROM curso_alias al LEFT JOIN curso c ON c.id_curso = al.id_curso
     WHERE c.id_curso IS NULL;
    IF huerfanos > 0 THEN
        RAISE EXCEPTION 'Migración 017: % alias apuntan a un curso inexistente.', huerfanos;
    END IF;
    RAISE NOTICE 'Migración 017: % actividades, % cursos, % alias. El kardex no se tocó.',
        n_act, n_cur, n_ali;
END $$;

INSERT INTO schema_migration (version, descripcion)
VALUES ('017', '017_maestro_cursos_actividades.sql')
ON CONFLICT DO NOTHING;

COMMIT;

-- ═══════════════════════════════════════════════════════════════════
-- PENDIENTE
-- ═══════════════════════════════════════════════════════════════════
-- 1. Reclasificar los movimientos históricos. Los que traen un curso
--    reconocible se resuelven solos contra `curso_alias`; el 56 % que
--    son nombres de personas hay que mapearlo contra `investigador`.
-- 2. Decidir si `kardex.usuario_final` (texto libre) se retira en favor
--    de `id_investigador_destinatario`, que guarda lo mismo con clave
--    foránea. Hoy conviven y pueden discrepar.
-- 3. Al registrar un consumo nuevo, la clasificación debería crearse en
--    el mismo acto con origen 'registro_en_origen'. Eso es trabajo de la
--    API, no de esta migración.
-- ═══════════════════════════════════════════════════════════════════
