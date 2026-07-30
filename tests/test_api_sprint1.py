from fastapi.testclient import TestClient


def test_health_and_problem_json(client: TestClient) -> None:
    health = client.get("/api/health")
    assert health.status_code == 200
    assert health.json()["database"] == "ok"
    assert health.headers["X-Request-ID"]

    unauthorized = client.get("/api/insumos")
    assert unauthorized.status_code == 401
    assert unauthorized.headers["content-type"].startswith(
        "application/problem+json"
    )
    assert unauthorized.json()["code"] == "NO_AUTENTICADO"

    invalid = client.post(
        "/api/auth/login",
        json={
            "email": "admin.pytest@ulima.edu.pe",
            "password": "Contrasena-Incorrecta",
        },
    )
    assert invalid.status_code == 401
    assert invalid.json()["code"] == "CREDENCIALES_INVALIDAS"

    contract = client.get("/api/openapi.json").json()
    assert contract["servers"][0]["url"] == "http://127.0.0.1:8000"
    insumos_get = contract["paths"]["/api/insumos"]["get"]
    assert (
        "application/problem+json"
        in insumos_get["responses"]["401"]["content"]
    )
    assert (
        insumos_get["responses"]["200"]["headers"]["X-Request-ID"]["schema"][
            "format"
        ]
        == "uuid"
    )


def test_login_me_and_logout(client: TestClient) -> None:
    login = client.post(
        "/api/auth/login",
        json={
            "email": "admin.pytest@ulima.edu.pe",
            "password": "Prueba-Backend-IQBF-2026",
        },
    )
    token = login.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}

    me = client.get("/api/auth/me", headers=headers)
    assert me.status_code == 200
    assert set(me.json()["roles"]) == {
        "ADMIN_TECNICO",
        "RESPONSABLE_IQBF",
    }

    logout = client.post("/api/auth/logout", headers=headers)
    assert logout.status_code == 204
    assert logout.content == b""

    closed = client.get("/api/auth/me", headers=headers)
    assert closed.status_code == 401
    assert closed.json()["code"] == "SESION_INVALIDA"


def test_insumo_presentacion_density_and_audit(
    client: TestClient, admin_headers: dict[str, str]
) -> None:
    created = client.post(
        "/api/insumos",
        headers=admin_headers,
        json={
            "id_insumo": "PYTEST-IQBF-01",
            "nombre_comercial": "Ácido de integración",
            "tipo": "LIQUIDO",
            "unidad_base": "g",
        },
    )
    assert created.status_code == 201, created.text

    presentation = client.post(
        "/api/presentaciones",
        headers=admin_headers,
        json={
            "id_presentacion": "PYTEST-PRES-01",
            "id_insumo": "PYTEST-IQBF-01",
            "codigo_bf_sunat": "009901",
            "codigo_presentacion": "P-PYTEST-01",
            "concentracion": "37%",
            "capacidad": "1000.0000",
            "unidad": "mL",
            "tipo_envase": "Vidrio",
            "equivalencia_g": "1190.0000",
            "densidad": "1.190000",
            "vigencia_desde": "2026-07-27",
        },
    )
    assert presentation.status_code == 201, presentation.text
    body = presentation.json()
    assert body["capacidad"] == "1000.0000"
    assert body["densidad_actual"] == "1.190000"

    search = client.get(
        "/api/insumos",
        params={"q": "acido", "estado": "VIGENTE"},
        headers=admin_headers,
    )
    assert search.status_code == 200
    assert any(
        item["id_insumo"] == "PYTEST-IQBF-01"
        for item in search.json()["items"]
    )
    found = next(
        item
        for item in search.json()["items"]
        if item["id_insumo"] == "PYTEST-IQBF-01"
    )
    assert found["cantidad_presentaciones"] == 1
    assert found["presentaciones"][0]["id_presentacion"] == "PYTEST-PRES-01"

    overlap = client.post(
        "/api/presentaciones/PYTEST-PRES-01/densidades",
        headers=admin_headers,
        json={
            "valor": "1.200000",
            "unidad": "g/mL",
            "fuente": "Certificado que se solapa",
            "vigencia_desde": "2026-07-27",
        },
    )
    assert overlap.status_code == 409
    assert overlap.json()["code"] == "VIGENCIA_SOLAPADA"

    inactivated = client.patch(
        "/api/insumos/PYTEST-IQBF-01",
        headers=admin_headers,
        json={
            "estado": "INACTIVO",
            "motivo": "Fin de la prueba de aceptación",
        },
    )
    assert inactivated.status_code == 200
    assert inactivated.json()["estado"] == "INACTIVO"

    all_states = client.get(
        "/api/insumos",
        params={"q": "acido", "estado": "TODOS"},
        headers=admin_headers,
    )
    assert any(
        item["id_insumo"] == "PYTEST-IQBF-01"
        for item in all_states.json()["items"]
    )


def test_catalog_maintenance(
    client: TestClient, admin_headers: dict[str, str]
) -> None:
    created = client.post(
        "/api/catalogos/establecimientos",
        headers=admin_headers,
        json={
            "codigo": "SEDE-PYTEST",
            "nombre": "Sede de integración",
            "vigencia_desde": "2026-07-27",
        },
    )
    assert created.status_code == 201, created.text
    item_id = created.json()["id"]

    updated = client.patch(
        f"/api/catalogos/establecimientos/{item_id}",
        headers=admin_headers,
        json={"estado": "INACTIVO", "vigencia_hasta": "2026-07-28"},
    )
    assert updated.status_code == 200
    assert updated.json()["estado"] == "INACTIVO"


def test_user_roles_scope_and_revocation(
    client: TestClient, admin_headers: dict[str, str]
) -> None:
    laboratories = client.get(
        "/api/catalogos/laboratorios", headers=admin_headers
    ).json()
    laboratory_id = laboratories[0]["id"]
    establishments = client.get(
        "/api/catalogos/establecimientos", headers=admin_headers
    ).json()
    outside_laboratory = client.post(
        "/api/catalogos/laboratorios",
        headers=admin_headers,
        json={
            "codigo": "LAB-PYTEST-FUERA-ALCANCE",
            "nombre": "Laboratorio fuera de alcance",
            "id_establecimiento": int(establishments[0]["id"]),
        },
    )
    assert outside_laboratory.status_code == 201, outside_laboratory.text

    created = client.post(
        "/api/usuarios",
        headers=admin_headers,
        json={
            "codigo_institucional": "PYTEST-AUDITOR",
            "nombre": "Auditor de alcance",
            "email": "auditor.pytest@ulima.edu.pe",
            "password": "Auditor-Prueba-Segura-2026",
            "roles": ["AUDITOR"],
            "alcance_global": False,
            "laboratorios": [laboratory_id],
        },
    )
    assert created.status_code == 201, created.text
    user_id = created.json()["id_usuario"]

    login = client.post(
        "/api/auth/login",
        json={
            "email": "auditor.pytest@ulima.edu.pe",
            "password": "Auditor-Prueba-Segura-2026",
        },
    )
    assert login.status_code == 200
    auditor_headers = {
        "Authorization": f"Bearer {login.json()['access_token']}"
    }

    scoped_labs = client.get(
        "/api/catalogos/laboratorios", headers=auditor_headers
    )
    assert scoped_labs.status_code == 200
    assert [item["id"] for item in scoped_labs.json()] == [laboratory_id]
    scoped_export = client.get(
        "/api/catalogos/export/laboratorios.csv",
        headers=auditor_headers,
    )
    assert scoped_export.status_code == 200
    assert scoped_labs.json()[0]["nombre"] in scoped_export.text
    assert "Laboratorio fuera de alcance" not in scoped_export.text

    forbidden = client.post(
        "/api/insumos",
        headers=auditor_headers,
        json={
            "id_insumo": "PYTEST-FORBIDDEN",
            "nombre_comercial": "No autorizado",
            "tipo": "SOLIDO",
        },
    )
    assert forbidden.status_code == 403
    assert forbidden.json()["code"] == "PERMISO_DENEGADO"

    disabled = client.patch(
        f"/api/usuarios/{user_id}",
        headers=admin_headers,
        json={"estado": "INACTIVO"},
    )
    assert disabled.status_code == 200
    assert disabled.json()["estado"] == "INACTIVO"

    revoked = client.get("/api/auth/me", headers=auditor_headers)
    assert revoked.status_code == 401
    assert revoked.json()["code"] == "SESION_INVALIDA"
