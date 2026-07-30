"""Punto de entrada ASGI.

La composición vive en ``app.application`` para permitir instancias aisladas
en pruebas y evitar configuración global dispersa.
"""

from app.application import create_app


app = create_app()
