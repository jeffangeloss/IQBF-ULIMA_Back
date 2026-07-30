from datetime import date, timedelta
from decimal import Decimal
from time import perf_counter
from uuid import uuid4

import psycopg
import pytest
from fastapi.testclient import TestClient
from psycopg import Connection


DEMO_PASSWORD = "Prueba-Desechable-IQBF-2026"


def _login(
    client: TestClient, email: str, password: str = DEMO_PASSWORD
) -> dict[str, str]:
    response = client.post(
        "/api/auth/login",
        json={"email": email, "password": password},
    )
    assert response.status_code == 200, response.text
    return {"Authorization": f"Bearer {response.json()['access_token']}"}


def _create_account(
    client: TestClient,
    admin_headers: dict[str, str],
    *,
    suffix: str,
    role: str,
    global_scope: bool,
    laboratory_id: int | None = None,
) -> dict:
    payload = {
        "codigo_institucional": f"PYTEST-{suffix}",
        "nombre": f"Cuenta {suffix}",
        "email": f"{suffix.lower()}@pytest.ulima.edu.pe",
        "password": DEMO_PASSWORD,
        "roles": [role],
        "alcance_global": global_scope,
        "laboratorios": [] if global_scope else [laboratory_id],
    }
    response = client.post(
        "/api/usuarios", headers=admin_headers, json=payload
    )
    assert response.status_code == 201, response.text
    return response.json()


def _initial_laboratory_id(
    client: TestClient, admin_headers: dict[str, str]
) -> int:
    response = client.get(
        "/api/catalogos/laboratorios", headers=admin_headers
    )
    assert response.status_code == 200, response.text
    return int(response.json()[0]["id"])


def test_us001_invalid_login_does_not_create_session_and_logout_is_recorded(
    client: TestClient,
    db_connection: Connection,
) -> None:
    user_id = db_connection.execute(
        """
        SELECT id_usuario
          FROM usuario
         WHERE email = 'admin.pytest@ulima.edu.pe'
        """
    ).fetchone()["id_usuario"]
    before = db_connection.execute(
        "SELECT count(*) AS total FROM sesion WHERE id_usuario = %s",
        (user_id,),
    ).fetchone()["total"]

    invalid = client.post(
        "/api/auth/login",
        json={
            "email": "admin.pytest@ulima.edu.pe",
            "password": "incorrecta",
        },
    )
    assert invalid.status_code == 401
    assert invalid.json()["code"] == "CREDENCIALES_INVALIDAS"
    after_invalid = db_connection.execute(
        "SELECT count(*) AS total FROM sesion WHERE id_usuario = %s",
        (user_id,),
    ).fetchone()["total"]
    assert after_invalid == before

    headers = _login(
        client,
        "admin.pytest@ulima.edu.pe",
        "Prueba-Backend-IQBF-2026",
    )
    active = db_connection.execute(
        """
        SELECT id_sesion
          FROM sesion
         WHERE id_usuario = %s
           AND cerrada_en IS NULL
           AND revocada_en IS NULL
         ORDER BY iniciada_en DESC
         LIMIT 1
        """,
        (user_id,),
    ).fetchone()
    assert active is not None

    logout = client.post("/api/auth/logout", headers=headers)
    assert logout.status_code == 204
    closed = db_connection.execute(
        "SELECT cerrada_en FROM sesion WHERE id_sesion = %s",
        (active["id_sesion"],),
    ).fetchone()
    assert closed["cerrada_en"] is not None


def test_us002_six_roles_have_differentiated_backend_permissions(
    client: TestClient,
    admin_headers: dict[str, str],
) -> None:
    laboratory_id = _initial_laboratory_id(client, admin_headers)
    roles = [
        "RESPONSABLE_IQBF",
        "OPERADOR_DOCIMASIA",
        "DOCENTE_INVESTIGADOR",
        "APROBADOR",
        "AUDITOR",
        "ADMIN_TECNICO",
    ]
    headers_by_role: dict[str, dict[str, str]] = {}
    for index, role in enumerate(roles):
        global_scope = role in {"RESPONSABLE_IQBF", "ADMIN_TECNICO"}
        suffix = f"RBAC-{index}-{role}"
        _create_account(
            client,
            admin_headers,
            suffix=suffix,
            role=role,
            global_scope=global_scope,
            laboratory_id=laboratory_id,
        )
        role_headers = _login(
            client, f"{suffix.lower()}@pytest.ulima.edu.pe"
        )
        me = client.get("/api/auth/me", headers=role_headers)
        assert me.status_code == 200
        assert me.json()["roles"] == [role]
        headers_by_role[role] = role_headers

    responsible_create = client.post(
        "/api/insumos",
        headers=headers_by_role["RESPONSABLE_IQBF"],
        json={
            "id_insumo": "PYTEST-RBAC-IQBF",
            "nombre_comercial": "Maestro permitido por rol",
            "tipo": "SOLIDO",
        },
    )
    assert responsible_create.status_code == 201, responsible_create.text

    admin_denied_master = client.post(
        "/api/insumos",
        headers=headers_by_role["ADMIN_TECNICO"],
        json={
            "id_insumo": "PYTEST-RBAC-ADMIN-DENIED",
            "nombre_comercial": "Maestro no permitido",
            "tipo": "SOLIDO",
        },
    )
    assert admin_denied_master.status_code == 403
    assert admin_denied_master.json()["code"] == "PERMISO_DENEGADO"

    admin_creates_account = client.post(
        "/api/usuarios",
        headers=headers_by_role["ADMIN_TECNICO"],
        json={
            "codigo_institucional": "PYTEST-RBAC-ADMIN-CREATED",
            "nombre": "Cuenta creada por administrador",
            "email": "rbac-admin-created@pytest.ulima.edu.pe",
            "password": DEMO_PASSWORD,
            "roles": ["AUDITOR"],
            "alcance_global": False,
            "laboratorios": [laboratory_id],
        },
    )
    assert admin_creates_account.status_code == 201

    responsible_denied_accounts = client.post(
        "/api/usuarios",
        headers=headers_by_role["RESPONSABLE_IQBF"],
        json={
            "codigo_institucional": "PYTEST-RBAC-RESP-DENIED",
            "nombre": "Cuenta no permitida",
            "email": "rbac-resp-denied@pytest.ulima.edu.pe",
            "password": DEMO_PASSWORD,
            "roles": ["AUDITOR"],
            "alcance_global": False,
            "laboratorios": [laboratory_id],
        },
    )
    assert responsible_denied_accounts.status_code == 403

    for role in {
        "OPERADOR_DOCIMASIA",
        "DOCENTE_INVESTIGADOR",
        "APROBADOR",
        "AUDITOR",
    }:
        denied = client.post(
            "/api/insumos",
            headers=headers_by_role[role],
            json={
                "id_insumo": f"PYTEST-RBAC-DENIED-{role}",
                "nombre_comercial": "No permitido",
                "tipo": "SOLIDO",
            },
        )
        assert denied.status_code == 403
        assert denied.json()["code"] == "PERMISO_DENEGADO"

    scoped_responsible = _create_account(
        client,
        admin_headers,
        suffix="RBAC-RESP-SCOPED",
        role="RESPONSABLE_IQBF",
        global_scope=False,
        laboratory_id=laboratory_id,
    )
    scoped_headers = _login(client, scoped_responsible["email"])
    denied_by_scope = client.post(
        "/api/insumos",
        headers=scoped_headers,
        json={
            "id_insumo": "PYTEST-SCOPE-DENIED",
            "nombre_comercial": "No permitido por alcance",
            "tipo": "SOLIDO",
        },
    )
    assert denied_by_scope.status_code == 403
    assert denied_by_scope.json()["code"] == "ALCANCE_GLOBAL_REQUERIDO"


def test_us003_accounts_are_unique_inactivated_and_audited(
    client: TestClient,
    admin_headers: dict[str, str],
    db_connection: Connection,
) -> None:
    laboratory_id = _initial_laboratory_id(client, admin_headers)
    created = _create_account(
        client,
        admin_headers,
        suffix="ACCOUNT-AUDIT",
        role="OPERADOR_DOCIMASIA",
        global_scope=False,
        laboratory_id=laboratory_id,
    )

    duplicate = client.post(
        "/api/usuarios",
        headers=admin_headers,
        json={
            "codigo_institucional": "pytest-account-audit",
            "nombre": "Código institucional repetido",
            "email": "account-audit-duplicate@pytest.ulima.edu.pe",
            "password": DEMO_PASSWORD,
            "roles": ["AUDITOR"],
            "alcance_global": False,
            "laboratorios": [laboratory_id],
        },
    )
    assert duplicate.status_code == 409
    assert duplicate.json()["code"] == "REGISTRO_DUPLICADO"

    request_id = str(uuid4())
    changed = client.patch(
        f"/api/usuarios/{created['id_usuario']}",
        headers={**admin_headers, "X-Request-ID": request_id},
        json={"roles": ["AUDITOR"]},
    )
    assert changed.status_code == 200, changed.text
    assert changed.json()["roles"] == ["AUDITOR"]

    role_audit = db_connection.execute(
        """
        SELECT accion, valores_antes, valores_despues
          FROM bitacora
         WHERE request_id = %s
           AND entidad = 'usuario_rol'
         ORDER BY id_evento
        """,
        (request_id,),
    ).fetchall()
    assert {row["accion"] for row in role_audit} == {"DELETE", "INSERT"}

    disabled = client.patch(
        f"/api/usuarios/{created['id_usuario']}",
        headers=admin_headers,
        json={"estado": "INACTIVO"},
    )
    assert disabled.status_code == 200
    assert disabled.json()["estado"] == "INACTIVO"

    denied_login = client.post(
        "/api/auth/login",
        json={"email": created["email"], "password": DEMO_PASSWORD},
    )
    assert denied_login.status_code == 403
    assert denied_login.json()["code"] == "CUENTA_INACTIVA"
    preserved = db_connection.execute(
        """
        SELECT estado
          FROM usuario
         WHERE id_usuario = %s
        """,
        (created["id_usuario"],),
    ).fetchone()
    assert preserved["estado"] == "INACTIVO"
    leaked_hashes = db_connection.execute(
        """
        SELECT count(*) AS total
          FROM bitacora
         WHERE valores_antes::text LIKE '%contrasena%'
            OR valores_despues::text LIKE '%contrasena%'
        """
    ).fetchone()["total"]
    assert leaked_hashes == 0


def test_us004_us005_organization_and_people_keep_vigency_and_history(
    client: TestClient,
    admin_headers: dict[str, str],
) -> None:
    establishment = client.post(
        "/api/catalogos/establecimientos",
        headers=admin_headers,
        json={
            "codigo": "SEDE-ACCEPTANCE",
            "nombre": "Sede de aceptación",
            "vigencia_desde": "2026-07-01",
        },
    )
    assert establishment.status_code == 201, establishment.text
    establishment_id = int(establishment.json()["id"])

    career = client.post(
        "/api/catalogos/carreras",
        headers=admin_headers,
        json={
            "codigo": "CAR-ACCEPTANCE",
            "nombre": "Carrera de aceptación",
            "vigencia_desde": "2026-07-01",
        },
    )
    assert career.status_code == 201, career.text
    career_id = int(career.json()["id"])

    laboratory = client.post(
        "/api/catalogos/laboratorios",
        headers=admin_headers,
        json={
            "codigo": "LAB-ACCEPTANCE",
            "nombre": "Laboratorio de aceptación",
            "id_establecimiento": establishment_id,
            "id_carrera": career_id,
            "vigencia_desde": "2026-07-01",
        },
    )
    assert laboratory.status_code == 201, laboratory.text
    laboratory_id = int(laboratory.json()["id"])

    person = client.post(
        "/api/catalogos/investigadores",
        headers=admin_headers,
        json={
            "codigo": "ACTOR-ACCEPTANCE",
            "nombre": "Persona de aceptación",
            "tipo": "PERSONA",
            "email": "actor-acceptance@ulima.edu.pe",
            "id_carrera": career_id,
            "id_laboratorio": laboratory_id,
            "vigencia_desde": "2026-07-01",
        },
    )
    assert person.status_code == 201, person.text
    person_id = person.json()["id"]

    duplicate = client.post(
        "/api/catalogos/investigadores",
        headers=admin_headers,
        json={
            "codigo": "actor-acceptance",
            "nombre": "Persona duplicada",
            "tipo": "PERSONA",
            "id_laboratorio": laboratory_id,
        },
    )
    assert duplicate.status_code == 409

    inactive_person = client.patch(
        f"/api/catalogos/investigadores/{person_id}",
        headers=admin_headers,
        json={"estado": "INACTIVO"},
    )
    assert inactive_person.status_code == 200
    assert inactive_person.json()["vigencia_hasta"] == date.today().isoformat()

    active_people = client.get(
        "/api/catalogos/investigadores",
        headers=admin_headers,
        params={"estado": "ACTIVO"},
    ).json()
    assert person_id not in {item["id"] for item in active_people}
    all_people = client.get(
        "/api/catalogos/investigadores",
        headers=admin_headers,
        params={"estado": "TODOS"},
    ).json()
    assert person_id in {item["id"] for item in all_people}

    disabled_establishment = client.patch(
        f"/api/catalogos/establecimientos/{establishment_id}",
        headers=admin_headers,
        json={"estado": "INACTIVO"},
    )
    assert disabled_establishment.status_code == 200
    invalid_reference = client.post(
        "/api/catalogos/laboratorios",
        headers=admin_headers,
        json={
            "codigo": "LAB-INACTIVE-REFERENCE",
            "nombre": "Laboratorio con referencia inválida",
            "id_establecimiento": establishment_id,
        },
    )
    assert invalid_reference.status_code == 422
    assert invalid_reference.json()["code"] == "REFERENCIA_INVALIDA"


def test_us007_us008_us010_us011_master_integrity_and_history(
    client: TestClient,
    admin_headers: dict[str, str],
    db_connection: Connection,
) -> None:
    insumo = client.post(
        "/api/insumos",
        headers=admin_headers,
        json={
            "id_insumo": "PYTEST-HISTORY-SOLID",
            "nombre_comercial": "Sólido con historia",
            "tipo": "SOLIDO",
        },
    )
    assert insumo.status_code == 201, insumo.text

    incompatible = client.post(
        "/api/presentaciones",
        headers=admin_headers,
        json={
            "id_presentacion": "PYTEST-HISTORY-BAD-UNIT",
            "id_insumo": "PYTEST-HISTORY-SOLID",
            "codigo_presentacion": "P-HISTORY-BAD",
            "capacidad": "100",
            "unidad": "mL",
            "equivalencia_g": "100",
        },
    )
    assert incompatible.status_code == 422

    presentation = client.post(
        "/api/presentaciones",
        headers=admin_headers,
        json={
            "id_presentacion": "PYTEST-HISTORY-PRESENTATION",
            "id_insumo": "PYTEST-HISTORY-SOLID",
            "codigo_bf_sunat": "BF-HISTORY-UNIQUE",
            "codigo_presentacion": "P-HISTORY-UNIQUE",
            "capacidad": "100",
            "unidad": "g",
            "tipo_envase": "Frasco",
            "equivalencia_g": "100",
            "vigencia_desde": "2026-07-01",
        },
    )
    assert presentation.status_code == 201, presentation.text

    duplicate_fiscal_code = client.post(
        "/api/presentaciones",
        headers=admin_headers,
        json={
            "id_presentacion": "PYTEST-HISTORY-DUPLICATE",
            "id_insumo": "PYTEST-HISTORY-SOLID",
            "codigo_bf_sunat": "bf-history-unique",
            "codigo_presentacion": "P-HISTORY-OTHER",
            "capacidad": "50",
            "unidad": "g",
            "equivalencia_g": "50",
        },
    )
    assert duplicate_fiscal_code.status_code == 409

    user_id = db_connection.execute(
        """
        SELECT id_usuario FROM usuario
         WHERE email = 'admin.pytest@ulima.edu.pe'
        """
    ).fetchone()["id_usuario"]
    lot_id = db_connection.execute(
        """
        INSERT INTO lote (id_presentacion, numero_lote, fecha_ingreso)
        VALUES ('PYTEST-HISTORY-PRESENTATION', 'LOT-HISTORY', CURRENT_DATE)
        RETURNING id_lote
        """
    ).fetchone()["id_lote"]
    db_connection.execute(
        """
        INSERT INTO frasco (
          id_frasco, id_lote, peso_neto_inicial_g, peso_neto_actual_g
        ) VALUES ('FRASCO-PYTEST-HISTORY', %s, 100, 100)
        """,
        (lot_id,),
    )
    movement_id = db_connection.execute(
        """
        INSERT INTO kardex (
          id_frasco, tipo_movimiento, motivo, cantidad_g,
          registrado_por, saldo_resultante_g
        ) VALUES (
          'FRASCO-PYTEST-HISTORY', 'SALIDA', 'consumo_laboratorio',
          10, %s, 0
        )
        RETURNING id_movimiento
        """,
        (user_id,),
    ).fetchone()["id_movimiento"]

    no_reason = client.patch(
        "/api/presentaciones/PYTEST-HISTORY-PRESENTATION",
        headers=admin_headers,
        json={"estado": "INACTIVO"},
    )
    assert no_reason.status_code == 422
    assert no_reason.json()["code"] == "MOTIVO_REQUERIDO"

    presentation_reason = "Presentación retirada de nuevas altas"
    disabled_presentation = client.patch(
        "/api/presentaciones/PYTEST-HISTORY-PRESENTATION",
        headers=admin_headers,
        json={
            "estado": "INACTIVO",
            "motivo": presentation_reason,
        },
    )
    assert disabled_presentation.status_code == 200

    with pytest.raises(psycopg.errors.RaiseException):
        db_connection.execute(
            """
            INSERT INTO lote (
              id_presentacion, numero_lote, fecha_ingreso
            ) VALUES (
              'PYTEST-HISTORY-PRESENTATION',
              'LOT-AFTER-INACTIVATION',
              CURRENT_DATE
            )
            """
        )
    with pytest.raises(psycopg.errors.ForeignKeyViolation):
        db_connection.execute(
            """
            DELETE FROM presentacion
             WHERE id_presentacion = 'PYTEST-HISTORY-PRESENTATION'
            """
        )

    visible = db_connection.execute(
        """
        SELECT peso_neto_actual_g
          FROM v_inventario_core
         WHERE id_frasco = 'FRASCO-PYTEST-HISTORY'
        """
    ).fetchone()
    assert visible["peso_neto_actual_g"] == 90
    snapshot = db_connection.execute(
        """
        SELECT saldo_resultante_g
          FROM kardex
         WHERE id_movimiento = %s
        """,
        (movement_id,),
    ).fetchone()
    assert snapshot["saldo_resultante_g"] == 90

    insumo_reason = "Insumo retirado conservando su historial"
    disabled_insumo = client.patch(
        "/api/insumos/PYTEST-HISTORY-SOLID",
        headers=admin_headers,
        json={"estado": "INACTIVO", "motivo": insumo_reason},
    )
    assert disabled_insumo.status_code == 200
    new_presentation_denied = client.post(
        "/api/presentaciones",
        headers=admin_headers,
        json={
            "id_presentacion": "PYTEST-HISTORY-AFTER-INACTIVE",
            "id_insumo": "PYTEST-HISTORY-SOLID",
            "codigo_presentacion": "P-AFTER-INACTIVE",
            "capacidad": "10",
            "unidad": "g",
            "equivalencia_g": "10",
        },
    )
    assert new_presentation_denied.status_code == 409
    assert new_presentation_denied.json()["code"] == "INSUMO_INACTIVO"

    reasons = db_connection.execute(
        """
        SELECT entidad, motivo
          FROM bitacora
         WHERE (
           entidad = 'presentacion'
           AND entidad_id = 'PYTEST-HISTORY-PRESENTATION'
         ) OR (
           entidad = 'insumo'
           AND entidad_id = 'PYTEST-HISTORY-SOLID'
         )
        """
    ).fetchall()
    assert presentation_reason in {row["motivo"] for row in reasons}
    assert insumo_reason in {row["motivo"] for row in reasons}


def test_us009_density_versions_and_operation_snapshots(
    client: TestClient,
    admin_headers: dict[str, str],
    db_connection: Connection,
) -> None:
    fixed = client.post(
        "/api/insumos",
        headers=admin_headers,
        json={
            "id_insumo": "PYTEST-DENSITY-FIXED",
            "nombre_comercial": "Líquido de densidad fija",
            "tipo": "LIQUIDO",
            "densidad_variable": False,
        },
    )
    assert fixed.status_code == 201, fixed.text
    fixed_presentation = client.post(
        "/api/presentaciones",
        headers=admin_headers,
        json={
            "id_presentacion": "PYTEST-DENSITY-FIXED-P",
            "id_insumo": "PYTEST-DENSITY-FIXED",
            "codigo_presentacion": "P-DENSITY-FIXED",
            "capacidad": "100",
            "unidad": "mL",
            "equivalencia_g": "110",
            "densidad": "1.100000",
            "vigencia_desde": "2026-01-01",
        },
    )
    assert fixed_presentation.status_code == 201, fixed_presentation.text

    user_id = db_connection.execute(
        """
        SELECT id_usuario FROM usuario
         WHERE email = 'admin.pytest@ulima.edu.pe'
        """
    ).fetchone()["id_usuario"]
    lot_id = db_connection.execute(
        """
        INSERT INTO lote (id_presentacion, numero_lote, fecha_ingreso)
        VALUES ('PYTEST-DENSITY-FIXED-P', 'LOT-DENSITY-FIXED', CURRENT_DATE)
        RETURNING id_lote
        """
    ).fetchone()["id_lote"]
    db_connection.execute(
        """
        INSERT INTO frasco (
          id_frasco, id_lote, peso_neto_inicial_g, peso_neto_actual_g
        ) VALUES ('FRASCO-DENSITY-FIXED', %s, 110, 110)
        """,
        (lot_id,),
    )
    movement_id = db_connection.execute(
        """
        INSERT INTO kardex (
          id_frasco, tipo_movimiento, motivo, cantidad_g,
          registrado_por, saldo_resultante_g
        ) VALUES (
          'FRASCO-DENSITY-FIXED', 'SALIDA', 'consumo_laboratorio',
          10, %s, 0
        )
        RETURNING id_movimiento
        """,
        (user_id,),
    ).fetchone()["id_movimiento"]

    version = client.post(
        "/api/presentaciones/PYTEST-DENSITY-FIXED-P/densidades",
        headers=admin_headers,
        json={
            "valor": "1.200000",
            "unidad": "g/mL",
            "fuente": "Certificado de análisis vigente",
            "vigencia_desde": date.today().isoformat(),
        },
    )
    assert version.status_code == 201, version.text
    densities = client.get(
        "/api/presentaciones/PYTEST-DENSITY-FIXED-P/densidades",
        headers=admin_headers,
    ).json()
    assert len(densities) == 2
    previous = next(
        item for item in densities if item["valor"] == "1.100000"
    )
    assert previous["vigencia_hasta"] == (
        date.today() - timedelta(days=1)
    ).isoformat()

    historical_snapshot = db_connection.execute(
        """
        SELECT densidad_aplicada
          FROM kardex
         WHERE id_movimiento = %s
        """,
        (movement_id,),
    ).fetchone()["densidad_aplicada"]
    assert historical_snapshot == Decimal("1.100000")

    overlap = client.post(
        "/api/presentaciones/PYTEST-DENSITY-FIXED-P/densidades",
        headers=admin_headers,
        json={
            "valor": "1.250000",
            "unidad": "g/mL",
            "fuente": "Versión solapada",
            "vigencia_desde": date.today().isoformat(),
        },
    )
    assert overlap.status_code == 409
    assert overlap.json()["code"] == "VIGENCIA_SOLAPADA"

    variable = client.post(
        "/api/insumos",
        headers=admin_headers,
        json={
            "id_insumo": "PYTEST-DENS-VAR",
            "nombre_comercial": "Líquido de densidad variable",
            "tipo": "LIQUIDO",
            "densidad_variable": True,
        },
    )
    assert variable.status_code == 201, variable.text
    variable_presentation = client.post(
        "/api/presentaciones",
        headers=admin_headers,
        json={
            "id_presentacion": "PYTEST-DENS-VAR-P",
            "id_insumo": "PYTEST-DENS-VAR",
            "codigo_presentacion": "P-DENSITY-VARIABLE",
            "capacidad": "100",
            "unidad": "mL",
            "equivalencia_g": "100",
            "vigencia_desde": "2026-07-01",
        },
    )
    assert variable_presentation.status_code == 201, variable_presentation.text
    wrong_master = client.post(
        "/api/presentaciones/PYTEST-DENS-VAR-P/densidades",
        headers=admin_headers,
        json={
            "valor": "1.300000",
            "unidad": "g/mL",
            "fuente": "No corresponde a presentación",
            "vigencia_desde": date.today().isoformat(),
        },
    )
    assert wrong_master.status_code == 422

    with pytest.raises(psycopg.errors.RaiseException):
        db_connection.execute(
            """
            INSERT INTO lote (
              id_presentacion, numero_lote, fecha_ingreso
            ) VALUES (
              'PYTEST-DENS-VAR-P',
              'LOT-DENSITY-MISSING',
              CURRENT_DATE
            )
            """
        )
    variable_lot = db_connection.execute(
        """
        INSERT INTO lote (
          id_presentacion, numero_lote, densidad, fecha_ingreso
        ) VALUES (
          'PYTEST-DENS-VAR-P',
          'LOT-DENSITY-PRESENT',
          1.300000,
          CURRENT_DATE
        )
        RETURNING id_lote
        """
    ).fetchone()
    assert variable_lot is not None


def test_us013_search_is_normalized_nested_filtered_and_fast(
    client: TestClient,
    admin_headers: dict[str, str],
) -> None:
    created = client.post(
        "/api/insumos",
        headers=admin_headers,
        json={
            "id_insumo": "PYTEST-SEARCH-ACID",
            "nombre_comercial": "Ácido Único de Búsqueda",
            "tipo": "LIQUIDO",
        },
    )
    assert created.status_code == 201, created.text
    presentation = client.post(
        "/api/presentaciones",
        headers=admin_headers,
        json={
            "id_presentacion": "PYTEST-SEARCH-P",
            "id_insumo": "PYTEST-SEARCH-ACID",
            "codigo_bf_sunat": "BF-SEARCH-2026",
            "codigo_presentacion": "P-SEARCH-2026",
            "capacidad": "100",
            "unidad": "mL",
            "equivalencia_g": "115",
            "densidad": "1.150000",
        },
    )
    assert presentation.status_code == 201, presentation.text

    started = perf_counter()
    by_name = client.get(
        "/api/insumos",
        headers=admin_headers,
        params={"q": "acido unico", "estado": "VIGENTE"},
    )
    elapsed = perf_counter() - started
    assert by_name.status_code == 200
    assert elapsed < 1.0
    found = next(
        item
        for item in by_name.json()["items"]
        if item["id_insumo"] == "PYTEST-SEARCH-ACID"
    )
    assert found["presentaciones"][0]["id_presentacion"] == "PYTEST-SEARCH-P"

    for code in ("bf-search-2026", "p-search-2026", "pytest-search-acid"):
        result = client.get(
            "/api/insumos",
            headers=admin_headers,
            params={"q": code, "estado": "VIGENTE"},
        )
        assert any(
            item["id_insumo"] == "PYTEST-SEARCH-ACID"
            for item in result.json()["items"]
        )

    disabled = client.patch(
        "/api/insumos/PYTEST-SEARCH-ACID",
        headers=admin_headers,
        json={
            "estado": "INACTIVO",
            "motivo": "Validar el filtro de estado",
        },
    )
    assert disabled.status_code == 200
    active = client.get(
        "/api/insumos",
        headers=admin_headers,
        params={"q": "acido unico", "estado": "VIGENTE"},
    ).json()
    assert not any(
        item["id_insumo"] == "PYTEST-SEARCH-ACID"
        for item in active["items"]
    )
    inactive = client.get(
        "/api/insumos",
        headers=admin_headers,
        params={"q": "acido unico", "estado": "INACTIVO"},
    ).json()
    assert any(
        item["id_insumo"] == "PYTEST-SEARCH-ACID"
        for item in inactive["items"]
    )
