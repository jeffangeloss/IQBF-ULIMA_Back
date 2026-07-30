"""Guardas ejecutables para evitar que la arquitectura vuelva a degradarse."""

from __future__ import annotations

import ast
from pathlib import Path

import pytest
from fastapi.testclient import TestClient
from pydantic import ValidationError
from psycopg_pool import PoolTimeout

from app.application import create_app
from app.config import Settings
from app.database import Database
from app.dependencies import get_connection


ROOT = Path(__file__).resolve().parents[1]
APP = ROOT / "app"
TEST_DATABASE_URL = "postgresql://127.0.0.1:5432/iqbf_test"


def _settings(**overrides: object) -> Settings:
    base: dict[str, object] = {
        "_env_file": None,
        "environment": "test",
        "database_url": TEST_DATABASE_URL,
    }
    base.update(overrides)
    return Settings(**base)


def _imports(path: Path) -> set[str]:
    tree = ast.parse(path.read_text(encoding="utf-8"))
    imported: set[str] = set()
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            imported.update(alias.name for alias in node.names)
        elif isinstance(node, ast.ImportFrom) and node.module:
            imported.add(node.module)
    return imported


def test_main_is_only_the_asgi_composition_entrypoint() -> None:
    assert _imports(APP / "main.py") == {"app.application"}


def test_modules_do_not_import_another_modules_router() -> None:
    for router in (APP / "modules").glob("*/router.py"):
        own_module = router.parent.name
        forbidden = {
            item
            for item in _imports(router)
            if item.startswith("app.modules.")
            and item.endswith(".router")
            and f"app.modules.{own_module}." not in item
        }
        assert forbidden == set(), f"{router}: {sorted(forbidden)}"


def test_removed_flat_layers_cannot_return() -> None:
    python = "\n".join(
        path.read_text(encoding="utf-8")
        for path in APP.rglob("*.py")
        if "__pycache__" not in path.parts
    )
    assert "app.schemas" not in python
    assert "app.routers" not in python


def test_reference_antipatterns_are_not_copied() -> None:
    runtime = "\n".join(
        path.read_text(encoding="utf-8")
        for path in APP.rglob("*.py")
        if path.name != "test_architecture.py"
    )
    assert "JWT_SECRET_KEY =" not in runtime
    assert "SECRET_KEY =" not in runtime
    assert 'create_engine("sqlite:' not in runtime
    assert "echo=True" not in runtime
    assert "password == password" not in runtime


def test_factory_builds_isolated_apps_and_comma_separated_cors() -> None:
    settings = Settings(
        _env_file=None,
        environment="test",
        database_url="postgresql://127.0.0.1:5432/iqbf_test",
        cors_origins="http://localhost:5173,http://127.0.0.1:5173",
    )
    first = create_app(settings)
    second = create_app(settings)

    assert first is not second
    assert settings.cors_origins == [
        "http://localhost:5173",
        "http://127.0.0.1:5173",
    ]
    assert "/api/auth/login" in first.openapi()["paths"]
    assert "/api/insumos" in first.openapi()["paths"]


def test_pool_saturation_is_reported_as_503_and_not_as_internal_error() -> None:
    """PoolTimeout hereda de psycopg.Error: sin manejador propio saldría 500."""

    app = create_app(_settings())

    def unavailable_connection() -> None:
        raise PoolTimeout("no hay conexiones libres en el pool")

    app.dependency_overrides[get_connection] = unavailable_connection
    # Sin gestor de contexto no se ejecuta el ciclo de vida: la prueba no
    # necesita PostgreSQL porque la dependencia está sustituida.
    response = TestClient(app).get("/api/health")

    assert response.status_code == 503
    assert response.headers["Retry-After"] == "5"
    assert response.headers["content-type"].startswith(
        "application/problem+json"
    )
    assert response.json()["code"] == "SERVICIO_SATURADO"


def test_pool_timeout_reaches_the_pool() -> None:
    database = Database(_settings(pool_timeout=7.0))

    assert database.pool.timeout == 7.0


def test_pool_min_size_cannot_exceed_max_size() -> None:
    with pytest.raises(ValidationError):
        _settings(pool_min_size=10, pool_max_size=5)


def test_published_contract_announces_the_configured_public_host() -> None:
    published = create_app(
        _settings(
            environment="production",
            jwt_secret="secreto-de-produccion-para-pruebas-2026",
            public_base_url="https://api.iqbf.ulima.edu.pe",
        )
    ).openapi()["servers"]

    assert published[0] == {
        "url": "https://api.iqbf.ulima.edu.pe",
        "description": "Producción",
    }

    local = create_app(_settings(environment="development")).openapi()["servers"]

    assert local[0] == {
        "url": "http://127.0.0.1:8000",
        "description": "Desarrollo local",
    }
