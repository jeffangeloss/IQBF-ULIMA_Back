import os
import re
import subprocess
import sys
from pathlib import Path
from urllib.parse import urlsplit, urlunsplit
from uuid import uuid4

import psycopg
import pytest
from fastapi.testclient import TestClient
from psycopg import sql
from psycopg.rows import dict_row

from app.config import get_settings
from app.security import hash_password


TEST_PASSWORD = "Prueba-Backend-IQBF-2026"
BACKEND_ROOT = Path(__file__).resolve().parents[1]


def _database_url_with_name(url: str, database: str) -> str:
    parts = urlsplit(url)
    return urlunsplit(
        (parts.scheme, parts.netloc, f"/{database}", parts.query, parts.fragment)
    )


@pytest.fixture(scope="session")
def test_database_url() -> str:
    server_url = os.environ.get(
        "IQBF_TEST_DATABASE_SERVER_URL",
        "postgresql://127.0.0.1:5432/iqbf_mvp",
    )
    test_name = f"iqbf_api_pytest_{os.getpid()}_{uuid4().hex[:8]}"
    assert re.fullmatch(r"iqbf_api_pytest_[0-9]+_[0-9a-f]{8}", test_name)

    admin_url = _database_url_with_name(server_url, "postgres")
    with psycopg.connect(admin_url, autocommit=True) as admin:
        admin.execute(
            sql.SQL("CREATE DATABASE {} TEMPLATE template0").format(
                sql.Identifier(test_name)
            )
        )

    test_url = _database_url_with_name(server_url, test_name)
    try:
        migration_environment = os.environ.copy()
        migration_environment["IQBF_DATABASE_URL"] = test_url
        first_migration = subprocess.run(
            [
                sys.executable,
                "-m",
                "app.cli",
                "migrate",
            ],
            check=True,
            cwd=BACKEND_ROOT,
            env=migration_environment,
            capture_output=True,
            text=True,
        )
        assert "Aplicada: 000_core_baseline.sql" in first_migration.stdout
        repeated_migration = subprocess.run(
            [sys.executable, "-m", "app.cli", "migrate"],
            check=True,
            cwd=BACKEND_ROOT,
            env=migration_environment,
            capture_output=True,
            text=True,
        )
        assert "Omitida (ya aplicada): 002_sprint1_acceptance.sql" in (
            repeated_migration.stdout
        )
        with psycopg.connect(test_url) as connection:
            with connection.transaction():
                connection.execute(
                    "SET LOCAL search_path TO iqbf, public, pg_catalog"
                )
                establishment = connection.execute(
                    """
                    SELECT id_establecimiento
                      FROM establecimiento
                     WHERE codigo = 'ULIMA'
                    """
                ).fetchone()[0]
                career = connection.execute(
                    """
                    INSERT INTO carrera (codigo, nombre)
                    VALUES ('CAR-PYTEST', 'Carrera Pytest')
                    RETURNING id_carrera
                    """
                ).fetchone()[0]
                connection.execute(
                    """
                    INSERT INTO laboratorio (
                      codigo, nombre, id_carrera, id_establecimiento
                    ) VALUES ('LAB-PYTEST', 'Laboratorio Pytest', %s, %s)
                    """,
                    (career, establishment),
                )
                row = connection.execute(
                    """
                    INSERT INTO usuario (
                      codigo_institucional, nombre, email, contrasena,
                      rol, estado, alcance_global
                    ) VALUES (
                      'PYTEST-ADMIN', 'Administrador Pytest',
                      'admin.pytest@ulima.edu.pe', %s,
                      'ADMIN', 'ACTIVO', true
                    )
                    RETURNING id_usuario
                    """,
                    (hash_password(TEST_PASSWORD),),
                ).fetchone()
                connection.execute(
                    """
                    INSERT INTO usuario_rol (id_usuario, codigo_rol)
                    VALUES (%s, 'ADMIN_TECNICO'),
                           (%s, 'RESPONSABLE_IQBF')
                    """,
                    (row[0], row[0]),
                )
        yield test_url
    finally:
        with psycopg.connect(admin_url, autocommit=True) as admin:
            admin.execute(
                sql.SQL("DROP DATABASE {} WITH (FORCE)").format(
                    sql.Identifier(test_name)
                )
            )


@pytest.fixture(scope="session")
def client(test_database_url: str):
    os.environ["IQBF_DATABASE_URL"] = test_database_url
    os.environ["IQBF_JWT_SECRET"] = (
        "secreto-exclusivo-de-pruebas-automatizadas-2026"
    )
    os.environ["IQBF_ENVIRONMENT"] = "test"
    get_settings.cache_clear()

    from app.main import app

    with TestClient(app, raise_server_exceptions=True) as test_client:
        yield test_client

    get_settings.cache_clear()


@pytest.fixture
def db_connection(test_database_url: str):
    with psycopg.connect(
        test_database_url,
        autocommit=True,
        row_factory=dict_row,
    ) as connection:
        connection.execute(
            "SET search_path TO iqbf, public, pg_catalog"
        )
        yield connection


@pytest.fixture
def admin_headers(client: TestClient) -> dict[str, str]:
    response = client.post(
        "/api/auth/login",
        json={
            "email": "admin.pytest@ulima.edu.pe",
            "password": TEST_PASSWORD,
        },
    )
    assert response.status_code == 200, response.text
    return {
        "Authorization": f"Bearer {response.json()['access_token']}",
        "X-Request-ID": str(uuid4()),
    }
