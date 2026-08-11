"""Lo que `app/` importa tiene que estar instalado en Render.

Render construye con `pip install -r requirements.txt` y arranca con
`migrate && uvicorn`: una dependencia que existe en el entorno local pero
no está declarada pasa todas las pruebas y revienta al importar la
aplicación en la nube, con el servicio caído. Esta prueba cierra ese hueco
sin tener que esperar al despliegue.
"""

import ast
import pathlib
import re
import sys
from importlib.metadata import PackageNotFoundError, packages_distributions, requires

RAIZ = pathlib.Path(__file__).resolve().parents[1]


def _normalizar(nombre: str) -> str:
    return re.sub(r"[-_.]+", "-", nombre).strip().lower()


def _declaradas() -> set[str]:
    """Nombres que aparecen en requirements.txt, sin extras ni versión."""
    declaradas = set()
    for linea in (RAIZ / "requirements.txt").read_text(encoding="utf-8").splitlines():
        linea = linea.split("#", 1)[0].strip()
        if not linea or linea.startswith("-"):
            continue
        declaradas.add(_normalizar(re.split(r"[\[<>=!;]", linea, 1)[0]))
    return declaradas


def _cierre(semillas: set[str]) -> set[str]:
    """Las declaradas más todo lo que ellas arrastran, en profundidad."""
    vistas: set[str] = set()
    pendientes = list(semillas)
    while pendientes:
        actual = pendientes.pop()
        if actual in vistas:
            continue
        vistas.add(actual)
        try:
            dependencias = requires(actual) or []
        except PackageNotFoundError:
            continue
        for bruto in dependencias:
            nombre = _normalizar(re.split(r"[\[<>=!;() ]", bruto, 1)[0])
            if nombre and nombre not in vistas:
                pendientes.append(nombre)
    return vistas


def _importados() -> set[str]:
    """Módulos de terceros que `app/` importa de verdad."""
    modulos: set[str] = set()
    for archivo in (RAIZ / "app").rglob("*.py"):
        arbol = ast.parse(archivo.read_text(encoding="utf-8"), filename=str(archivo))
        for nodo in ast.walk(arbol):
            if isinstance(nodo, ast.Import):
                modulos.update(alias.name.split(".")[0] for alias in nodo.names)
            elif isinstance(nodo, ast.ImportFrom) and nodo.level == 0 and nodo.module:
                modulos.add(nodo.module.split(".")[0])
    return {m for m in modulos if m != "app" and m not in sys.stdlib_module_names}


def test_lo_que_la_aplicacion_importa_se_instala_en_produccion():
    disponible = _cierre(_declaradas())
    mapa = packages_distributions()

    sin_declarar = {
        modulo: mapa.get(modulo, [])
        for modulo in sorted(_importados())
        if not any(_normalizar(dist) in disponible for dist in mapa.get(modulo, []))
    }

    assert not sin_declarar, (
        "Estos módulos se importan en app/ pero no llegan a requirements.txt "
        f"ni a sus dependencias: {sin_declarar}. En Render el arranque falla "
        "con ModuleNotFoundError y el servicio queda caído."
    )
