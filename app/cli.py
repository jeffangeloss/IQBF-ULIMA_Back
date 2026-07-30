import argparse
import getpass
import os
from pathlib import Path
import re

import psycopg
from psycopg.rows import dict_row

from app.config import get_settings
from app.security import hash_password


BACKEND_ROOT = Path(__file__).resolve().parents[1]
MIGRATIONS_DIR = BACKEND_ROOT / "migrations"


def migrate() -> None:
    settings = get_settings()
    files = sorted(MIGRATIONS_DIR.glob("*.sql"))
    if not files:
        raise SystemExit("No se encontraron migraciones.")
    with psycopg.connect(
        settings.database_url,
        row_factory=dict_row,
        autocommit=True,
    ) as connection:
        for path in files:
            match = re.match(r"^([0-9]{3})_", path.name)
            if match is None:
                raise SystemExit(
                    f"La migración {path.name} no empieza con una versión de 3 dígitos."
                )
            version = match.group(1)
            migration_table_exists = connection.execute(
                "SELECT to_regclass('iqbf.schema_migration') IS NOT NULL AS existe"
            ).fetchone()["existe"]
            if migration_table_exists:
                already_applied = connection.execute(
                    """
                    SELECT EXISTS (
                      SELECT 1
                        FROM iqbf.schema_migration
                       WHERE version = %s
                    ) AS aplicada
                    """,
                    (version,),
                ).fetchone()["aplicada"]
                if already_applied:
                    print(f"Omitida (ya aplicada): {path.name}")
                    continue
            sql_text = path.read_text(encoding="utf-8")
            connection.execute(sql_text)
            recorded = connection.execute(
                """
                SELECT EXISTS (
                  SELECT 1
                    FROM iqbf.schema_migration
                   WHERE version = %s
                ) AS registrada
                """,
                (version,),
            ).fetchone()["registrada"]
            if not recorded:
                raise RuntimeError(
                    f"La migración {path.name} no registró la versión {version}."
                )
            print(f"Aplicada: {path.name}")


def create_admin(args: argparse.Namespace) -> None:
    settings = get_settings()
    password = os.environ.get("IQBF_ADMIN_PASSWORD")
    if not password:
        password = getpass.getpass("Contraseña inicial (mínimo 12 caracteres): ")
    if len(password) < 12:
        raise SystemExit("La contraseña debe tener al menos 12 caracteres.")

    with psycopg.connect(settings.database_url, row_factory=dict_row) as connection:
        with connection.transaction():
            connection.execute(
                "SET LOCAL search_path TO iqbf, public, pg_catalog"
            )
            row = connection.execute(
                """
                INSERT INTO usuario (
                  codigo_institucional, nombre, email, contrasena,
                  rol, estado, alcance_global
                ) VALUES (%s, %s, %s, %s, 'ADMIN', 'ACTIVO', true)
                RETURNING id_usuario
                """,
                (args.code, args.name, args.email, hash_password(password)),
            ).fetchone()
            connection.execute(
                """
                INSERT INTO usuario_rol (id_usuario, codigo_rol)
                VALUES (%s, 'ADMIN_TECNICO'), (%s, 'RESPONSABLE_IQBF')
                """,
                (row["id_usuario"], row["id_usuario"]),
            )
    print(f"Administrador creado: {args.email}")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Administración de IQBF API")
    subparsers = parser.add_subparsers(dest="command", required=True)
    subparsers.add_parser("migrate", help="Aplicar migraciones SQL")

    admin = subparsers.add_parser(
        "create-admin", help="Crear la primera cuenta administrativa"
    )
    admin.add_argument("--email", required=True)
    admin.add_argument("--code", required=True)
    admin.add_argument("--name", required=True)
    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()
    if args.command == "migrate":
        migrate()
    elif args.command == "create-admin":
        create_admin(args)


if __name__ == "__main__":
    main()
