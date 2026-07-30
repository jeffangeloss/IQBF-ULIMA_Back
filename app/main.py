from collections.abc import AsyncIterator
from contextlib import asynccontextmanager
from uuid import UUID, uuid4

from fastapi import Depends, FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from psycopg import Connection

from app import __version__
from app.config import get_settings
from app.database import Database
from app.dependencies import get_connection
from app.errors import register_exception_handlers
from app.routers import auth, catalogs, insumos, users
from app.schemas import Health, Problem


COMMON_PROBLEM_RESPONSES = {
    400: {"model": Problem, "description": "Solicitud inválida"},
    401: {"model": Problem, "description": "Autenticación requerida o inválida"},
    403: {"model": Problem, "description": "Permiso denegado"},
    404: {"model": Problem, "description": "Recurso inexistente"},
    409: {"model": Problem, "description": "Conflicto con el estado actual"},
    422: {"model": Problem, "description": "Validación o regla de negocio"},
    500: {"model": Problem, "description": "Error interno"},
}


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    settings = get_settings()
    database = Database(settings)
    database.open()
    app.state.database = database
    try:
        yield
    finally:
        database.close()


settings = get_settings()
app = FastAPI(
    title="IQBF ULIMA API",
    summary="API transaccional para la gestión de IQBF",
    description=(
        "Contrato del Sprint 1: identidad, organización, insumos, "
        "presentaciones, densidades versionadas y auditoría."
    ),
    version=__version__,
    openapi_version="3.1.0",
    openapi_url="/api/openapi.json",
    docs_url="/api/docs",
    redoc_url="/api/redoc",
    servers=[
        {
            "url": "http://127.0.0.1:8000",
            "description": "Desarrollo local",
        }
    ],
    responses=COMMON_PROBLEM_RESPONSES,
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PATCH", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type", "Idempotency-Key", "X-Request-ID"],
    expose_headers=["X-Request-ID"],
)


@app.middleware("http")
async def request_id_middleware(request: Request, call_next):
    supplied = request.headers.get("X-Request-ID")
    try:
        request_id = UUID(supplied) if supplied else uuid4()
    except ValueError:
        request_id = uuid4()
    request.state.request_id = request_id
    response = await call_next(request)
    response.headers["X-Request-ID"] = str(request_id)
    return response


register_exception_handlers(app)
app.include_router(auth.router)
app.include_router(users.router)
app.include_router(insumos.router)
app.include_router(catalogs.router)


_default_openapi = app.openapi


def custom_openapi() -> dict:
    if app.openapi_schema:
        return app.openapi_schema
    schema = _default_openapi()
    for path in schema.get("paths", {}).values():
        for method, operation in path.items():
            if method not in {
                "get",
                "post",
                "put",
                "patch",
                "delete",
                "options",
                "head",
            }:
                continue
            for status_code, response in operation.get(
                "responses", {}
            ).items():
                response.setdefault("headers", {})["X-Request-ID"] = {
                    "description": "Identificador de correlación de la solicitud",
                    "schema": {"type": "string", "format": "uuid"},
                }
                if str(status_code).startswith(("4", "5")):
                    content = response.setdefault("content", {})
                    if "application/json" in content:
                        content["application/problem+json"] = content.pop(
                            "application/json"
                        )
    app.openapi_schema = schema
    return schema


app.openapi = custom_openapi


@app.get(
    "/api/health",
    response_model=Health,
    tags=["Sistema"],
    summary="Comprobar la API y PostgreSQL",
)
def health(connection: Connection = Depends(get_connection)) -> Health:
    connection.execute("SELECT 1").fetchone()
    return Health(status="ok", database="ok", version=__version__)
