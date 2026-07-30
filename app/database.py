from collections.abc import Iterator
from contextlib import contextmanager

from psycopg import Connection
from psycopg.rows import dict_row
from psycopg_pool import ConnectionPool

from app.config import Settings


class Database:
    def __init__(self, settings: Settings) -> None:
        self.pool = ConnectionPool(
            conninfo=settings.database_url,
            min_size=settings.pool_min_size,
            max_size=settings.pool_max_size,
            timeout=settings.pool_timeout,
            open=False,
            kwargs={"row_factory": dict_row},
            check=ConnectionPool.check_connection,
        )

    def open(self) -> None:
        self.pool.open(wait=True)

    def close(self) -> None:
        self.pool.close()

    @contextmanager
    def connection(self) -> Iterator[Connection]:
        with self.pool.connection() as connection:
            with connection.transaction():
                connection.execute(
                    "SET LOCAL search_path TO iqbf, public, pg_catalog"
                )
                yield connection
