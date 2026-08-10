"""Pruebas de la US-020 — Transferencia de custodia y laboratorio."""

import pytest
from fastapi.testclient import TestClient


@pytest.fixture
def escenario_tr(db_connection):
    cur = db_connection
    for sentencia in (
        """INSERT INTO insumo (id_insumo, nombre_comercial, tipo, unidad_base)
           VALUES ('TR-HCL', 'Ácido clorhídrico TR', 'LIQUIDO', 'g')
           ON CONFLICT DO NOTHING""",
        """INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
                                     capacidad, unidad, equivalencia_g, densidad)
           VALUES ('TR-HCL-P', 'TR-HCL', '000888', 1, 'L', 1190, 1.19)
           ON CONFLICT DO NOTHING""",
        """INSERT INTO laboratorio (nombre, codigo)
           VALUES ('Lab Origen TR', 'LAB-TR-O'), ('Lab Destino TR', 'LAB-TR-D')
           ON CONFLICT DO NOTHING""",
        """INSERT INTO investigador (nombre, tipo, id_laboratorio)
           SELECT 'Custodio Origen TR', 'PERSONA',
                  (SELECT id_laboratorio FROM laboratorio WHERE codigo = 'LAB-TR-O')
           ON CONFLICT DO NOTHING""",
        """INSERT INTO investigador (nombre, tipo, id_laboratorio)
           SELECT 'Custodio Destino TR', 'PERSONA',
                  (SELECT id_laboratorio FROM laboratorio WHERE codigo = 'LAB-TR-D')
           ON CONFLICT DO NOTHING""",
        """INSERT INTO lote (id_presentacion, numero_lote, estado)
           VALUES ('TR-HCL-P', 'LOTE-TR', 'ACTIVO') ON CONFLICT DO NOTHING""",
    ):
        cur.execute(sentencia)

    lote = cur.execute("SELECT id_lote FROM lote WHERE numero_lote = 'LOTE-TR'").fetchone()["id_lote"]
    orig = cur.execute("SELECT id_investigador FROM investigador WHERE nombre = 'Custodio Origen TR'").fetchone()["id_investigador"]
    dest = cur.execute("SELECT id_investigador FROM investigador WHERE nombre = 'Custodio Destino TR'").fetchone()["id_investigador"]
    lab_orig = cur.execute("SELECT id_laboratorio FROM laboratorio WHERE codigo = 'LAB-TR-O'").fetchone()["id_laboratorio"]
    lab_dest = cur.execute("SELECT id_laboratorio FROM laboratorio WHERE codigo = 'LAB-TR-D'").fetchone()["id_laboratorio"]

    cur.execute(
        """
        INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_laboratorio_actual,
                            peso_bruto_g, tara_g, peso_neto_inicial_g, peso_neto_actual_g, estado)
        VALUES ('FRASCO-TR-1', %s, %s, %s, 1500, 310, 1190, 1190, 'EN_USO')
        ON CONFLICT DO NOTHING
        """,
        (lote, orig, lab_orig),
    )
    db_connection.connection.commit()
    return {
        "orig": orig, "dest": dest,
        "lab_orig": lab_orig, "lab_dest": lab_dest,
    }


def test_transferencia_custodia_exito(client: TestClient, admin_headers: dict, escenario_tr: dict):
    res = client.post(
        "/api/movimientos/transferencia",
        headers=admin_headers,
        json={
            "id_frasco": "FRASCO-TR-1",
            "id_investigador_destino": escenario_tr["dest"],
            "id_laboratorio_destino": escenario_tr["lab_dest"],
            "observaciones": "Transferencia de prueba",
        },
    )
    assert res.status_code == 201
    datos = res.json()
    assert datos["id_frasco"] == "FRASCO-TR-1"
    assert datos["custodio_nuevo"] == "Custodio Destino TR"
    assert datos["laboratorio_nuevo"] == "Lab Destino TR"

    # Verificar que el frasco cambió en la base de datos
    ficha = client.get("/api/frascos/FRASCO-TR-1", headers=admin_headers).json()
    assert ficha["custodio"] == "Custodio Destino TR"
    assert ficha["id_investigador"] == escenario_tr["dest"]
    assert ficha["id_laboratorio"] == escenario_tr["lab_dest"]
    assert ficha["laboratorio"] == "Lab Destino TR"

    # Verificar que el Kardex registró el movimiento
    ult_mov = ficha["movimientos"][0]
    assert ult_mov["tipo_movimiento"] == "TRANSFERENCIA"
    assert ult_mov["cantidad_g"] == "0.0000"


def test_transferencia_sin_destino_falla(client: TestClient, admin_headers: dict, escenario_tr: dict):
    res = client.post(
        "/api/movimientos/transferencia",
        headers=admin_headers,
        json={"id_frasco": "FRASCO-TR-1"},
    )
    assert res.status_code == 422

