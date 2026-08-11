"""Registro explícito de capacidades HTTP.

Este módulo es el único lugar que conoce todos los routers. Los módulos de
negocio no se importan entre sí; comparten únicamente contratos y
dependencias transversales.
"""

from fastapi import APIRouter, Depends, FastAPI
from psycopg import Connection

from app import __version__
from app.contracts import Health
from app.dependencies import get_connection
from app.modules.auth.router import router as auth_router
from app.modules.autorizaciones.router import router as autorizaciones_router
from app.modules.catalogs.router import router as catalogs_router
from app.modules.insumos.router import router as insumos_router
from app.modules.inventario.router import router as inventario_router
from app.modules.users.router import router as users_router


from app.modules.inventario.reportes_rm04 import router as reportes_rm04_router


system_router = APIRouter()


@system_router.get(
    "/api/health",
    response_model=Health,
    tags=["Sistema"],
    summary="Comprobar la API y PostgreSQL",
)
def health(connection: Connection = Depends(get_connection)) -> Health:
    connection.execute("SELECT 1").fetchone()
    return Health(status="ok", database="ok", version=__version__)


ROUTERS = (
    auth_router,
    users_router,
    insumos_router,
    inventario_router,
    reportes_rm04_router,
    autorizaciones_router,
    catalogs_router,
    system_router,
)


def register_routers(app: FastAPI) -> None:
    for router in ROUTERS:
        app.include_router(router)
