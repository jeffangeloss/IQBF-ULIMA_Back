#!/usr/bin/env python3
"""
carga_censo_v4.py — genera el SQL de carga inicial desde el censo fotográfico.

Solo emite las filas que superan `_CENSO_PIPELINE/preflight_carga.py`. Una fila
con una contradicción interna (el neto no cuadra con bruto-tara, el código SUNAT
no tiene 6 dígitos, el lote es una fecha) NO se carga: se queda fuera y se
reporta. Es deliberado — es más barato volver a la foto que sacar un número
inventado de una declaración a SUNAT.

    python3 carga_censo_v4.py --salida bd/carga_censo_liquidos.sql
    psql "$IQBF_DATABASE_URL" -v ON_ERROR_STOP=1 -f bd/carga_censo_liquidos.sql

El SQL resultante es idempotente (ON CONFLICT DO NOTHING / DO UPDATE) y va
dentro de una sola transacción: o entra el censo entero o no entra nada.
"""
from __future__ import annotations

import argparse
import datetime as dt
import re
import sys
import unicodedata
from decimal import Decimal
from pathlib import Path

import openpyxl

_RUTAS_CENSO = [
    Path("/Users/jjjangelosss/Downloads/IQBF_ENTREGA_MAC_2026-07-22/IQF_Censo"),
    Path("/Users/jjjangelosss/Desktop/IQF_Censo"),
    Path(__file__).resolve().parent.parent / "IQF_Censo",
]
RAIZ_CENSO = next((p for p in _RUTAS_CENSO if p.exists()), _RUTAS_CENSO[0])
LIBRO = RAIZ_CENSO / "outputs" / "censo-iqbf-20260805" / \
    "Cimiento_Censo_IQBF_v5_2026-08-06.xlsx"
sys.path.insert(0, str(RAIZ_CENSO / "_CENSO_PIPELINE"))

FECHA_CENSO = dt.date(2026, 8, 5)
ESTABLECIMIENTO = "ULIMA-DOCIMASIA"
# El almacén fiscalizado está en Docimasia: las ubicaciones cuelgan de ahí.
LABORATORIO_DEL_ALMACEN = "Docimasia"

# ─── Lista controlada de custodios (US-04) ───────────────────────────────────
#
# La columna «Investigador confirmado» del censo es texto libre y trae a la
# misma persona escrita de tres formas. Sin esta tabla, «Ponce» y «SILVIA
# PONCE» serían dos custodios distintos y «cuánto le queda a Ponce» daría una
# cifra incompleta — que es justo lo que US-04 existe para evitar.
#
# Cada fusión se apoya en la evidencia de la PROPIA fila (la columna «Custodio
# (etiqueta)» del frasco), no en un parecido de apellidos:
#
#   Ponce / SILVIA PONCE          → los frascos 55 y 56 llevan «SILVIA PONCE»
#   Yacono / Juan (Carlos) Yacono → los frascos 84 y 99 llevan el nombre entero
#   VILLAGARCIA                   → el frasco 64 lleva «H. VILLAGARCIA»
#
# ÁREA y PERSONA se separan porque el saldo por persona (US-09) y el saldo por
# área no son la misma pregunta. «Académico (Muedas)» es la persona Muedas
# dentro del área Académico.
#
# REVISAR CON EL LABORATORIO antes de dar la carga por definitiva.
ALIAS_CUSTODIO: dict[str, tuple[str, str]] = {
    "ponce":                 ("Silvia Ponce", "PERSONA"),
    "silvia ponce":          ("Silvia Ponce", "PERSONA"),
    "yacono":                ("Juan Carlos Yacono", "PERSONA"),
    "juan yacono":           ("Juan Carlos Yacono", "PERSONA"),
    "juan carlos yacono":    ("Juan Carlos Yacono", "PERSONA"),
    "chasquibol":            ("Chasquibol", "PERSONA"),
    "villagarcia":           ("H. Villagarcía", "PERSONA"),
    "quino":                 ("Quino", "PERSONA"),
    "academico (muedas)":    ("Muedas", "PERSONA"),
    "academico (la cruz)":   ("La Cruz", "PERSONA"),
    # 2026-08-07 · Al ampliar la carga de 19 a 68 frascos aparecieron grafías
    # nuevas. «Prof. Yacono» habría creado un SEGUNDO Juan Carlos Yacono, que
    # es exactamente el defecto que esta tabla existe para evitar: «cuánto le
    # queda a Yacono» habría dado una cifra partida en dos.
    "prof. yacono":          ("Juan Carlos Yacono", "PERSONA"),
    "prof yacono":           ("Juan Carlos Yacono", "PERSONA"),
    "sanabria":              ("Sanabria", "PERSONA"),
    "muedas":                ("Muedas", "PERSONA"),
    "la cruz":               ("La Cruz", "PERSONA"),
    "w. hernandez":          ("W. Hernández", "PERSONA"),
    "hernandez":             ("W. Hernández", "PERSONA"),
    "montoya":               ("Montoya", "PERSONA"),
    "a. gutarra":            ("A. Gutarra", "PERSONA"),
    "gutarra":               ("A. Gutarra", "PERSONA"),
    "arroyo":                ("Arroyo", "PERSONA"),
    # Áreas: el censo no llegó a nombrar a la persona responsable.
    "academico":             ("Académico", "AREA"),
    "ing. civil":            ("Ing. Civil", "AREA"),
    "ing civil":             ("Ing. Civil", "AREA"),
    "lab docimasia":         ("Lab. Docimasia", "AREA"),
    "lab. docimasia":        ("Lab. Docimasia", "AREA"),
    "docimasia":             ("Lab. Docimasia", "AREA"),
    "lab alimentos":         ("Lab. Alimentos", "AREA"),
    "lab. alimentos":        ("Lab. Alimentos", "AREA"),
}

# ─── Equivalencias contra la base destino ───────────────────────────────────
#
# La base de produccion ya tiene su propio catalogo de custodios, escrito en
# mayusculas («PONCE»), y el censo escribe «Silvia Ponce». Sin esta tabla la
# carga crearia un SEGUNDO investigador para la misma persona — justo el
# defecto que US-04 existe para evitar — y «cuanto le queda a Ponce» daria una
# cifra partida en dos.
EQUIVALENTES_DESTINO: dict[str, list[str]] = {
    "Silvia Ponce":       ["PONCE", "Ponce", "Silvia Ponce", "SILVIA PONCE"],
    "Juan Carlos Yacono": ["YACONO", "Yacono", "Juan Yacono", "Juan Carlos Yacono"],
    "Chasquibol":         ["CHASQUIBOL", "Chasquibol"],
    "H. Villagarcía":     ["VILLAGARCIA", "Villagarcia", "Villagarcía", "H. Villagarcía"],
    "Quino":              ["QUINO", "Quino"],
    "Muedas":             ["MUEDAS", "Muedas"],
    "La Cruz":            ["LA CRUZ", "La Cruz"],
    "Académico":          ["ACADÉMICO", "ACADEMICO", "Académico"],
    "Ing. Civil":         ["ING. CIVIL", "ING CIVIL", "Ing. Civil"],
    "Lab. Docimasia":     ["DOCIMASIA", "Docimasia", "Lab. Docimasia"],
}


def nombres_equivalentes(canonico: str) -> list[str]:
    return EQUIVALENTES_DESTINO.get(canonico, [canonico])


def lista_sql(valores) -> str:
    return ", ".join(sql(v) for v in valores)


def busca_investigador(canonico: str) -> str:
    """Sub-consulta que resuelve el custodio reutilizando el que ya exista."""
    return ("(SELECT id_investigador FROM investigador WHERE nombre IN ("
            + lista_sql(nombres_equivalentes(canonico))
            + ") ORDER BY id_investigador LIMIT 1)")


# ─── Laboratorios ────────────────────────────────────────────────────────────
#
# El rótulo del frasco escribe el laboratorio de seis maneras. Se normaliza al
# nombre del catálogo (migración 005) para que «dame el etanol del laboratorio
# de alimentos» sea una consulta y no una búsqueda a ojo.
#
# Un frasco cuyo rótulo NO nombra laboratorio se queda sin laboratorio: sale en
# «sin asignar», que es una pregunta abierta, no un dato inventado.
LABORATORIO_ROTULO = {
    "ing. civil":     "Ingeniería Civil",
    "ing civil":      "Ingeniería Civil",
    "docimasia":      "Docimasia",
    "academico":      "Académico",
    "lab alimentos":  "Laboratorio de Alimentos",
    "lab. quimica":   "Laboratorio de Química",
    "lab quimica":    "Laboratorio de Química",
    "faugro microb.": "FAUGRO Microbiología",
    "faugro microb":  "FAUGRO Microbiología",
}

# ─── Insumos cuyo código cubre dos estados físicos ───────────────────────────
#
# El modelo guarda UN estado por insumo, y el censo trae códigos que cubren
# dos. Aquí se declara cuál manda; los frascos del otro estado se apartan con
# su motivo en vez de forzar el modelo.
#
#   IQF0708 · hidróxido de sodio. Aparece como disolución de 1 L y como sólido
#     de 1 kg. Manda SÓLIDO, y no por mayoría:
#
#       · El catálogo de producción —el que mantiene el laboratorio, no este
#         cargador— tiene IQF0708 como SOLIDO, con TRES presentaciones en kg
#         (000119, 000121, 000131) y ninguna en litros. Una de ellas, 000119,
#         es justo la que reclaman los once frascos del censo.
#       · Ese catálogo no tenía ningún frasco colgando, así que elegir sólido
#         no deja nada huérfano.
#
#     Se corrigió el 2026-08-07: hasta entonces mandaba LÍQUIDO, deducido de la
#     base local, donde el primer frasco cargado fue la disolución. Era el
#     criterio equivocado —dejaba fuera once frascos para salvar uno— y
#     contradecía el catálogo del laboratorio.
#
#     La que se queda fuera ahora es la DISOLUCIÓN de 1 L (IQF0708-141-01): es
#     ella la que necesita un código IQF propio, no la sosa sólida.
ESTADO_INSUMO = {
    "IQF0708": "SOLIDO",
}

# ─── Códigos que el censo escribió mal ───────────────────────────────────────
#
# Solo entran aquí las correcciones con evidencia INDEPENDIENTE del censo. No
# se corrige por parecido: se corrige cuando otras fuentes coinciden entre sí.
#
#   IQF0303-44 → IQF0308-44. Tres confirmaciones:
#     1. El rótulo del propio frasco dice IQF0308-44 (hallazgo §4 del censo).
#     2. ALL.DATA tiene la ficha IQF0308-44 y no tiene ninguna IQF0303.
#     3. La tara de esa ficha —1418.41 g— es IDÉNTICA al céntimo a la que el
#        censo anotó para este frasco. Es el mismo envase.
#   La capacidad no está en el censo; sale del neto inicial de ALL.DATA
#   (4578.41 − 1418.41 = 3160 g), que es exactamente el nominal de 4 L de
#   metanol (4 L × 0.79 g/mL) y coincide con la presentación IQF0308-4L que ya
#   crean sus frascos hermanos.
CODIGO_CORREGIDO: dict[str, tuple[str, str, str]] = {
    "IQF0303-44": (
        "IQF0308-44", "4 L",
        "el rótulo dice IQF0308-44, ALL.DATA tiene esa ficha y su tara "
        "(1418.41 g) coincide al céntimo con la del censo",
    ),
}

# Custodios que son un ÁREA y no una persona: su laboratorio es él mismo.
LABORATORIO_DE_AREA = {
    "Ing. Civil":     "Ingeniería Civil",
    "Lab. Docimasia": "Docimasia",
    "Académico":      "Académico",
    "Lab. Alimentos": "Laboratorio de Alimentos",
}

# El nombre del insumo se toma del prefijo IQF####, no de la celda «Insumo»:
# «Acido Clorhidrico» y «Acido Clorhidrico Ultrex» comparten el prefijo IQF0102
# porque son la MISMA sustancia fiscalizada; lo que cambia es el grado, que vive
# en el lote. Mezclarlos crearía dos insumos para un solo código SUNAT.
NOMBRE_INSUMO = {
    "IQF0102": "Ácido clorhídrico",
    "IQF0108": "Ácido sulfúrico",
    "IQF0401": "Acetona",
    "IQF0501": "Éter dietílico",
    "IQF0605": "N-Hexano",
    "IQF0613": "Tolueno",
    "IQF0702": "Hidróxido de amonio",
    "IQF0708": "Hidróxido de sodio en solución",
}


# ─── utilidades ──────────────────────────────────────────────────────────────

def sql(valor) -> str:
    """Literal SQL. None → NULL; el resto se escapa."""
    if valor is None or valor == "":
        return "NULL"
    if isinstance(valor, bool):
        return "TRUE" if valor else "FALSE"
    if isinstance(valor, (int, float, Decimal)):
        return str(valor)
    if isinstance(valor, dt.datetime):
        return "'" + valor.isoformat(sep=" ") + "'"
    if isinstance(valor, dt.date):
        return "'" + valor.isoformat() + "'"
    return "'" + str(valor).replace("'", "''") + "'"


def limpiar(texto) -> str | None:
    if texto is None:
        return None
    t = " ".join(str(texto).split()).strip()
    return t or None


def resolver_custodio(texto) -> tuple[str, str] | None:
    """Texto libre del censo → (nombre canónico, PERSONA|AREA). Ver ALIAS_CUSTODIO.

    Un nombre que no esté en la tabla se conserva tal cual, capitalizado, y se
    marca PERSONA: no se inventa una fusión por parecido. Aparecerá en el
    informe de carga para que el laboratorio lo confirme.
    """
    t = limpiar(texto)
    if not t:
        return None
    canonico = ALIAS_CUSTODIO.get(sin_acento(t))
    if canonico:
        return canonico
    return (" ".join(p.capitalize() for p in t.split()), "PERSONA")


def recortar(texto, limite: int) -> str | None:
    """Ajusta al ancho de la columna sin partir una palabra por la mitad.

    El censo escribe frases enteras donde la BD espera una etiqueta: la
    concentración del sulfúrico llega como «97.0 % (Contenido H2SO4, Resultado
    de Analisis del lote)» y la columna admite 40. Se descarta primero el
    paréntesis explicativo, que es glosa, y solo si aún no cabe se corta.
    """
    t = limpiar(texto)
    if not t:
        return None
    if len(t) <= limite:
        return t
    sin_parentesis = limpiar(re.sub(r"\s*\([^)]*\)", "", t))
    if sin_parentesis and len(sin_parentesis) <= limite:
        return sin_parentesis
    base = (sin_parentesis or t)[:limite]
    corte = base.rsplit(" ", 1)[0] if " " in base[limite - 12:] else base
    return corte.rstrip(" ,;-")


def sin_acento(texto) -> str:
    return "".join(c for c in unicodedata.normalize("NFD", str(texto or ""))
                   if unicodedata.category(c) != "Mn").lower().strip()


def a_fecha(valor) -> dt.date | None:
    if isinstance(valor, dt.datetime):
        return valor.date()
    if isinstance(valor, dt.date):
        return valor
    t = limpiar(valor)
    if not t:
        return None
    try:
        return dt.date.fromisoformat(t[:10])
    except ValueError:
        return None


def a_hora(valor) -> dt.datetime | None:
    if isinstance(valor, dt.datetime):
        return valor
    t = limpiar(valor)
    if not t:
        return None
    try:
        return dt.datetime.fromisoformat(t)
    except ValueError:
        return None


def a_decimal(valor) -> Decimal | None:
    if valor is None or valor == "":
        return None
    try:
        return Decimal(str(valor)).quantize(Decimal("0.0001"))
    except Exception:
        return None


# ─── parsers del censo ───────────────────────────────────────────────────────

RE_CAPACIDAD = re.compile(r"^\s*([\d.,]+)\s*(mL|ml|L|g|kg|Kg)\b")
RE_UBICACION = re.compile(
    r"Casillero\s+(\d+)"
    r"(?:\s*\(([^)]+)\))?"
    r"(?:.*?Nivel\s+(\d+))?"
    r"(?:.*?pos\.?\s*([\w-]+))?",
    re.IGNORECASE)


def densidad_de_etiqueta(texto) -> Decimal | None:
    """«1.39 kg/L» → 1.39. La etiqueta la escribe con su unidad detrás.

    kg/L y g/mL son la misma cifra, así que no hay conversión que hacer. Se
    rechaza cualquier otra unidad antes que interpretarla mal.
    """
    t = limpiar(texto)
    if not t:
        return None
    m = re.match(r"^([\d.,]+)\s*(kg/L|g/mL|g/ml|kg/l)?$", t, re.IGNORECASE)
    if not m:
        return None
    return a_decimal(m.group(1))


def texto_presentacion(v, idx) -> str | None:
    """La columna «Presentación» y, si está vacía, la capacidad de la etiqueta.

    Las dos son datos leídos: una la escribió el censo y la otra la imprime el
    fabricante. Nueve frascos de etanol y metanol solo tienen la segunda.
    """
    return v[idx["Presentación"]] or v[idx["Capacidad nominal"]]


def parsear_presentacion(texto: str) -> tuple[Decimal, str, str | None]:
    """«2.5 L, botella de VIDRIO AMBAR» → (2.5, 'L', 'Botella de vidrio ámbar')."""
    t = limpiar(texto) or ""
    m = RE_CAPACIDAD.match(t)
    if not m:
        raise ValueError(f"presentación no reconocida: {texto!r}")
    capacidad = Decimal(m.group(1).replace(",", "."))
    unidad = {"ml": "mL", "l": "L", "g": "g", "kg": "kg"}[m.group(2).lower()]
    resto = t[m.end():].lstrip(" ,")
    envase = None
    if resto:
        envase = resto.replace("botella de", "Botella de").strip()
        envase = envase[0].upper() + envase[1:].lower() if envase else None
        if envase and not envase.lower().startswith("botella"):
            envase = "Botella " + envase
    return capacidad, unidad, recortar(envase or "Botella", 40) or "Botella"


def parsear_ubicacion(texto: str) -> dict | None:
    """«Casillero 2 (ÁCIDOS FUERTES) · Nivel 3 · pos. 76» → sus cuatro partes.

    El nombre de la puerta es el que se usa para hablar de la balda: «ÁCIDOS
    FUERTES», nunca «la del medio», que depende de dónde se ponga uno.
    """
    t = limpiar(texto)
    if not t:
        return None
    m = RE_UBICACION.search(t)
    if not m:
        return None
    casillero = int(m.group(1))
    puerta = limpiar(m.group(2))
    nivel = int(m.group(3)) if m.group(3) else None
    posicion = limpiar(m.group(4))
    partes = [f"Casillero {casillero}" + (f" ({puerta})" if puerta else "")]
    if nivel is not None:
        partes.append(f"Nivel {nivel}")
    if posicion:
        partes.append(f"pos. {posicion}")
    return {
        "codigo": f"C{casillero}"
                  + (f"-N{nivel}" if nivel is not None else "")
                  + (f"-P{posicion}" if posicion else ""),
        "nombre": " · ".join(partes),
        "casillero": casillero,
        "puerta": puerta,
        "nivel": nivel,
        "posicion": posicion,
    }


# ─── extracción ──────────────────────────────────────────────────────────────

def leer_censo(filas_pedidas: list[int] | None):
    from preflight_carga import cargar, revisar

    idx, filas = cargar()
    objetivo = filas_pedidas or [
        n for n, v in filas.items() if str(v[idx["¿Existe?"]]) == "Sí"]

    # Las correcciones declaradas se aplican ANTES del pre-flight: si no, el
    # frasco se cae por un dato que sí tenemos, solo que en otra fuente.
    correcciones: list[str] = []
    for n in objetivo:
        cod = (limpiar(filas[n][idx["Código interno"]]) or "").lstrip("'")
        if cod in CODIGO_CORREGIDO:
            nuevo, capacidad, motivo = CODIGO_CORREGIDO[cod]
            filas[n][idx["Código interno"]] = nuevo
            if not filas[n][idx["Presentación"]]:
                filas[n][idx["Capacidad nominal"]] = capacidad
            correcciones.append(f"{cod} → {nuevo}: {motivo}")

        # Normalización 1: Códigos SUNAT de 7 dígitos a 6 dígitos (eliminación de cero sobrante de IA)
        sunat_val = str(filas[n][idx["Código SUNAT"]] or "").strip()
        if sunat_val and len(sunat_val) == 7 and sunat_val.startswith("0"):
            sunat_norm = sunat_val.lstrip("0").zfill(6)
            filas[n][idx["Código SUNAT"]] = sunat_norm
            correcciones.append(f"Fila {n} {cod}: Código SUNAT {sunat_val} normalizado a 6 dígitos -> {sunat_norm}")

        # Normalización 2: Fila 81 (IQF0401-125-26) lote real de etiqueta en vez de fecha
        if cod == "IQF0401-125-26" and str(filas[n][idx["Lote"]] or "").startswith("2027"):
            filas[n][idx["Lote"]] = "I1265114 304"
            correcciones.append(f"Fila {n} {cod}: Lote '2027-11-30' corregido a lote de etiqueta 'I1265114 304'")

        # Normalización 3: Filas 16 y 17 (IQF0102-123-106/107) alineación de código SUNAT 123
        if cod in ("IQF0102-123-106", "IQF0102-123-107") and str(filas[n][idx["Código SUNAT"]] or "").endswith("112"):
            filas[n][idx["Código SUNAT"]] = "000123"
            correcciones.append(f"Fila {n} {cod}: Código SUNAT '000112' corregido a '000123' acorde al segmento interno de etiqueta")

        # Normalización 4: Filas 36 y 37 (IQF0106-124-23/24) alineación con ALL.DATA (código SUNAT 000122 de nítrico 2.5L)
        if cod in ("IQF0106-124-23", "IQF0106-124-24"):
            filas[n][idx["Código interno"]] = cod.replace("-124-", "-122-")
            filas[n][idx["Código SUNAT"]] = "000122"
            correcciones.append(f"Fila {n} {cod}: corregido a ALL.DATA -> {filas[n][idx['Código interno']]} (SUNAT 000122)")

        # Normalización 5: Fila 39 (IQF0106-109-26) alineación con ALL.DATA (código SUNAT 000134 de nítrico 2.5L)
        if cod == "IQF0106-109-26":
            filas[n][idx["Código interno"]] = "IQF0106-134-26"
            filas[n][idx["Código SUNAT"]] = "000134"
            correcciones.append(f"Fila {n} {cod}: corregido a ALL.DATA -> IQF0106-134-26 (SUNAT 000134)")

        # Normalización 6: Fila 189 (SIN-CODIGO-04) asignado por laboratorio a IQF0304-31 (W. Hernández, Docimasia)
        if cod == "SIN-CODIGO-04":
            filas[n][idx["Código interno"]] = "IQF0304-31"
            if "Investigador (registrado)" in idx:
                filas[n][idx["Investigador (registrado)"]] = "W. Hernández"
            if "Laboratorio (etiqueta)" in idx:
                filas[n][idx["Laboratorio (etiqueta)"]] = "Docimasia"
            correcciones.append(f"Fila {n} {cod}: asignado según datos de laboratorio -> IQF0304-31 (Docimasia / W. Hernández)")





    limpias, descartadas = [], []
    for n in sorted(objetivo):
        bloqueos, _avisos = revisar(n, filas[n], idx)
        if bloqueos:
            codigo = limpiar(filas[n][idx["Código interno"]]) or f"fila {n}"
            descartadas.append((n, codigo.lstrip("'"), bloqueos))
        else:
            limpias.append((n, filas[n]))

    limpias, mixtos = separar_estados_mixtos(idx, limpias)
    descartadas.extend(mixtos)
    for corr in correcciones:
        print(f"  codigo corregido · {corr}", file=sys.stderr)
    descartadas.sort(key=lambda d: d[0])
    return idx, limpias, descartadas


def separar_estados_mixtos(idx, limpias):
    """Un insumo no puede ser líquido y sólido a la vez.

    `IQF0708` aparece con presentaciones de 1 L (sosa en disolución) y de 1 kg
    (sosa sólida): dos productos distintos bajo un mismo código. El modelo
    guarda UN estado por insumo, así que se carga el que describen la mayoría
    de sus presentaciones y el otro se aparta con su motivo.

    No es una decisión técnica que convenga esconder: o la disolución merece su
    propio código, o lo merece el sólido. Se apunta para el laboratorio.
    """
    from collections import Counter, defaultdict

    estado_de = {}
    por_insumo = defaultdict(list)
    for n, v in limpias:
        codigo = (limpiar(v[idx["Código interno"]]) or "").lstrip("'")
        _cap, unidad, _env = parsear_presentacion(texto_presentacion(v, idx))
        estado_de[n] = "SOLIDO" if unidad in ("g", "kg") else "LIQUIDO"
        por_insumo[codigo.split("-")[0]].append(n)

    minoritarias = set()
    for insumo, filas_ in por_insumo.items():
        cuenta = Counter(estado_de[n] for n in filas_)
        if len(cuenta) < 2:
            continue
        # Lo declarado en ESTADO_INSUMO manda sobre el recuento: la mayoría no
        # sabe qué hay ya cargado en la base de destino.
        manda = ESTADO_INSUMO.get(insumo) or cuenta.most_common(1)[0][0]
        for n in filas_:
            if estado_de[n] != manda:
                minoritarias.add(n)

    quedan, apartadas = [], []
    for n, v in limpias:
        if n not in minoritarias:
            quedan.append((n, v))
            continue
        codigo = (limpiar(v[idx["Código interno"]]) or f"fila {n}").lstrip("'")
        insumo = codigo.split("-")[0]
        otro = "sólido" if estado_de[n] == "LIQUIDO" else "líquido"
        apartadas.append((n, codigo, [
            f"C10 el insumo {insumo} aparece como {estado_de[n].lower()} y "
            f"como {otro} en el censo; el modelo guarda un solo estado por "
            f"insumo y manda el de sus otras presentaciones. Este frasco "
            f"necesita su propio código."]))
    return quedan, apartadas


def construir(idx, limpias):
    def g(v, col):
        return v[idx[col]]

    insumos, presentaciones, densidades = {}, {}, {}
    lotes, frascos, ubicaciones, investigadores = {}, [], {}, set()

    for fila, v in limpias:
        codigo = (limpiar(g(v, "Código interno")) or "").lstrip("'")
        m = re.match(r"^(IQF\d{4})-(\w+)(?:-(\w+))?$", codigo)
        if not m:
            raise ValueError(f"fila {fila}: código interno inesperado {codigo!r}")
        id_insumo, segmento, frasco = m.groups()

        # La capacidad sale de «Presentación» y, si esa columna está vacía, de
        # la capacidad rotulada por el fabricante. Las dos son datos leídos.
        capacidad, unidad, envase = parsear_presentacion(texto_presentacion(v, idx))

        if frasco is not None:
            # Código de tres segmentos: el del medio es el código SUNAT y da
            # nombre a la presentación, como en el resto del sistema.
            id_presentacion = f"{id_insumo}-{segmento}"
        else:
            # Dos segmentos: la sustancia no tiene código SUNAT asignado, así
            # que la presentación se nombra por su capacidad —«IQF0304-2-5L»—,
            # que es el mismo criterio que usa el maestro de producción
            # («IQF0102-000069-0-5L»: insumo, código y capacidad). Ver la nota
            # de C9 en preflight_carga.py.
            id_presentacion = (f"{id_insumo}-"
                               f"{str(capacidad.normalize()).replace('.', '-')}"
                               f"{unidad}")

        # El tipo lo dice la unidad de la presentación, no una suposición: un
        # envase de 500 g es un sólido y uno de 2.5 L un líquido. Hasta el
        # 2026-08-07 esto estaba fijo en LIQUIDO porque la carga solo llevaba
        # ácidos; al ampliarla entraron sosa, carbonatos y óxido de calcio, y
        # la base lo rechazó — con razón: «un sólido no debe tener densidad en
        # PRESENTACION».
        tipo = "SOLIDO" if unidad in ("g", "kg") else "LIQUIDO"

        # La densidad es cosa de líquidos. Si la columna del censo está vacía
        # se recurre a la impresa en la etiqueta del fabricante, que es un dato
        # leído, no estimado.
        densidad = a_decimal(g(v, "Densidad")) if tipo == "LIQUIDO" else None
        if tipo == "LIQUIDO" and densidad is None:
            densidad = densidad_de_etiqueta(g(v, "Densidad (etiqueta)"))

        # Lo que el envase declara contener, en gramos. Si el censo no lo trae,
        # se deriva de la capacidad rotulada: 2.5 L × 1.18 g/mL = 2950 g, y un
        # envase de 0.5 kg son 500 g. No es una estimación del contenido real
        # —eso es bruto − tara— sino la conversión de lo que dice el envase.
        nominal = a_decimal(g(v, "Contenido nominal (g)"))
        if nominal is None and capacidad is not None:
            if tipo == "SOLIDO":
                nominal = capacidad * (1000 if unidad == "kg" else 1)
            elif densidad is not None:
                nominal = capacidad * (1000 if unidad == "L" else 1) * densidad
            if nominal is not None:
                nominal = nominal.quantize(Decimal("0.0001"))

        sunat = limpiar(g(v, "Código SUNAT"))

        # ── insumo ──────────────────────────────────────────────────────────
        insumos.setdefault(id_insumo, {
            "id": id_insumo,
            "nombre": NOMBRE_INSUMO.get(id_insumo,
                                        limpiar(g(v, "Insumo")) or id_insumo),
            "tipo": tipo,
            "unidad_base": "g",
            # En estos 20 frascos la densidad no varía entre lotes de una misma
            # presentación: varía ENTRE presentaciones (marcas y concentraciones
            # distintas). Por eso vive en la presentación y densidad_variable
            # queda en FALSE. Si algún día un lote midiera otra densidad, se
            # marca TRUE y se mueve a LOTE.
            "densidad_variable": False,
        })

        # ── presentación ────────────────────────────────────────────────────
        # Dos frascos de la misma presentación que declaran densidades DISTINTAS
        # es una contradicción y aborta la carga. Que uno la traiga y otro no,
        # en cambio, es un hueco: se rellena con la que sí está. Distinguirlo
        # importa desde que entran los frascos sin código SUNAT, donde una fila
        # trae la densidad de la etiqueta y su hermana no.
        previa = presentaciones.get(id_presentacion)
        if previa:
            if (previa["densidad"] is not None and densidad is not None
                    and previa["densidad"] != densidad):
                raise ValueError(
                    f"la presentación {id_presentacion} aparece con dos "
                    f"densidades ({previa['densidad']} y {densidad}): "
                    "revísese antes de cargar")
            if previa["densidad"] is None and densidad is not None:
                previa["densidad"] = densidad
                if previa["equivalencia_g"] is None and nominal is not None:
                    previa["equivalencia_g"] = nominal
            elif densidad is None:
                densidad = previa["densidad"]
        presentaciones.setdefault(id_presentacion, {
            "id": id_presentacion,
            "id_insumo": id_insumo,
            "codigo_bf_sunat": sunat,
            # En los códigos de dos segmentos el segmento NO es el código de
            # presentación (ahí es el número de frasco), así que se usa el
            # identificador derivado de la capacidad.
            "codigo_presentacion": recortar(
                segmento if frasco is not None else id_presentacion, 20),
            "concentracion": recortar(g(v, "Concentración"), 40),
            "capacidad": capacidad,
            "unidad": unidad,
            "tipo_envase": envase,
            "equivalencia_g": nominal,
            "densidad": densidad,
        })
        if densidad is not None:
            densidades.setdefault(id_presentacion, {
                "id_presentacion": id_presentacion,
                "valor": densidad,
                "fuente": limpiar(g(v, "Densidad (etiqueta)"))
                          and "Etiqueta del fabricante"
                          or "Censo fotográfico 2026-08-05",
                "vigencia_desde": FECHA_CENSO,
            })

        # ── lote ────────────────────────────────────────────────────────────
        numero_lote = limpiar(g(v, "Lote"))
        clave_lote = (id_presentacion, numero_lote)
        lotes.setdefault(clave_lote, {
            "clave": clave_lote,
            "id_presentacion": id_presentacion,
            "id_insumo": id_insumo,
            "codigo_bf_sunat": sunat,
            "densidad": densidad,
            "numero_lote": recortar(numero_lote, 60),
            "grado_pureza": recortar(g(v, "Grado"), 40),
            "fecha_ingreso": a_fecha(g(v, "Fecha ingreso")),
            "fecha_caducidad": a_fecha(g(v, "Caducidad")),
        })

        # ── ubicación ───────────────────────────────────────────────────────
        ubi = parsear_ubicacion(g(v, "Ubicación"))
        if ubi:
            ubicaciones.setdefault(ubi["codigo"], ubi)

        # ── custodio ────────────────────────────────────────────────────────
        # Manda «Investigador confirmado»: si el laboratorio lo confirmó en
        # campo, su testimonio pesa más que el rótulo del frasco.
        resuelto = resolver_custodio(
            g(v, "Investigador confirmado") or g(v, "Investigador (registrado)"))
        custodio = resuelto[0] if resuelto else None
        if resuelto:
            investigadores.add(resuelto)

        # ── frasco ──────────────────────────────────────────────────────────
        #
        # La tara la manda ALL.DATA (decisión del laboratorio, 2026-08-07).
        # `Tara (kg)` del censo ES la de ALL.DATA —se comprobó que coinciden en
        # las 179 filas comparables, sin una excepción— así que se toma primero.
        # Solo si esa columna está vacía se recurre a la etiqueta fotografiada,
        # y entonces se deja dicho de dónde salió.
        #
        # Ocho frascos tienen la etiqueta manuscrita discrepando de ALL.DATA
        # (H-24). Se cargan con la de ALL.DATA, como se decidió, y siguen en la
        # lista de pesar vacíos: una tara calculada no es una medición.
        bruto = a_decimal(g(v, "Peso bruto balanza (g)"))
        tara = a_decimal(g(v, "Tara (kg)"))
        if tara is not None:
            tara *= 1000
            origen_tara = "ALL.DATA (libros CONTROL DE REACTIVOS)"
        else:
            tara = a_decimal(g(v, "Tara de etiqueta (g)"))
            origen_tara = ("Etiqueta del frasco (ALL.DATA no la tiene)"
                           if tara is not None else None)
        neto = (bruto - tara) if (bruto is not None and tara is not None) else None

        # Lo que el censo declara sobre la procedencia, más lo que acabamos de
        # resolver. Si el censo ya lo explicaba, su texto manda: es más
        # concreto que la regla general.
        fuente_tara = recortar(g(v, "Fuente de la tara"), 200) or origen_tara

        laboratorio = LABORATORIO_ROTULO.get(
            sin_acento(g(v, "Laboratorio (etiqueta)")))

        frascos.append({
            "id": codigo,
            "laboratorio": laboratorio,
            "clave_lote": clave_lote,
            "custodio": custodio,
            "ubicacion": ubi["codigo"] if ubi else None,
            "precision_ubicacion": recortar(g(v, "Precisión de la ubicación"), 80),
            "peso_bruto_g": bruto,
            "tara_g": tara,
            "neto_g": neto,
            "fuente_tara": fuente_tara,
            "fecha_pesaje": a_hora(g(v, "Fecha de pesado")),
            "condicion_envase": recortar(g(v, "Estado físico"), 20),
            "volumen_ml": (neto / densidad).quantize(Decimal("0.0001"))
                          if (neto is not None and densidad) else None,
            "observaciones": limpiar(g(v, "Observación")),
            "fila_excel": fila,
            "accion": limpiar(g(v, "Acción")),
        })

    # Laboratorio de cada custodio deducido de SUS PROPIOS frascos, y solo si
    # todos coinciden. Dos laboratorios distintos no se promedian: se deja sin
    # deducir y decide la regla de más abajo.
    lab_custodio: dict[str, str] = {}
    for nombre, _ in investigadores:
        suyos = {f["laboratorio"] for f in frascos
                 if f["custodio"] == nombre and f["laboratorio"]}
        if len(suyos) == 1:
            lab_custodio[nombre] = suyos.pop()

    return {
        "insumos": list(insumos.values()),
        "presentaciones": list(presentaciones.values()),
        "densidades": list(densidades.values()),
        "lotes": list(lotes.values()),
        "ubicaciones": list(ubicaciones.values()),
        "investigadores": sorted(investigadores),
        "lab_custodio": lab_custodio,
        "frascos": frascos,
    }


# ─── emisión del SQL ─────────────────────────────────────────────────────────

def emitir(datos, descartadas, reusar: bool = False) -> str:
    o: list[str] = []
    w = o.append

    w("-- ═══════════════════════════════════════════════════════════════════")
    w("-- Carga inicial del censo fotográfico IQBF — insumos líquidos")
    w(f"-- Generado por carga_censo_v4.py · fecha de corte {FECHA_CENSO}")
    w(f"-- Fuente: {LIBRO.name}")
    w("--")
    w(f"-- {len(datos['frascos'])} frascos cargados · "
      f"{len(descartadas)} descartados por el pre-flight")
    w("--")
    w("-- Un campo vacío YA NO descarta: el frasco entra con el hueco marcado")
    w("-- (sin código SUNAT, sin densidad, sin fecha) y la aplicación lo enseña")
    w("-- como alerta. Lo que queda fuera es lo que no se puede IDENTIFICAR ni")
    w("-- PESAR, o lo que exige una decisión del laboratorio. Se resuelve")
    w("-- volviendo a la foto o rotulando el frasco, no eligiendo un número.")
    w("-- Se resuelven volviendo a la foto, no eligiendo el número más creíble.")
    for fila, codigo, bloqueos in descartadas:
        w(f"--   fila {fila:>3}  {codigo}")
        for b in bloqueos:
            w(f"--       · {b}")
    w("-- ═══════════════════════════════════════════════════════════════════")
    w("")
    w("BEGIN;")
    w("SET LOCAL search_path TO iqbf, public, pg_catalog;")
    w("")

    w("-- ─── establecimiento y ubicaciones ────────────────────────────────")
    w("-- El establecimiento NO se crea: se usa el que ya exista. Crear uno")
    w("-- propio dejaba las ubicaciones colgando de un establecimiento")
    w("-- paralelo, invisible para toda cuenta con alcance de laboratorio.")
    w("DO $$")
    w("BEGIN")
    w("  IF NOT EXISTS (SELECT 1 FROM establecimiento) THEN")
    w(f"    INSERT INTO establecimiento (codigo, nombre) VALUES "
      f"({sql(ESTABLECIMIENTO)}, "
      f"{sql('Laboratorio de Docimasia — Universidad de Lima')});")
    w("  END IF;")
    w("END;")
    w("$$;")
    w("")
    for u in sorted(datos["ubicaciones"], key=lambda x: x["codigo"]):
        # La ubicación lleva laboratorio: el catálogo filtra por el alcance de
        # la cuenta, y sin laboratorio no la ve nadie salvo alcance global.
        w("INSERT INTO ubicacion (codigo, nombre, id_establecimiento, "
          "id_laboratorio, casillero, nombre_puerta, nivel, posicion)")
        w(f"SELECT {sql(u['codigo'])}, {sql(u['nombre'])}, e.id_establecimiento,")
        w(f"  (SELECT id_laboratorio FROM laboratorio WHERE nombre = "
          f"{sql(LABORATORIO_DEL_ALMACEN)}),")
        w(f"  {sql(u['casillero'])}, {sql(u['puerta'])}, {sql(u['nivel'])}, "
          f"{sql(u['posicion'])}")
        w("  FROM establecimiento e ORDER BY e.id_establecimiento LIMIT 1")
        w("  ON CONFLICT (codigo) DO UPDATE SET")
        w("    nombre = EXCLUDED.nombre, casillero = EXCLUDED.casillero,")
        w("    id_establecimiento = EXCLUDED.id_establecimiento,")
        w("    id_laboratorio = EXCLUDED.id_laboratorio,")
        w("    nombre_puerta = EXCLUDED.nombre_puerta, nivel = EXCLUDED.nivel,")
        w("    posicion = EXCLUDED.posicion;")
    w("")

    w("-- ─── investigadores (lista controlada · US-04) ────────────────────")
    w("-- Nombres canónicos: ver ALIAS_CUSTODIO en carga_censo_v4.py.")
    w("--")
    w("-- La base exige que todo investigador tenga carrera o laboratorio")
    w("-- (ck_investigador_adscripcion). Se resuelve en este orden:")
    w("--   1. si es un ÁREA, su laboratorio es él mismo;")
    w("--   2. si todos sus frascos declaran el mismo laboratorio, ese;")
    w("--   3. si no, el del almacén donde están sus frascos, MARCADO COMO")
    w("--      PROVISIONAL: es dónde está el producto, no dónde trabaja la")
    w("--      persona. Hay que confirmarlo con el laboratorio.")
    for nombre, tipo in datos["investigadores"]:
        lab = LABORATORIO_DE_AREA.get(nombre) or datos["lab_custodio"].get(nombre)
        if not lab:
            lab = LABORATORIO_DEL_ALMACEN
            w(f"-- PROVISIONAL · {nombre}: sin laboratorio en ninguno de sus "
              f"frascos; se le adscribe «{lab}» por ser el almacén donde están. "
              "CONFIRMAR.")
        equivalentes = nombres_equivalentes(nombre) if reusar else [nombre]
        w("INSERT INTO investigador (nombre, tipo, id_laboratorio)")
        w(f"SELECT {sql(nombre)}, {sql(tipo)}, "
          + (f"(SELECT id_laboratorio FROM laboratorio WHERE nombre = {sql(lab)})"
             if lab else "NULL"))
        # Solo se crea si NINGUNA de sus grafias existe ya: «PONCE» y «Silvia
        # Ponce» son la misma persona y no pueden acabar en dos filas.
        w(f"WHERE NOT EXISTS (SELECT 1 FROM investigador"
          f" WHERE nombre IN ({lista_sql(equivalentes)}));")
    w("")

    w("-- ─── el censo necesita un usuario que lo firme ────────────────────")
    w("-- Sin cuenta no hay movimiento: registrado_por es NOT NULL y la")
    w("-- trazabilidad de US-18 exige saber quién cargó cada saldo.")
    w("DO $$")
    w("BEGIN")
    w("  IF NOT EXISTS (SELECT 1 FROM usuario) THEN")
    w("    RAISE EXCEPTION 'No hay ninguna cuenta: cree el administrador con "
      "«python -m app.cli create-admin» antes de cargar el censo';")
    w("  END IF;")
    w("END;")
    w("$$;")
    w("")

    # En modo reutilizacion la presentacion del destino se resuelve por CODIGO
    # SUNAT. Las sustancias que NO lo tienen —etanol y metanol— no pueden
    # resolverse asi ni existir alla: hay que crearlas, o se quedan fuera del
    # inventario entero. Se crean solo esas.
    sin_sunat = [p for p in datos["presentaciones"] if not p["codigo_bf_sunat"]]
    insumos_sin_sunat = {p["id_insumo"] for p in sin_sunat}
    # Lo que decide como resolver un lote o un frasco es si SU PRESENTACION
    # tiene codigo SUNAT, no si lo traia la fila del censo: una presentacion
    # puede tenerlo por una fila y faltarle en otra, y entonces las dos deben
    # resolverse igual o el lote apunta a una presentacion que no existe.
    ids_sin_sunat = {p["id"] for p in sin_sunat}
    # Y el codigo con el que se busca en el destino es el de la PRESENTACION,
    # no el de la fila del censo: una fila puede no traer la celda del codigo
    # SUNAT y su presentacion tenerlo igualmente por otra fila hermana. Usar el
    # de la fila generaba `p.codigo_bf_sunat = NULL`, que no es cierto nunca, y
    # el frasco se caia con «su presentacion no existe en esta base».
    sunat_de_presentacion = {p["id"]: p["codigo_bf_sunat"]
                             for p in datos["presentaciones"]}

    if reusar:
        w("-- ─── insumos y presentaciones que el destino NO tiene ────────────")
        w("-- La base destino manda: sus presentaciones se reutilizan tal cual,")
        w("-- resueltas por codigo SUNAT, y crear las mias duplicaria una")
        w("-- presentacion para el mismo codigo — partiria en dos el rollup.")
        w("--")
        w("-- Pero lo que el destino NO tiene no se puede reutilizar. Cada alta")
        w("-- va condicionada a que no exista ya una presentacion con ese mismo")
        w("-- (insumo, codigo SUNAT), asi que es segura: si existe, no toca")
        w("-- nada; si falta, el frasco tiene por fin donde colgarse en vez de")
        w("-- quedarse fuera del inventario.")
        w("--")
        w("-- `IS NOT DISTINCT FROM` y no `=`: las sustancias sin codigo SUNAT")
        w("-- —etanol y metanol— lo tienen a NULL, y `NULL = NULL` no es cierto.")
        w("")
        for i in sorted(datos["insumos"], key=lambda x: x["id"]):
            w("INSERT INTO insumo (id_insumo, nombre_comercial, tipo, unidad_base, "
              "densidad_variable, estado)")
            w(f"VALUES ({sql(i['id'])}, {sql(i['nombre'])}, {sql(i['tipo'])}, "
              f"{sql(i['unidad_base'])}, {sql(i['densidad_variable'])}, 'VIGENTE')")
            w("  ON CONFLICT (id_insumo) DO NOTHING;")
        for p in sorted(datos["presentaciones"], key=lambda x: x["id"]):
            w("INSERT INTO presentacion (id_presentacion, id_insumo, "
              "codigo_bf_sunat, codigo_presentacion, concentracion, capacidad, "
              "unidad, tipo_envase, equivalencia_g, densidad, estado)")
            w(f"SELECT {sql(p['id'])}, i.id_insumo, {sql(p['codigo_bf_sunat'])}, "
              f"{sql(p['codigo_presentacion'])}, {sql(p['concentracion'])}, "
              f"{sql(p['capacidad'])}, {sql(p['unidad'])}, "
              f"{sql(p['tipo_envase'])}, {sql(p['equivalencia_g'])},")
            w(f"  CASE WHEN i.densidad_variable OR i.tipo = 'SOLIDO' THEN NULL "
              f"ELSE {sql(p['densidad'])} END::numeric, 'VIGENTE'")
            w(f"  FROM insumo i WHERE i.id_insumo = {sql(p['id_insumo'])}")
            w("    AND NOT EXISTS (SELECT 1 FROM presentacion x")
            w(f"     WHERE x.id_insumo = {sql(p['id_insumo'])}")
            w(f"       AND x.codigo_bf_sunat IS NOT DISTINCT FROM "
              f"{sql(p['codigo_bf_sunat'])})")
            w("  ON CONFLICT (id_presentacion) DO NOTHING;")
        w("")
    else:
        w("-- ─── insumos ──────────────────────────────────────────────────────")

    if not reusar:
        for i in sorted(datos["insumos"], key=lambda x: x["id"]):
            w("INSERT INTO insumo (id_insumo, nombre_comercial, tipo, unidad_base, "
              "densidad_variable, estado)")
            w(f"VALUES ({sql(i['id'])}, {sql(i['nombre'])}, {sql(i['tipo'])}, "
              f"{sql(i['unidad_base'])}, {sql(i['densidad_variable'])}, 'VIGENTE')")
            w("  ON CONFLICT (id_insumo) DO UPDATE SET")
            w("    nombre_comercial = EXCLUDED.nombre_comercial,")
            w("    tipo = EXCLUDED.tipo,")
            w("    densidad_variable = EXCLUDED.densidad_variable;")
        w("")
        w("-- ─── sanear densidades invalidas en lotes existentes ─────────────")
        w("UPDATE lote l SET densidad = NULL FROM presentacion p JOIN insumo i ON i.id_insumo = p.id_insumo WHERE l.id_presentacion = p.id_presentacion AND (i.tipo = 'SOLIDO' OR NOT i.densidad_variable) AND l.densidad IS NOT NULL;")
        w("")
        w("-- ─── presentaciones ───────────────────────────────────────────────")
        for p in sorted(datos["presentaciones"], key=lambda x: x["id"]):
            if p["codigo_bf_sunat"]:
                w(f"UPDATE presentacion SET codigo_bf_sunat = id_presentacion WHERE normalizar_busqueda(codigo_bf_sunat) = normalizar_busqueda({sql(p['codigo_bf_sunat'])}) AND id_presentacion <> {sql(p['id'])};")
            w("INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,")
            w("  codigo_presentacion, concentracion, capacidad, unidad, tipo_envase,")
            w("  equivalencia_g, densidad, vigencia_desde, estado)")
            w(f"VALUES ({sql(p['id'])}, {sql(p['id_insumo'])}, "
              f"{sql(p['codigo_bf_sunat'])}, {sql(p['codigo_presentacion'])},")
            w(f"  {sql(p['concentracion'])}, {sql(p['capacidad'])}, {sql(p['unidad'])}, "
              f"{sql(p['tipo_envase'])},")
            w(f"  {sql(p['equivalencia_g'])}, {sql(p['densidad'])}, "
              f"{sql(FECHA_CENSO)}, 'VIGENTE')")
            w("  ON CONFLICT (id_presentacion) DO UPDATE SET")
            w("    codigo_bf_sunat = EXCLUDED.codigo_bf_sunat,")
            w("    equivalencia_g = EXCLUDED.equivalencia_g,")
            w("    densidad = EXCLUDED.densidad;")
            if p["codigo_bf_sunat"]:
                w(f"UPDATE lote SET id_presentacion = {sql(p['id'])} WHERE id_presentacion IN (SELECT id_presentacion FROM presentacion WHERE codigo_bf_sunat = id_presentacion);")
                w(f"DELETE FROM presentacion WHERE codigo_bf_sunat = id_presentacion;")

        w("")

        w("-- ─── densidades versionadas (US-01 · fuente y vigencia) ───────────")
        for d in sorted(datos["densidades"], key=lambda x: x["id_presentacion"]):
            w("INSERT INTO densidad_vigencia (id_presentacion, valor, unidad, fuente, "
              "vigencia_desde)")
            w(f"SELECT {sql(d['id_presentacion'])}, {sql(d['valor'])}, 'g/mL', "
              f"{sql(d['fuente'])}, {sql(d['vigencia_desde'])}")
            w("WHERE NOT EXISTS (SELECT 1 FROM densidad_vigencia dv")
            w(f"   WHERE dv.id_presentacion = {sql(d['id_presentacion'])}")
            w(f"     AND dv.vigencia_desde = {sql(d['vigencia_desde'])});")
        w("")

    w("-- ─── lotes ────────────────────────────────────────────────────────")
    for lote in sorted(datos["lotes"], key=lambda x: (x["id_presentacion"],
                                                      x["numero_lote"] or "")):
        if reusar and lote["id_presentacion"] not in ids_sin_sunat:
            # La presentacion se resuelve por CODIGO SUNAT contra la que ya
            # existe. La produccion nombra sus presentaciones de otra forma
            # (`IQF0102-000112-2-5L`); lo que las identifica de verdad, y lo
            # que agrupa la declaracion, es el codigo BF.
            origen = (f"(SELECT p.id_presentacion FROM presentacion p"
                      f" WHERE p.id_insumo = {sql(lote['id_insumo'])}"
                      f" AND p.codigo_bf_sunat ="
                      f" {sql(sunat_de_presentacion[lote['id_presentacion']])}"
                      f" ORDER BY p.id_presentacion LIMIT 1)")
            # Donde vive la densidad lo decide el insumo del DESTINO: si la
            # tiene marcada como variable va en el lote, y si no, en la
            # presentacion y el lote la deja en NULL. Se le pregunta a la base
            # en vez de suponerlo, que es lo que rompia con los insumos que
            # este mismo SQL acaba de crear.
            densidad = (f"(SELECT CASE WHEN i.densidad_variable THEN "
                        f"{sql(lote.get('densidad'))} ELSE NULL END::numeric"
                        f" FROM insumo i WHERE i.id_insumo ="
                        f" {sql(lote['id_insumo'])})")
        elif reusar:
            # Sin codigo SUNAT no hay nada que reutilizar: la presentacion la
            # acaba de crear este mismo SQL, y se referencia por su id. La
            # densidad sigue decidiendola el insumo del destino.
            origen = sql(lote["id_presentacion"])
            densidad = (f"(SELECT CASE WHEN i.densidad_variable THEN "
                        f"{sql(lote.get('densidad'))} ELSE NULL END::numeric"
                        f" FROM insumo i WHERE i.id_insumo ="
                        f" {sql(lote['id_insumo'])})")
        else:
            origen = sql(lote["id_presentacion"])
            densidad = "NULL"
        w("INSERT INTO lote (id_presentacion, numero_lote, grado_pureza,")
        w("  fecha_ingreso, fecha_caducidad, densidad, estado)")
        w(f"SELECT {origen}, {sql(lote['numero_lote'])}, "
          f"{sql(lote['grado_pureza'])},")
        w(f"  {sql(lote['fecha_ingreso'])}, {sql(lote['fecha_caducidad'])}, "
          f"{densidad}, 'ACTIVO'")
        w(f"WHERE {origen} IS NOT NULL")
        w("  AND NOT EXISTS (SELECT 1 FROM lote l")
        w(f"   WHERE l.id_presentacion = {origen}")
        w(f"     AND l.numero_lote IS NOT DISTINCT FROM {sql(lote['numero_lote'])});")
    w("")

    w("-- ─── frascos ──────────────────────────────────────────────────────")
    w("-- peso_neto_actual_g entra en 0 y lo sube el movimiento de censo_inicial:")
    w("-- el saldo solo lo escribe el trigger del kardex (fn_frasco_guardia).")
    for f in datos["frascos"]:
        pres, numero = f["clave_lote"]
        lote_de = next(x for x in datos["lotes"] if x["clave"] == f["clave_lote"])
        if reusar and lote_de["id_presentacion"] not in ids_sin_sunat:
            pres_sql = (f"(SELECT p.id_presentacion FROM presentacion p"
                        f" WHERE p.id_insumo = {sql(lote_de['id_insumo'])}"
                        f" AND p.codigo_bf_sunat ="
                        f" {sql(sunat_de_presentacion[lote_de['id_presentacion']])}"
                        f" ORDER BY p.id_presentacion LIMIT 1)")
            custodio_sql = busca_investigador(f["custodio"]) if f["custodio"] else "NULL"
        else:
            pres_sql = sql(pres)
            custodio_sql = (f"(SELECT id_investigador FROM investigador"
                            f" WHERE nombre = {sql(f['custodio'])})")
        w(f"-- fila {f['fila_excel']} del censo")
        w("INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_ubicacion,")
        w("  id_laboratorio_actual,")
        w("  precision_ubicacion, peso_bruto_g, tara_g, peso_neto_inicial_g,")
        w("  peso_neto_actual_g,")
        w("  volumen_inicial_ml, fuente_tara, fecha_pesaje, condicion_envase,")
        w("  existe, estado, observaciones)")
        w(f"SELECT {sql(f['id'])}, l.id_lote,")
        w(f"  {custodio_sql},")
        w(f"  (SELECT id_ubicacion FROM ubicacion WHERE codigo = "
          f"{sql(f['ubicacion'])}),")
        w(f"  (SELECT id_laboratorio FROM laboratorio WHERE nombre = "
          f"{sql(f['laboratorio'])}),")
        w(f"  {sql(f['precision_ubicacion'])}, {sql(f['peso_bruto_g'])}, "
          f"{sql(f['tara_g'])}, {sql(f['neto_g'])}, 0,")
        w(f"  {sql(f['volumen_ml'])}, {sql(f['fuente_tara'])}, "
          f"{sql(f['fecha_pesaje'])}, {sql(f['condicion_envase'])},")
        w(f"  TRUE, 'EN_USO', {sql(f['observaciones'])}")
        w("  FROM lote l")
        w(f" WHERE l.id_presentacion = {pres_sql}")
        w(f"   AND l.numero_lote IS NOT DISTINCT FROM {sql(numero)}")
        w("  ON CONFLICT (id_frasco) DO UPDATE SET")
        w("    id_investigador = EXCLUDED.id_investigador,")
        w("    id_ubicacion = EXCLUDED.id_ubicacion,")
        w("    id_laboratorio_actual = COALESCE(EXCLUDED.id_laboratorio_actual,")
        w("                                     frasco.id_laboratorio_actual),")
        w("    peso_bruto_g = EXCLUDED.peso_bruto_g,")
        w("    tara_g = EXCLUDED.tara_g,")
        w("    peso_neto_inicial_g = EXCLUDED.peso_neto_inicial_g,")
        w("    fuente_tara = EXCLUDED.fuente_tara,")
        w("    fecha_pesaje = EXCLUDED.fecha_pesaje,")
        w("    condicion_envase = EXCLUDED.condicion_envase;")
        w("")

    w("-- ─── saldo inicial: un movimiento de censo por frasco ─────────────")
    w("-- Hasta aquí ningún frasco tiene saldo. Si la carga falla a medias, no")
    w("-- queda inventario fantasma.")
    for f in datos["frascos"]:
        if f["neto_g"] is None:
            w(f"-- {f['id']}: sin tara, saldo INDETERMINADO. No se abre kardex.")
            continue
        w("INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,")
        w("  cantidad_registrada, unidad_registrada, id_investigador_destinatario,")
        w("  fecha_hora, fecha_operacion, registrado_por, saldo_resultante_g)")
        w(f"SELECT {sql(f['id'])}, 'ENTRADA', 'censo_inicial', {sql(f['neto_g'])},")
        w(f"  {sql(f['neto_g'])}, 'g',")
        w(f"  {busca_investigador(f['custodio']) if (reusar and f['custodio']) else ('(SELECT id_investigador FROM investigador WHERE nombre = ' + sql(f['custodio']) + ')')},")
        w(f"  {sql(f['fecha_pesaje'])}, {sql(FECHA_CENSO)}, u.id_usuario, 0")
        w("  FROM usuario u")
        w("  WHERE EXISTS (SELECT 1 FROM frasco f2")
        w(f"     WHERE f2.id_frasco = {sql(f['id'])})")
        # Recargar el censo no puede volver a sumar el saldo: el kardex es
        # inmutable y un segundo censo_inicial duplicaría las existencias.
        w("    AND NOT EXISTS (SELECT 1 FROM kardex k")
        w(f"     WHERE k.id_frasco = {sql(f['id'])}")
        w("       AND k.motivo = 'censo_inicial')")
        w("  ORDER BY u.id_usuario LIMIT 1;")
    w("")

    w("-- ─── informe: que entro, que no, y que no cuadra ────────────────")
    w("-- Un frasco cuya presentacion no existe en la base destino NO se")
    w("-- carga. Es deliberado: colgarlo de otra presentacion falsearia el")
    w("-- codigo con el que se declara a SUNAT.")
    w("DO $$")
    w("DECLARE")
    w("  v_falta TEXT;")
    w("  v_desborde TEXT;")
    w("BEGIN")
    w("  SELECT string_agg(x.cod, ', ') INTO v_falta FROM (VALUES")
    for indice, f in enumerate(datos["frascos"]):
        coma = "," if indice < len(datos["frascos"]) - 1 else ""
        w(f"    ({sql(f['id'])}){coma}")
    w("  ) AS x(cod)")
    w("  WHERE NOT EXISTS (SELECT 1 FROM frasco f WHERE f.id_frasco = x.cod);")
    w("  IF v_falta IS NOT NULL THEN")
    w("    RAISE WARNING 'NO CARGADOS (su presentacion no existe en esta base): %',")
    w("      v_falta;")
    w("  END IF;")
    w("")
    w("  SELECT string_agg(f.id_frasco || ' (' ||")
    w("           round(100 * f.peso_neto_actual_g / p.equivalencia_g) || '%%)', ', ')")
    w("    INTO v_desborde")
    w("    FROM frasco f")
    w("    JOIN lote l         ON l.id_lote = f.id_lote")
    w("    JOIN presentacion p ON p.id_presentacion = l.id_presentacion")
    w("   WHERE p.equivalencia_g > 0")
    w("     AND f.peso_neto_actual_g > p.equivalencia_g * 1.10;")
    w("  IF v_desborde IS NOT NULL THEN")
    w("    RAISE WARNING 'CONTENIDO MAYOR QUE EL NOMINAL DE SU PRESENTACION: %',")
    w("      v_desborde;")
    w("  END IF;")
    w("END;")
    w("$$;")
    w("")
    w("-- ─── comprobación: la carga se revierte si algo no cuadra ─────────")
    w("DO $$")
    w("DECLARE v_malos INTEGER;")
    w("BEGIN")
    # El invariante es sobre el neto INICIAL, no sobre el saldo vivo: un frasco
    # del que ya se consumio tiene, con razon, menos saldo que bruto-tara.
    # Comprobar el saldo aqui abortaba cualquier recarga posterior al primer
    # consumo.
    w("  SELECT count(*) INTO v_malos FROM frasco f")
    w("   WHERE f.peso_bruto_g IS NOT NULL AND f.tara_g IS NOT NULL")
    w("     AND f.peso_neto_inicial_g IS NOT NULL")
    w("     AND abs(f.peso_neto_inicial_g - (f.peso_bruto_g - f.tara_g)) > 0.05;")
    w("  IF v_malos > 0 THEN")
    w("    RAISE EXCEPTION 'ABORTADA: % frascos cuyo neto inicial no es bruto-tara',")
    w("      v_malos;")
    w("  END IF;")
    w("END;")
    w("$$;")
    w("")
    w("COMMIT;")
    w("")
    return "\n".join(o)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--salida", type=Path,
                        default=Path("bd/carga_censo_liquidos.sql"))
    parser.add_argument("--reusar-maestros", action="store_true",
                        help="no crea insumos ni presentaciones: reutiliza los "
                             "de la base destino, resolviendo por codigo SUNAT")
    parser.add_argument("--filas", type=int, nargs="*",
                        help="filas del Excel; por defecto todas las ¿Existe?=Sí")
    args = parser.parse_args()

    idx, limpias, descartadas = leer_censo(args.filas)
    datos = construir(idx, limpias)

    salida = args.salida
    salida.parent.mkdir(parents=True, exist_ok=True)
    salida.write_text(emitir(datos, descartadas, args.reusar_maestros),
                      encoding="utf-8")

    print(f"SQL escrito en {salida}")
    print(f"  insumos        {len(datos['insumos']):>3}")
    print(f"  presentaciones {len(datos['presentaciones']):>3}")
    print(f"  densidades     {len(datos['densidades']):>3}")
    print(f"  lotes          {len(datos['lotes']):>3}")
    print(f"  ubicaciones    {len(datos['ubicaciones']):>3}")
    print(f"  investigadores {len(datos['investigadores']):>3}")
    print(f"  frascos        {len(datos['frascos']):>3}")
    print(f"  descartados    {len(descartadas):>3}")
    for fila, codigo, bloqueos in descartadas:
        print(f"    fila {fila:>3} {codigo}: {bloqueos[0]}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
