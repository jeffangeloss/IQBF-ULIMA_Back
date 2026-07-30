from http import HTTPStatus
import logging
from typing import Any

import psycopg
from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse


PROBLEM_MEDIA_TYPE = "application/problem+json"
logger = logging.getLogger("iqbf.api")


class ProblemException(Exception):
    def __init__(
        self,
        status: int,
        code: str,
        title: str,
        detail: str,
        *,
        field: str | None = None,
        extra: dict[str, Any] | None = None,
    ) -> None:
        self.status = status
        self.code = code
        self.title = title
        self.detail = detail
        self.field = field
        self.extra = extra or {}
        super().__init__(detail)


def _problem_payload(
    request: Request,
    *,
    status: int,
    code: str,
    title: str,
    detail: str,
    field: str | None = None,
    extra: dict[str, Any] | None = None,
) -> dict[str, Any]:
    payload: dict[str, Any] = {
        "type": f"https://iqbf.ulima.edu.pe/problemas/{code.lower()}",
        "title": title,
        "status": status,
        "detail": detail,
        "instance": str(request.url.path),
        "code": code,
        "request_id": str(getattr(request.state, "request_id", "")),
    }
    if field:
        payload["field"] = field
    if extra:
        payload.update(extra)
    return payload


def _map_database_error(error: psycopg.Error) -> tuple[int, str, str, str]:
    detail = str(error).splitlines()[0]
    lowered = detail.lower()

    if isinstance(error, psycopg.errors.UniqueViolation):
        return 409, "REGISTRO_DUPLICADO", "Registro duplicado", detail
    if isinstance(error, psycopg.errors.ForeignKeyViolation):
        return 422, "REFERENCIA_INVALIDA", "Referencia inválida", detail
    if isinstance(error, psycopg.errors.NotNullViolation):
        return 422, "VALIDACION", "Dato requerido", detail
    if isinstance(error, psycopg.errors.StringDataRightTruncation):
        return 422, "VALIDACION", "Dato demasiado largo", detail
    if isinstance(error, psycopg.errors.CheckViolation):
        return 422, "REGLA_NEGOCIO", "Regla de negocio incumplida", detail
    if "saldo insuficiente" in lowered:
        return 409, "SALDO_INSUFICIENTE", "Saldo insuficiente", detail
    if "requiere un motivo" in lowered:
        return 422, "MOTIVO_REQUERIDO", "Motivo requerido", detail
    if (
        "insumo inactivo" in lowered
        or "insumo o presentacion inactiva" in lowered
    ):
        return 409, "INSUMO_INACTIVO", "Maestro inactivo", detail
    if "no se modifica ni se borra" in lowered:
        return 409, "KARDEX_INMUTABLE", "Kardex inmutable", detail
    if "solo puede cambiar registrando" in lowered:
        return 409, "SALDO_SOLO_VIA_KARDEX", "Saldo protegido", detail
    if "falta la densidad" in lowered:
        return 422, "DENSIDAD_REQUERIDA", "Densidad requerida", detail
    if "requiere densidad fija" in lowered:
        return 422, "DENSIDAD_REQUERIDA", "Densidad requerida", detail
    if (
        "densidad variable" in lowered
        and "registre la densidad en lote" in lowered
    ):
        return (
            422,
            "DENSIDAD_LOTE_REQUERIDA",
            "Densidad de lote requerida",
            detail,
        )
    if "ya tiene una densidad vigente" in lowered:
        return 409, "VIGENCIA_SOLAPADA", "Vigencia solapada", detail
    return (
        500,
        "ERROR_BASE_DATOS",
        "Error de base de datos",
        "La operación no pudo completarse.",
    )


def register_exception_handlers(app: FastAPI) -> None:
    @app.exception_handler(ProblemException)
    async def handle_problem(
        request: Request, error: ProblemException
    ) -> JSONResponse:
        return JSONResponse(
            status_code=error.status,
            media_type=PROBLEM_MEDIA_TYPE,
            content=_problem_payload(
                request,
                status=error.status,
                code=error.code,
                title=error.title,
                detail=error.detail,
                field=error.field,
                extra=error.extra,
            ),
        )

    @app.exception_handler(RequestValidationError)
    async def handle_validation(
        request: Request, error: RequestValidationError
    ) -> JSONResponse:
        issues = [
            {
                "field": ".".join(str(part) for part in issue["loc"][1:]),
                "message": issue["msg"],
                "type": issue["type"],
            }
            for issue in error.errors()
        ]
        return JSONResponse(
            status_code=422,
            media_type=PROBLEM_MEDIA_TYPE,
            content=_problem_payload(
                request,
                status=422,
                code="VALIDACION",
                title="Datos inválidos",
                detail="Revise los campos indicados.",
                extra={"errors": issues},
            ),
        )

    @app.exception_handler(psycopg.Error)
    async def handle_database(
        request: Request, error: psycopg.Error
    ) -> JSONResponse:
        status, code, title, detail = _map_database_error(error)
        return JSONResponse(
            status_code=status,
            media_type=PROBLEM_MEDIA_TYPE,
            content=_problem_payload(
                request,
                status=status,
                code=code,
                title=title,
                detail=detail,
            ),
        )

    @app.exception_handler(Exception)
    async def handle_unexpected(
        request: Request, error: Exception
    ) -> JSONResponse:
        logger.exception(
            "Error no controlado request_id=%s path=%s",
            getattr(request.state, "request_id", ""),
            request.url.path,
            exc_info=error,
        )
        return JSONResponse(
            status_code=HTTPStatus.INTERNAL_SERVER_ERROR,
            media_type=PROBLEM_MEDIA_TYPE,
            content=_problem_payload(
                request,
                status=500,
                code="ERROR_INTERNO",
                title="Error interno",
                detail="Ocurrió un error inesperado.",
            ),
        )
