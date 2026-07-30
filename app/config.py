from functools import lru_cache
from typing import Annotated, Literal

from pydantic import Field, SecretStr, field_validator, model_validator
from pydantic_settings import BaseSettings, NoDecode, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_prefix="IQBF_",
        extra="ignore",
    )

    app_name: str = "IQBF ULIMA API"
    environment: str = "development"
    auth_mode: Literal["local"] = "local"
    database_url: str = "postgresql://127.0.0.1:5432/iqbf_mvp"
    jwt_secret: SecretStr = SecretStr(
        "solo-desarrollo-cambie-este-secreto-antes-de-desplegar"
    )
    jwt_algorithm: Literal["HS256"] = "HS256"
    access_token_minutes: int = Field(default=30, ge=5, le=480)
    cors_origins: Annotated[list[str], NoDecode] = ["http://localhost:5173"]
    public_base_url: str = "http://127.0.0.1:8000"
    pool_min_size: int = Field(default=1, ge=1, le=20)
    pool_max_size: int = Field(default=10, ge=1, le=50)
    # Espera máxima por una conexión libre antes de responder 503. Debe ser
    # menor que el tiempo de espera del proxy para que el cliente reciba el
    # problema en vez de un corte de conexión.
    pool_timeout: float = Field(default=10.0, ge=1.0, le=60.0)

    @property
    def server_description(self) -> str:
        return {
            "development": "Desarrollo local",
            "test": "Pruebas automatizadas",
            "production": "Producción",
        }.get(self.environment.lower(), self.environment)

    @field_validator("cors_origins", mode="before")
    @classmethod
    def parse_cors_origins(cls, value: object) -> object:
        if isinstance(value, str):
            return [item.strip() for item in value.split(",") if item.strip()]
        return value

    @model_validator(mode="after")
    def validate_pool_bounds(self) -> "Settings":
        if self.pool_min_size > self.pool_max_size:
            raise ValueError(
                "IQBF_POOL_MIN_SIZE no puede superar a IQBF_POOL_MAX_SIZE."
            )
        return self

    @model_validator(mode="after")
    def validate_production_secrets(self) -> "Settings":
        default_secret = (
            "solo-desarrollo-cambie-este-secreto-antes-de-desplegar"
        )
        secret = self.jwt_secret.get_secret_value()
        if self.environment.lower() not in {"development", "test"} and (
            secret == default_secret or len(secret) < 32
        ):
            raise ValueError(
                "IQBF_JWT_SECRET debe ser explícito y tener al menos "
                "32 caracteres fuera de desarrollo/pruebas."
            )
        return self


@lru_cache
def get_settings() -> Settings:
    return Settings()
