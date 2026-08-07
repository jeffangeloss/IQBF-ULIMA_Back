"""Épica E4 — autorizaciones de uso y excepciones (US-023 a US-029)."""

from decimal import Decimal

import pytest
from fastapi.testclient import TestClient


@pytest.fixture
def base_e4(db_connection):
    """Un insumo líquido con un frasco, un titular y un establecimiento."""
    cur = db_connection
    for sentencia in (
        """INSERT INTO insumo (id_insumo, nombre_comercial, tipo, unidad_base)
           VALUES ('E4-ACET', 'Acetona E4', 'LIQUIDO', 'g')
           ON CONFLICT DO NOTHING""",
        """INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
                                     capacidad, unidad, equivalencia_g, densidad)
           VALUES ('E4-ACET-P', 'E4-ACET', '000777', 1, 'L', 790, 0.79)
           ON CONFLICT DO NOTHING""",
        """INSERT INTO laboratorio (nombre, codigo) VALUES ('Lab E4', 'LAB-E4')
           ON CONFLICT DO NOTHING""",
        """INSERT INTO investigador (nombre, tipo, id_laboratorio)
           SELECT 'Titular E4', 'PERSONA',
                  (SELECT id_laboratorio FROM laboratorio WHERE codigo = 'LAB-E4')
           ON CONFLICT DO NOTHING""",
        """INSERT INTO lote (id_presentacion, numero_lote, estado)
           VALUES ('E4-ACET-P', 'LOTE-E4', 'ACTIVO') ON CONFLICT DO NOTHING""",
    ):
        cur.execute(sentencia)

    lote = cur.execute(
        "SELECT id_lote FROM lote WHERE numero_lote = 'LOTE-E4'"
    ).fetchone()["id_lote"]
    titular = cur.execute(
        "SELECT id_investigador FROM investigador WHERE nombre = 'Titular E4'"
    ).fetchone()["id_investigador"]
    est = cur.execute(
        "SELECT id_establecimiento FROM establecimiento ORDER BY 1 LIMIT 1"
    ).fetchone()["id_establecimiento"]

    cur.execute(
        """
        INSERT INTO frasco (id_frasco, id_lote, id_investigador, peso_bruto_g,
                            tara_g, peso_neto_inicial_g, peso_neto_actual_g, estado)
        VALUES ('E4-FRASCO', %s, %s, 1000, 210, 790, 790, 'EN_USO')
        ON CONFLICT DO NOTHING
        """,
        (lote, titular),
    )
    db_connection.connection.commit()
    return {"titular": titular, "establecimiento": est}



def _sin_autorizaciones(db_connection, titular: int) -> None:
    """Deja al titular sin ninguna autorización que ampare el consumo.

    Las pruebas comparten base dentro de la sesión, y una autorización creada
    por otra prueba ampararía el consumo que aquí se quiere ver bloqueado.
    """
    db_connection.execute(
        """
        UPDATE autorizacion SET estado = 'REVOCADA',
               motivo_revocacion = 'Aislamiento de la prueba'
         WHERE id_investigador = %s AND estado <> 'REVOCADA'
        """,
        (titular,),
    )
    db_connection.connection.commit()


def _crear_autorizacion(client, headers, base, cantidad="1", unidad="kg"):
    respuesta = client.post(
        "/api/autorizaciones",
        headers=headers,
        json={
            "codigo": f"AUT-E4-{cantidad}{unidad}",
            "id_investigador": base["titular"],
            "id_insumo": "E4-ACET",
            "id_establecimiento": base["establecimiento"],
            "cantidad": cantidad,
            "unidad": unidad,
        },
    )
    assert respuesta.status_code == 201, respuesta.text
    return respuesta.json()


def test_us023_la_autorizacion_se_guarda_en_la_unidad_canonica(
    client: TestClient, admin_headers, base_e4
):
    """1 kg autorizado son 1000 g. Comparar kilos con gramos pierde una declaración."""
    a = _crear_autorizacion(client, admin_headers, base_e4)
    assert Decimal(a["cantidad_autorizada_g"]) == Decimal("1000.0000")
    # Y se conserva lo que tecleó el responsable, para poder devolvérselo.
    assert Decimal(a["cantidad_registrada"]) == Decimal("1")
    assert a["unidad_registrada"] == "kg"
    assert a["estado_efectivo"] == "BORRADOR"


def test_us023_no_se_autoriza_una_presentacion_de_otro_insumo(
    client: TestClient, admin_headers, base_e4
):
    """Sin esto se autoriza «acetona» y se le cuelga una presentación de nítrico."""
    respuesta = client.post(
        "/api/autorizaciones",
        headers=admin_headers,
        json={
            "codigo": "AUT-E4-INCOHERENTE",
            "id_investigador": base_e4["titular"],
            "id_insumo": "E4-ACET",
            "id_presentacion": "TEST-HCL-P",
            "id_establecimiento": base_e4["establecimiento"],
            "cantidad": "100", "unidad": "g",
        },
    )
    assert respuesta.status_code == 422, respuesta.text


def test_us025_el_saldo_se_deriva_del_kardex(
    client: TestClient, admin_headers, base_e4, db_connection
):
    """El saldo autorizado no se guarda: se recalcula desde las operaciones.

    Una columna de saldo se queda rancia en cuanto entra un movimiento por otra
    vía, y aquí hay varias: la API, el cargador del censo y el SQL directo.
    """
    a = _crear_autorizacion(client, admin_headers, base_e4, "500", "g")
    client.patch(
        f"/api/autorizaciones/{a['id_autorizacion']}",
        headers=admin_headers, json={"estado": "VIGENTE"},
    )
    # Consumo por SQL directo: ni la API ni el trigger tocan ninguna columna
    # de saldo autorizado, y aun así la cifra tiene que moverse.
    db_connection.execute(
        """
        INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
                            id_investigador_origen, registrado_por,
                            saldo_resultante_g)
        VALUES ('E4-FRASCO', 'SALIDA', 'consumo_laboratorio', 120, %s, 1, 0)
        """,
        (base_e4["titular"],),
    )
    db_connection.connection.commit()

    despues = client.get(
        f"/api/autorizaciones/{a['id_autorizacion']}", headers=admin_headers
    ).json()
    assert Decimal(despues["consumido_g"]) == Decimal("120.0000")
    assert Decimal(despues["disponible_g"]) == Decimal("380.0000")


def test_us027_sin_autorizacion_el_consumo_se_bloquea(
    client: TestClient, admin_headers, base_e4, db_connection
):
    """Y el motivo exacto se muestra: no es lo mismo «no tiene» que «se le acabó»."""
    _sin_autorizaciones(db_connection, base_e4["titular"])
    db_connection.execute(
        "UPDATE establecimiento SET exige_autorizacion = TRUE"
    )
    db_connection.connection.commit()
    try:
        respuesta = client.post(
            "/api/movimientos/consumo",
            headers=admin_headers,
            json={
                "id_frasco": "E4-FRASCO", "cantidad": "10", "unidad": "g",
                "id_investigador": base_e4["titular"],
            },
        )
        assert respuesta.status_code == 409, respuesta.text
        assert respuesta.json()["code"] == "AUTORIZACION_INSUFICIENTE"
    finally:
        db_connection.execute(
            "UPDATE establecimiento SET exige_autorizacion = FALSE"
        )
        db_connection.connection.commit()


def test_us028_us029_la_excepcion_no_mueve_stock_hasta_aprobarse(
    client: TestClient, admin_headers, base_e4, db_connection
):
    """Y aprobarla ejecuta el consumo una sola vez."""
    _sin_autorizaciones(db_connection, base_e4["titular"])
    saldo_antes = db_connection.execute(
        "SELECT peso_neto_actual_g FROM frasco WHERE id_frasco = 'E4-FRASCO'"
    ).fetchone()["peso_neto_actual_g"]

    creada = client.post(
        "/api/excepciones",
        headers=admin_headers,
        json={
            "id_frasco": "E4-FRASCO", "id_investigador": base_e4["titular"],
            "cantidad": "7", "unidad": "g",
            "motivo": "Ensayo urgente con autorizacion en tramite",
        },
    )
    assert creada.status_code == 201, creada.text
    exc = creada.json()
    assert exc["estado"] == "PENDIENTE"
    # Tras revocar hay autorizaciones pero ninguna vigente, así que la razón
    # correcta es AUTORIZACION_NO_VIGENTE. El sistema distingue los tres casos
    # y eso importa: no es lo mismo «no tiene» que «se le venció».
    assert exc["regla_infringida"] in (
        "SIN_AUTORIZACION", "AUTORIZACION_NO_VIGENTE",
    )

    # Pendiente no mueve nada.
    sin_mover = db_connection.execute(
        "SELECT peso_neto_actual_g FROM frasco WHERE id_frasco = 'E4-FRASCO'"
    ).fetchone()["peso_neto_actual_g"]
    assert sin_mover == saldo_antes

    # Rechazar exige comentario.
    sin_comentario = client.post(
        f"/api/excepciones/{exc['id_excepcion']}/resolver",
        headers=admin_headers, json={"aprobar": False},
    )
    assert sin_comentario.status_code == 422
    assert sin_comentario.json()["code"] == "MOTIVO_REQUERIDO"

    # Aprobar ejecuta el consumo en el mismo acto.
    aprobada = client.post(
        f"/api/excepciones/{exc['id_excepcion']}/resolver",
        headers=admin_headers,
        json={"aprobar": True, "comentario": "Visto bueno del responsable"},
    )
    assert aprobada.status_code == 200, aprobada.text
    assert aprobada.json()["estado"] == "EJECUTADA"
    assert aprobada.json()["id_movimiento"] is not None

    despues = db_connection.execute(
        "SELECT peso_neto_actual_g FROM frasco WHERE id_frasco = 'E4-FRASCO'"
    ).fetchone()["peso_neto_actual_g"]
    assert despues == saldo_antes - Decimal("7")

    # Una sola vez: la unicidad la impone la base, no este código.
    otra_vez = client.post(
        f"/api/excepciones/{exc['id_excepcion']}/resolver",
        headers=admin_headers, json={"aprobar": True, "comentario": "otra vez"},
    )
    assert otra_vez.status_code == 409


def test_us024_el_soporte_se_versiona_y_no_se_borra(
    client: TestClient, admin_headers, base_e4
):
    """Sustituir crea versión. El documento de antes sigue recuperable."""
    a = _crear_autorizacion(client, admin_headers, base_e4, "250", "g")
    ident = a["id_autorizacion"]

    for contenido in (b"%PDF-1.4 primero", b"%PDF-1.4 segundo"):
        subida = client.post(
            f"/api/autorizaciones/{ident}/documentos",
            headers=admin_headers,
            files={"archivo": ("oficio.pdf", contenido, "application/pdf")},
        )
        assert subida.status_code == 201, subida.text

    versiones = client.get(
        f"/api/autorizaciones/{ident}/documentos", headers=admin_headers
    ).json()
    assert [v["version"] for v in versiones] == [2, 1]
    assert versiones[0]["sha256"] != versiones[1]["sha256"]

    # La versión 1 sigue descargándose: eso es lo que pide el criterio.
    primera = client.get(
        f"/api/autorizaciones/{ident}/documentos/1/contenido",
        headers=admin_headers,
    )
    assert primera.status_code == 200
    assert primera.content == b"%PDF-1.4 primero"


def test_us024_un_ejecutable_no_es_un_oficio(
    client: TestClient, admin_headers, base_e4
):
    a = _crear_autorizacion(client, admin_headers, base_e4, "300", "g")
    respuesta = client.post(
        f"/api/autorizaciones/{a['id_autorizacion']}/documentos",
        headers=admin_headers,
        files={"archivo": ("malo.sh", b"#!/bin/sh\nrm -rf /", "application/x-sh")},
    )
    assert respuesta.status_code == 422
