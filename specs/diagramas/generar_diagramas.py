#!/usr/bin/env python3
"""
generar_diagramas.py — emite `IQBF_Diagramas.drawio`, el archivo multipágina
que se abre en app.diagrams.net.

Por qué un generador y no un archivo dibujado a mano: los diagramas describen
un sistema que cambia, y uno dibujado a mano envejece en silencio. Aquí el
contenido sale de lo que el sistema *es* —las 41 rutas del OpenAPI, las 25
tablas del esquema, los 6 roles de `permisos.ts`— así que regenerarlo es la
forma de que no mienta.

    python3 specs/diagramas/generar_diagramas.py

El estilo sigue el de los diagramas del curso (PideYa, Patronika): actores
`umlActor`, casos de uso en elipse, frontera `umlFrame`, tablas `shape=table`
con aristas `entityRelationEdgeStyle`, componentes `shape=module` y secuencia
con `umlLifeline`. Paleta ámbar #fff2cc / #d6b656.
"""
from __future__ import annotations

import html
import zlib
from pathlib import Path


def _sello(texto: str) -> int:
    """Identificador estable a partir del nombre.

    `hash()` de Python aleatoriza por proceso, asi que dos ejecuciones daban
    archivos distintos byte a byte y cualquier diff en git era ruido. `crc32`
    no cambia entre ejecuciones: regenerar sin tocar nada no produce diff.
    """
    return zlib.crc32(texto.encode("utf-8"))

SALIDA = Path(__file__).resolve().parent / "IQBF_Diagramas.drawio"

# ─── Estilos, tomados del vocabulario de los diagramas del curso ─────────────

AMBAR = "fillColor=#fff2cc;strokeColor=#d6b656;"
AZUL = "fillColor=#dae8fc;strokeColor=#6c8ebf;"
VERDE = "fillColor=#d5e8d4;strokeColor=#82b366;"
ROJO = "fillColor=#f8cecc;strokeColor=#b85450;"
GRIS = "fillColor=#f5f5f5;strokeColor=#666666;"

E_ACTOR = ("shape=umlActor;verticalLabelPosition=bottom;verticalAlign=top;"
           "html=1;labelBackgroundColor=none;rounded=0;" + AMBAR)
E_CASO = ("ellipse;whiteSpace=wrap;html=1;labelBackgroundColor=none;rounded=0;"
          + AMBAR)
E_FRAME = ("shape=umlFrame;whiteSpace=wrap;html=1;pointerEvents=0;"
           "recursiveResize=0;container=1;collapsible=0;width=260;height=30;"
           "labelBackgroundColor=none;fillColor=none;strokeColor=#666666;"
           "verticalAlign=top;align=left;spacingLeft=6;")
E_LINEA = "edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;"
E_RECTA = "endArrow=none;html=1;rounded=0;"
E_EXT = ("edgeStyle=orthogonalEdgeStyle;rounded=0;html=1;dashed=1;"
         "endArrow=open;endFill=0;")
E_NOTA = ("shape=note;whiteSpace=wrap;html=1;backgroundOutline=1;"
          "darkOpacity=0.05;size=14;" + AMBAR)
E_TITULO = "text;html=1;align=left;verticalAlign=middle;fontSize=15;fontStyle=1;"
E_SUB = "text;html=1;align=left;verticalAlign=middle;fontSize=11;fontColor=#555555;"

E_TABLA = ("shape=table;startSize=26;container=1;collapsible=0;"
           "childLayout=tableLayout;fixedRows=1;rowLines=0;fontStyle=1;"
           "align=center;resizeLast=1;html=1;" + AMBAR)
E_FILA = ("shape=tableRow;horizontal=0;startSize=0;swimlaneHead=0;"
          "swimlaneBody=0;fillColor=none;collapsible=0;dropTarget=0;"
          "points=[[0,0.5],[1,0.5]];portConstraint=eastwest;strokeColor=none;"
          "top=0;left=0;bottom=0;right=0;")
E_CELDA = ("shape=partialRectangle;connectable=0;fillColor=none;top=0;left=0;"
           "bottom=0;right=0;overflow=hidden;whiteSpace=wrap;html=1;"
           "align=left;spacingLeft=6;fontSize=11;")
E_FK = ("edgeStyle=entityRelationEdgeStyle;fontSize=11;html=1;endArrow=ERone;"
        "startArrow=ERmany;exitX=0;exitY=0.5;entryX=1;entryY=0.5;")

E_MODULO = ("shape=module;jettyWidth=8;jettyHeight=4;html=1;whiteSpace=wrap;"
            "align=center;verticalAlign=top;spacingTop=4;")
E_BD = ("strokeWidth=2;html=1;shape=mxgraph.flowchart.database;"
        "whiteSpace=wrap;" + AMBAR)
E_NODO = ("html=1;whiteSpace=wrap;verticalAlign=top;align=left;spacingLeft=8;"
          "spacingTop=4;dashed=1;" + GRIS)
E_LIFELINE = ("shape=umlLifeline;perimeter=lifelinePerimeter;whiteSpace=wrap;"
              "html=1;container=1;dropTarget=0;collapsible=0;recursiveResize=0;"
              "outlineConnect=0;" + AMBAR)
E_MSG = "html=1;verticalAlign=bottom;endArrow=block;"
E_RET = "html=1;verticalAlign=bottom;endArrow=open;dashed=1;endSize=8;"
E_ACT = "html=1;points=[[0,0,0,0,5],[0,1,0,0,-5],[1,0,0,0,5],[1,1,0,0,-5]];perimeter=orthogonalPerimeter;outlineConnect=0;targetShapes=umlLifeline;" + AZUL


class Pagina:
    """Acumula celdas y las emite como una página del .drawio."""

    def __init__(self, nombre: str, ancho: int = 1400, alto: int = 900):
        self.nombre = nombre
        self.ancho, self.alto = ancho, alto
        self.celdas: list[str] = []
        self.n = 0

    def _id(self, pista: str = "") -> str:
        self.n += 1
        return f"{_sello(self.nombre) % 9973}-{pista}{self.n}"

    def caja(self, valor, estilo, x, y, w, h, padre="1", ident=None) -> str:
        ident = ident or self._id()
        self.celdas.append(
            f'<mxCell id="{ident}" value="{html.escape(str(valor))}" '
            f'style="{estilo}" vertex="1" parent="{padre}">'
            f'<mxGeometry x="{x}" y="{y}" width="{w}" height="{h}" as="geometry"/>'
            f"</mxCell>")
        return ident

    def linea(self, origen, destino, estilo=E_LINEA, valor="") -> str:
        ident = self._id("e")
        self.celdas.append(
            f'<mxCell id="{ident}" value="{html.escape(valor)}" '
            f'style="{estilo}" edge="1" parent="1" '
            f'source="{origen}" target="{destino}">'
            f'<mxGeometry relative="1" as="geometry"/></mxCell>')
        return ident

    def titulo(self, texto, subtitulo=""):
        self.caja(texto, E_TITULO, 40, 20, 900, 26)
        if subtitulo:
            self.caja(subtitulo, E_SUB, 40, 46, 1000, 20)

    def xml(self) -> str:
        return (
            f'  <diagram id="{_sello(self.nombre) % 999983}" '
            f'name="{html.escape(self.nombre)}">\n'
            f'    <mxGraphModel dx="1400" dy="900" grid="1" gridSize="10" '
            f'guides="1" tooltips="1" connect="1" arrows="1" fold="1" '
            f'page="1" pageScale="1" pageWidth="{self.ancho}" '
            f'pageHeight="{self.alto}" math="0" shadow="0">\n'
            f"      <root>\n"
            f'        <mxCell id="0"/>\n'
            f'        <mxCell id="1" parent="0"/>\n        '
            + "\n        ".join(self.celdas)
            + "\n      </root>\n    </mxGraphModel>\n  </diagram>\n")


def casos_de_uso(nombre, titulo, subtitulo, actores, frontera, casos,
                 enlaces, extiende=(), nota=None):
    """Una página de casos de uso: actores a la izquierda, sistema a la derecha."""
    p = Pagina(nombre)
    p.titulo(titulo, subtitulo)

    ids_actor = {}
    y = 130
    for a in actores:
        ids_actor[a] = p.caja(a, E_ACTOR, 60, y, 30, 60)
        y += 130

    alto_frame = max(len(casos) * 80 + 60, y - 90)
    p.caja(frontera, E_FRAME, 320, 100, 700, alto_frame)

    ids_caso = {}
    for i, c in enumerate(casos):
        col, fila = i % 2, i // 2
        ids_caso[c] = p.caja(c, E_CASO, 370 + col * 330, 150 + fila * 95, 280, 60)

    for actor, caso in enlaces:
        p.linea(ids_actor[actor], ids_caso[caso])
    for origen, destino, etiqueta in extiende:
        p.linea(ids_caso[origen], ids_caso[destino], E_EXT, etiqueta)

    if nota:
        p.caja(nota, E_NOTA, 1060, 130, 290, 190)
    return p


# ─── P1 · Caso de uso de negocio ─────────────────────────────────────────────

ROLES = ["Responsable IQBF", "Operador de docimasia", "Docente investigador",
         "Aprobador", "Auditor", "Administrador técnico"]

P1 = casos_de_uso(
    "Caso de Uso de Negocio",
    "IQBF — Caso de uso de negocio",
    "Control de insumos químicos y bienes fiscalizados · Laboratorio de Docimasia, Universidad de Lima · D.L. 1126",
    ROLES,
    "Sistema IQBF",
    ["Gestionar seguridad y cuentas",
     "Mantener maestros y catálogos",
     "Levantar y consultar el inventario",
     "Registrar consumos y ajustes",
     "Autorizar el uso y resolver excepciones",
     "Consolidar la declaración SUNAT",
     "Consultar el kardex de un frasco",
     "Importar y conciliar el censo físico"],
    [("Administrador técnico", "Gestionar seguridad y cuentas"),
     ("Responsable IQBF", "Gestionar seguridad y cuentas"),
     ("Responsable IQBF", "Mantener maestros y catálogos"),
     ("Responsable IQBF", "Importar y conciliar el censo físico"),
     ("Responsable IQBF", "Consolidar la declaración SUNAT"),
     ("Responsable IQBF", "Autorizar el uso y resolver excepciones"),
     ("Operador de docimasia", "Levantar y consultar el inventario"),
     ("Operador de docimasia", "Registrar consumos y ajustes"),
     ("Docente investigador", "Levantar y consultar el inventario"),
     ("Aprobador", "Autorizar el uso y resolver excepciones"),
     ("Auditor", "Consultar el kardex de un frasco")],
    nota=("El ROL y el ALCANCE son cosas distintas.\n\n"
          "El alcance global NO otorga roles: el servidor lo "
          "exige ADEMÁS del rol, nunca en su lugar.\n\n"
          "AVISO · El rol AUDITOR no aparece en ningún "
          "require_roles: hoy no habilita nada distinto de "
          "una cuenta autenticada cualquiera.\n\n"
          "La BITÁCORA se llena sola por disparadores de la "
          "base, pero NINGUNA ruta la lee: solo se consulta "
          "por SQL.\n\n"
          "La MERMA y las BAJAS existen en el modelo y "
          "ninguna ruta las produce: el motivo va fijo en "
          "cada INSERT."))

# ─── P2 · Gestionar Seguridad ────────────────────────────────────────────────

P2 = casos_de_uso(
    "Gestionar Seguridad",
    "Gestionar seguridad, cuentas y alcance",
    "US-001 · US-002 · US-003 · US-006 — 7 rutas: /api/auth/* y /api/usuarios",
    ["Usuario", "Administrador técnico", "Responsable IQBF"],
    "Sistema IQBF — Seguridad",
    ["Iniciar sesión", "Cerrar sesión",
     "Consultar identidad y permisos", "Crear cuenta",
     "Bloquear o desactivar una cuenta", "Asignar roles a una cuenta",
     "Definir el alcance por establecimiento o laboratorio",
     "Listar y consultar cuentas"],
    [("Usuario", "Iniciar sesión"),
     ("Usuario", "Cerrar sesión"),
     ("Usuario", "Consultar identidad y permisos"),
     ("Administrador técnico", "Crear cuenta"),
     ("Administrador técnico", "Bloquear o desactivar una cuenta"),
     ("Administrador técnico", "Definir el alcance por establecimiento o laboratorio"),
     ("Responsable IQBF", "Asignar roles a una cuenta"),
     ("Responsable IQBF", "Listar y consultar cuentas"),
     ("Administrador técnico", "Listar y consultar cuentas")],
    extiende=[],
    nota=("Separación de poderes, con su letra pequeña:\n\n"
          "• Crear cuentas → ADMIN_TECNICO\n"
          "• CAMBIAR roles de una cuenta ya creada →\n"
          "  RESPONSABLE_IQBF\n"
          "Ambos exigen además alcance global.\n\n"
          "PERO al CREAR la cuenta, POST /api/usuarios exige "
          "el campo `roles` y lo persiste — así que el "
          "ADMIN_TECNICO sí fija los roles iniciales.\n\n"
          "Y no hay guarda contra la automodificación: "
          "un RESPONSABLE_IQBF puede editarse a sí mismo.\n\n"
          "Una cuenta no se borra: cambia de estado."))

# ─── P3 · Gestionar Maestros ─────────────────────────────────────────────────

P3 = casos_de_uso(
    "Gestionar Maestros",
    "Mantener insumos, presentaciones y catálogos",
    "US-004 · US-005 · US-007 · US-008 · US-009 · US-010 · US-011 · US-013 — 14 rutas",
    ["Responsable IQBF", "Operador de docimasia"],
    "Sistema IQBF — Maestros",
    ["Crear o editar un insumo", "Inactivar un insumo",
     "Crear o editar una presentación", "Inactivar una presentación",
     "Versionar la densidad con vigencia", "Buscar por nombre o por código",
     "Mantener los catálogos controlados", "Exportar un catálogo a CSV"],
    [("Responsable IQBF", "Crear o editar un insumo"),
     ("Responsable IQBF", "Inactivar un insumo"),
     ("Responsable IQBF", "Crear o editar una presentación"),
     ("Responsable IQBF", "Inactivar una presentación"),
     ("Responsable IQBF", "Versionar la densidad con vigencia"),
     ("Responsable IQBF", "Mantener los catálogos controlados"),
     ("Operador de docimasia", "Buscar por nombre o por código"),
     ("Operador de docimasia", "Exportar un catálogo a CSV")],
    nota=("La búsqueda pasa por la tabla de ALIAS, y el "
          "mecanismo funciona.\n\n"
          "PERO el dato falta donde más hace falta: el "
          "etanol (IQF0304), el metanol (IQF0308) y el "
          "ácido nítrico (IQF0106) tienen CERO alias "
          "sembrados, justo los 19 frascos cargados el "
          "2026-08-07.\n\n"
          "Hoy quien pide «etanol» NO los encuentra por "
          "alias. Hay que sembrarlos.\n\n"
          "Buscar y exportar no exigen ningún rol: los "
          "hace cualquier cuenta autenticada."))

# ─── P4 · Inventario y consumo ───────────────────────────────────────────────

P4 = casos_de_uso(
    "Gestionar Inventario y Consumo",
    "Levantar el inventario y registrar el consumo",
    "US-018 · US-019 · US-030 · US-033 · US-034 · US-036 · US-050 — 9 rutas",
    ["Operador de docimasia", "Docente investigador", "Responsable IQBF"],
    "Sistema IQBF — Inventario",
    ["Buscar frascos con filtros", "Ver la ficha y el kardex de un frasco",
     "Consultar el panel del inventario", "Consultar el saldo de todos los custodios",
     "Consultar el stock por laboratorio", "Registrar consumo por doble pesada",
     "Registrar consumo por cantidad", "Confirmar el saldo sin moverlo",
     "Consolidar la declaración SUNAT", "Rechazar el movimiento inválido"],
    [("Operador de docimasia", "Buscar frascos con filtros"),
     ("Operador de docimasia", "Ver la ficha y el kardex de un frasco"),
     ("Operador de docimasia", "Registrar consumo por doble pesada"),
     ("Operador de docimasia", "Registrar consumo por cantidad"),
     ("Operador de docimasia", "Confirmar el saldo sin moverlo"),
     ("Docente investigador", "Consultar el saldo de todos los custodios"),
     ("Docente investigador", "Buscar frascos con filtros"),
     ("Responsable IQBF", "Consultar el stock por laboratorio"),
     ("Responsable IQBF", "Consolidar la declaración SUNAT"),
     ("Responsable IQBF", "Consultar el panel del inventario")],
    extiende=[("Registrar consumo por doble pesada", "Rechazar el movimiento inválido", "«extend»"),
              ("Registrar consumo por cantidad", "Rechazar el movimiento inválido", "«extend»")],
    nota=("Quién impone cada rechazo, que NO es lo mismo:\n\n"
          "LA BASE (un INSERT a mano con psql choca\n"
          "contra la misma regla):\n"
          "• SALDO_INSUFICIENTE\n"
          "• CUSTODIA_AJENA\n"
          "• SALDO_INDETERMINADO (sin tara)\n"
          "• KARDEX_INMUTABLE\n"
          "• SALDO_SOLO_VIA_KARDEX\n\n"
          "LA APLICACIÓN, antes de escribir:\n"
          "• PESADA_NO_CUADRA\n"
          "• AUTORIZACION_INSUFICIENTE\n\n"
          "Estas dos SÍ se pueden rodear por SQL directo.\n\n"
          "AVISO · Ninguna de las 9 rutas de inventario\n"
          "exige rol: las nueve las puede llamar cualquier\n"
          "cuenta autenticada. El reparto por actor de este\n"
          "diagrama es de NEGOCIO, no de autorización."))

# ─── P5 · Autorizaciones y excepciones ───────────────────────────────────────

P5 = casos_de_uso(
    "Gestionar Autorizaciones",
    "Autorizar el uso y resolver excepciones — épica E4",
    "US-023 a US-029 — 10 rutas: /api/autorizaciones y /api/excepciones",
    ["Responsable IQBF", "Docente investigador", "Aprobador",
     "Operador de docimasia"],
    "Sistema IQBF — Autorizaciones",
    ["Registrar una autorización en borrador", "Poner la autorización en vigor",
     "Revocar con motivo obligatorio", "Adjuntar el oficio de soporte",
     "Descargar una versión del soporte", "Consultar mis autorizaciones y saldo",
     "Validar el cupo antes de entregar", "Solicitar una excepción",
     "Aprobar o rechazar la excepción", "Ejecutar el consumo al aprobar"],
    [("Responsable IQBF", "Registrar una autorización en borrador"),
     ("Responsable IQBF", "Poner la autorización en vigor"),
     ("Responsable IQBF", "Revocar con motivo obligatorio"),
     ("Responsable IQBF", "Adjuntar el oficio de soporte"),
     ("Docente investigador", "Consultar mis autorizaciones y saldo"),
     ("Docente investigador", "Descargar una versión del soporte"),
     ("Operador de docimasia", "Solicitar una excepción"),
     ("Aprobador", "Aprobar o rechazar la excepción"),
     ("Responsable IQBF", "Aprobar o rechazar la excepción")],
    extiende=[("Validar el cupo antes de entregar", "Solicitar una excepción", "«extend»"),
              ("Aprobar o rechazar la excepción", "Ejecutar el consumo al aprobar", "«extend» solo si se aprueba")],
    nota=("El saldo autorizado NO se guarda: se recalcula\n"
          "desde el kardex en cada consulta.\n\n"
          "Aprobar EJECUTA el consumo en el mismo acto.\n"
          "Si el consumo falla, la aprobación se revierte\n"
          "con él.\n\n"
          "Sustituir el soporte no borra: añade versión.\n\n"
          "El control nace APAGADO por establecimiento."))


# ─── P6 · Componentes y despliegue ───────────────────────────────────────────

def componentes():
    p = Pagina("Componentes y Despliegue", 1400, 940)
    p.titulo("Componentes y despliegue",
             "EN-005 · Desplegado el 2026-08-06 · verificado el 2026-08-07 · "
             "87 frascos y 111,76 kg en producción")

    p.caja("Vercel · CDN", E_NODO, 60, 110, 330, 210)
    spa = p.caja("iqbf-ulima-front\nSPA React 18 + Vite + TypeScript\n"
                 "5 módulos contra la API", E_MODULO + AZUL, 90, 155, 270, 90)
    p.caja("El token vive en sessionStorage:\nla sesión muere al cerrar la "
           "pestaña.\nSon equipos compartidos.", E_SUB, 90, 255, 280, 50)

    p.caja("Render · Oregon", E_NODO, 470, 110, 380, 400)
    api = p.caja("iqbf-api\nFastAPI + psycopg 3 · Python 3.12\n"
                 "41 rutas en 7 módulos", E_MODULO + VERDE, 500, 155, 320, 90)
    p.caja("Migraciones encadenadas al arranque.\n"
           "Si una falla, el servicio NO arranca.", E_SUB, 500, 252, 330, 40)
    bd = p.caja("iqbf-db\nPostgreSQL 16\n25 tablas · 11 vistas", E_BD,
                560, 320, 200, 150)

    p.caja("Puesto del laboratorio", E_NODO, 940, 110, 400, 400)
    censo = p.caja("Censo fotográfico\nCimiento_Censo_IQBF_v5.xlsx\n"
                   "199 filas · 68 columnas", E_MODULO + AMBAR, 970, 155, 340, 80)
    carga = p.caja("carga_censo_v4.py + preflight_carga.py\n"
                   "8 comprobaciones por fila", E_MODULO + AMBAR, 970, 265, 340, 70)
    alldata = p.caja("ALL.DATA · CONTROL DE REACTIVOS\n"
                     "219 fichas · 811 movimientos", E_MODULO + GRIS, 970, 375, 340, 70)

    p.linea(spa, api, E_LINEA, "HTTPS · JSON\nBearer JWT")
    p.linea(api, bd, E_LINEA, "TLS · psycopg")
    p.linea(censo, carga, E_LINEA)
    p.linea(alldata, carga, E_LINEA, "tara y lote")
    p.linea(carga, bd, E_LINEA, "SQL idempotente\nen UNA transacción")

    p.caja("Lo que NO existe todavía\n\n"
           "• Sin integración continua: las 48 pruebas no\n"
           "  corren en ningún PR (EN-009, EN-011).\n"
           "• Sin copia de seguridad automática ni\n"
           "  restauración ensayada (EN-013).\n"
           "• Sin ambiente de staging desplegado.\n"
           "• La base gratuita EXPIRA EL 2026-08-29.",
           E_NOTA + ROJO, 60, 560, 400, 190)

    p.caja("Por qué el censo no vive en el repositorio\n\n"
           "Es el inventario de un laboratorio fiscalizado\n"
           "—posiciones de almacén, custodios y cantidades—\n"
           "y los dos repositorios son públicos.\n"
           "`bd/` está en .gitignore por lo mismo.",
           E_NOTA, 520, 560, 400, 160)
    return p


P6 = componentes()


# ─── P7 · Diagrama de base de datos ──────────────────────────────────────────

TABLAS = {
    "usuario": ["id_usuario PK", "email UQ", "contrasena", "estado",
                "alcance_global", "intentos_fallidos", "bloqueado_hasta"],
    "rol": ["codigo PK", "nombre"],
    "usuario_rol": ["id_usuario FK", "codigo_rol FK"],
    "usuario_alcance": ["id_usuario FK", "id_establecimiento FK", "id_laboratorio FK"],
    "establecimiento": ["id_establecimiento PK", "codigo UQ", "nombre", "exige_autorizacion"],
    "carrera": ["id_carrera PK", "codigo UQ", "nombre"],
    "laboratorio": ["id_laboratorio PK", "id_establecimiento FK", "id_carrera FK", "nombre"],
    "ubicacion": ["id_ubicacion PK", "id_establecimiento FK", "id_laboratorio FK",
                  "casillero", "nivel", "posicion"],
    "investigador": ["id_investigador PK", "codigo_institucional UQ", "nombre",
                     "tipo PERSONA|AREA", "id_laboratorio FK", "id_carrera FK"],
    "insumo": ["id_insumo PK", "nombre_comercial", "tipo LIQUIDO|SOLIDO",
               "unidad_base", "densidad_variable"],
    "insumo_alias": ["id_insumo FK", "alias", "— 27 sembrados"],
    "presentacion": ["id_presentacion PK", "id_insumo FK", "codigo_bf_sunat",
                     "capacidad", "unidad", "equivalencia_g", "densidad"],
    "densidad_vigencia": ["id_densidad PK", "id_presentacion FK", "valor",
                          "vigencia_desde", "vigencia_hasta"],
    "lote": ["id_lote PK", "id_presentacion FK", "numero_lote",
             "fecha_caducidad", "densidad"],
    "frasco": ["id_frasco PK", "id_lote FK", "id_investigador FK",
               "id_ubicacion FK", "id_laboratorio_actual FK", "peso_bruto_g",
               "tara_g", "peso_neto_actual_g NULL = indeterminado",
               "fuente_tara"],
    "kardex": ["id_movimiento PK", "id_frasco FK", "tipo_movimiento",
               "motivo", "cantidad_g", "densidad_aplicada CONGELADA",
               "id_densidad_aplicada FK", "id_investigador_origen FK",
               "id_investigador_destinatario FK", "id_laboratorio_origen FK",
               "id_laboratorio_destino FK", "saldo_resultante_g",
               "registrado_por FK"],
    "autorizacion": ["id_autorizacion PK", "id_investigador FK", "id_insumo FK",
                     "cantidad_autorizada_g", "vigencia_desde", "vigencia_hasta",
                     "estado"],
    "autorizacion_documento": ["id_documento PK", "id_autorizacion FK",
                               "version", "sha256", "contenido"],
    "excepcion": ["id_excepcion PK", "id_frasco FK", "id_investigador FK",
                  "cantidad_g", "regla_infringida", "estado",
                  "id_movimiento FK UQ"],
    "bitacora": ["id_evento PK", "id_usuario FK", "accion", "entidad",
                 "valores_antes", "valores_despues", "request_id"],
}

# (origen, destino) de las claves ajenas que cuentan la historia.
RELACIONES = [
    ("usuario_rol", "usuario"), ("usuario_rol", "rol"),
    ("usuario_alcance", "usuario"), ("usuario_alcance", "establecimiento"),
    ("laboratorio", "establecimiento"), ("laboratorio", "carrera"),
    ("ubicacion", "laboratorio"), ("investigador", "laboratorio"),
    ("insumo_alias", "insumo"), ("presentacion", "insumo"),
    ("densidad_vigencia", "presentacion"), ("lote", "presentacion"),
    ("frasco", "lote"), ("frasco", "investigador"), ("frasco", "ubicacion"),
    ("kardex", "frasco"), ("kardex", "investigador"), ("kardex", "usuario"),
    ("kardex", "densidad_vigencia"), ("kardex", "laboratorio"),
    ("ubicacion", "establecimiento"), ("usuario_alcance", "laboratorio"),
    ("investigador", "carrera"),
    ("autorizacion", "investigador"), ("autorizacion", "insumo"),
    ("autorizacion_documento", "autorizacion"),
    ("excepcion", "frasco"), ("excepcion", "kardex"), ("bitacora", "usuario"),
]

COLUMNAS_BD = [
    ["usuario", "rol", "usuario_rol", "usuario_alcance"],
    ["establecimiento", "carrera", "laboratorio", "ubicacion", "investigador"],
    ["insumo", "insumo_alias", "presentacion", "densidad_vigencia", "lote"],
    ["frasco", "kardex", "bitacora"],
    ["autorizacion", "autorizacion_documento", "excepcion"],
]


def base_de_datos():
    p = Pagina("DiagramaBD", 1900, 1500)
    p.titulo("Modelo de datos — 25 tablas",
             "EN-002 · EN-006 · migraciones 000 a 010 · las columnas mostradas "
             "son la clave primaria, las ajenas y las que deciden una regla")

    ids = {}
    for col, grupo in enumerate(COLUMNAS_BD):
        y = 110
        for nombre in grupo:
            campos = TABLAS[nombre]
            alto = 26 + len(campos) * 22
            tid = p.caja(nombre, E_TABLA, 60 + col * 370, y, 300, alto)
            ids[nombre] = tid
            for j, campo in enumerate(campos):
                fid = p.caja("", E_FILA, 0, 26 + j * 22, 300, 22, padre=tid)
                p.caja(campo, E_CELDA, 0, 0, 300, 22, padre=fid)
            y += alto + 45
    for origen, destino in RELACIONES:
        p.linea(ids[origen], ids[destino], E_FK)

    p.caja("Tres reglas que vive la base, no la aplicación\n\n"
           "1 · El saldo solo se mueve por el KARDEX.\n"
           "    Un UPDATE directo sobre frasco.peso_neto_actual_g\n"
           "    se rechaza: SALDO_SOLO_VIA_KARDEX.\n\n"
           "2 · El kardex es INMUTABLE. UPDATE y DELETE\n"
           "    rechazados: KARDEX_INMUTABLE. Se corrige con\n"
           "    un movimiento de reversa, no editando.\n\n"
           "3 · peso_neto_actual_g NULL es «indeterminado»,\n"
           "    no cero — y la base impide moverlo.\n\n"
           "No se dibujan: schema_migration, seed_migration,\n"
           "sesion, proveedor, procedencia.",
           E_NOTA, 60, 1180, 520, 260)
    return p


P7 = base_de_datos()


# ─── P8 · Secuencia: consumo por doble pesada ────────────────────────────────

def secuencia():
    p = Pagina("Secuencia — Consumo por doble pesada", 1500, 1150)
    p.titulo("Consumo por doble pesada — US-030, US-033, US-034, US-036",
             "Es como trabaja el laboratorio en sus libros CONTROL DE REACTIVOS: "
             "el frasco entero se pesa antes y después, y el consumo es la resta")

    lineas = [
        ("Operario\n(cualquier cuenta)", 80),
        ("InventarioView\n(SPA)", 330),
        ("POST /api/movimientos/\nconsumo-por-pesada", 600),
        ("PostgreSQL\nfn_kardex_antes", 920),
        ("kardex\n(append-only)", 1220),
    ]
    ids = {}
    for nombre, x in lineas:
        ids[nombre] = p.caja(nombre, E_LIFELINE, x, 110, 190, 860)

    pasos = [
        (0, 1, "1 · pesa el frasco lleno → bruto_antes", E_MSG),
        (0, 1, "2 · sirve y vuelve a pesar → bruto_despues", E_MSG),
        (1, 1, "3 · muestra el consumo derivado (resta)", E_MSG),
        (1, 2, "4 · POST {bruto_antes, bruto_despues, titular, curso}", E_MSG),
        (2, 2, "5 · ¿bruto_antes = tara + saldo?  (lo comprueba la API)", E_MSG),
        (2, 2, "6 · ¿el establecimiento exige autorización?  (la API)", E_MSG),
        (2, 3, "7 · INSERT INTO kardex (SALIDA, consumo_laboratorio)", E_MSG),
        (3, 3, "8 · ¿hay saldo? ¿es su custodio? ¿tiene tara?  (disparador)", E_MSG),
        (3, 4, "9 · escribe el movimiento y actualiza el saldo", E_MSG),
        (4, 2, "10 · saldo_resultante_g", E_RET),
        (2, 1, "11 · 201 · ConsumoOut con la densidad congelada", E_RET),
        (1, 0, "12 · «se descontaron 596,00 g · quedan 1.878,43 g»", E_RET),
    ]
    y = 210
    for origen, destino, texto, estilo in pasos:
        xo = lineas[origen][1] + 95
        xd = lineas[destino][1] + 95
        ident = p._id("m")
        if origen == destino:
            p.celdas.append(
                f'<mxCell id="{ident}" value="{html.escape(texto)}" '
                f'style="{estilo}html=1;align=left;spacingLeft=6;'
                f'edgeStyle=orthogonalEdgeStyle;" edge="1" parent="1">'
                f'<mxGeometry relative="1" as="geometry">'
                f'<mxPoint x="{xo}" y="{y}" as="sourcePoint"/>'
                f'<mxPoint x="{xo}" y="{y + 40}" as="targetPoint"/>'
                f'<Array as="points"><mxPoint x="{xo + 90}" y="{y}"/>'
                f'<mxPoint x="{xo + 90}" y="{y + 40}"/></Array>'
                f"</mxGeometry></mxCell>")
            y += 70
        else:
            p.celdas.append(
                f'<mxCell id="{ident}" value="{html.escape(texto)}" '
                f'style="{estilo}" edge="1" parent="1">'
                f'<mxGeometry relative="1" as="geometry">'
                f'<mxPoint x="{xo}" y="{y}" as="sourcePoint"/>'
                f'<mxPoint x="{xd}" y="{y}" as="targetPoint"/>'
                f"</mxGeometry></mxCell>")
            y += 60

    p.caja("El camino que NO cuadra (paso 5)\n\n"
           "Si la primera pesada no coincide con tara + saldo,\n"
           "la API responde 409 PESADA_NO_CUADRA ANTES de\n"
           "escribir nada.\n\n"
           "El descuadre va en los DOS sentidos:\n"
           "  · falta producto  → salió sin registrarse\n"
           "  · sobra producto  → entró sin registrarse\n\n"
           "Reenviar con ajustar_diferencia: true lo\n"
           "regulariza con un movimiento propio y anterior al\n"
           "consumo — ENTRADA si sobra, SALIDA si falta. El\n"
           "descuadre queda escrito, no absorbido.",
           E_NOTA + ROJO, 60, 1000, 460, 145)

    p.caja("Quién comprueba qué, que no es lo mismo\n\n"
           "Pasos 5 y 6 los hace LA API, antes de escribir: se\n"
           "pueden rodear con un INSERT a mano.\n\n"
           "El paso 8 lo hace un DISPARADOR de PostgreSQL:\n"
           "saldo, custodia y tara se comprueban aunque el\n"
           "INSERT venga por psql. Esa es la parte que vale en\n"
           "un sistema fiscalizado.\n\n"
           "El endpoint NO exige rol: lo llama cualquier cuenta\n"
           "autenticada. La densidad se congela (US-036).",
           E_NOTA, 570, 1000, 470, 145)
    return p


P8 = secuencia()


# ─── Ensamblado ──────────────────────────────────────────────────────────────

PAGINAS = [P1, P2, P3, P4, P5, P6, P7, P8]

if __name__ == "__main__":
    xml = ('<mxfile host="app.diagrams.net" agent="IQBF generar_diagramas.py" '
           f'version="28.2.8" pages="{len(PAGINAS)}">\n'
           + "".join(p.xml() for p in PAGINAS)
           + "</mxfile>\n")
    SALIDA.write_text(xml, encoding="utf-8")
    print(f"escrito: {SALIDA}")
    print(f"  {len(PAGINAS)} páginas · {len(xml):,} bytes")
    for p in PAGINAS:
        print(f"   · {p.nombre} ({len(p.celdas)} celdas)")
