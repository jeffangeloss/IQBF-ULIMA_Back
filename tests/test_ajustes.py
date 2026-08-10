"""Pruebas de la US-031 — Registro de mermas y ajustes de inventario."""

from decimal import Decimal
import pytest
from fastapi.testclient import TestClient


@pytest.fixture
def escenario_ajuste(db_connection):
    cur = db_connection
    for sentencia in (
        """INSERT INTO insumo (id_insumo, nombre_comercial, tipo, unidad_base)
           VALUES ('AJ-HCL', 'Ácido clorhídrico AJ', 'LIQUIDO', 'g')
           ON CONFLICT DO NOTHING""",
        """INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
                                     capacidad, unidad, equivalencia_g, densidad)
           VALUES ('AJ-HCL-P', 'AJ-HCL', '000666', 1, 'L', 1190, 1.19)
           ON CONFLICT DO NOTHING""",
        """INSERT INTO laboratorio (nombre, codigo) VALUES ('Lab Ajuste', 'LAB-AJ')
           ON CONFLICT DO NOTHING""",
        """INSERT INTO investigador (nombre, tipo, id_laboratorio)
           SELECT 'Custodio Ajuste', 'PERSONA',
                  (SELECT id_laboratorio FROM laboratorio WHERE codigo = 'LAB-AJ')
           ON CONFLICT DO NOTHING""",
        """INSERT INTO lote (id_presentacion, numero_lote, estado)
           VALUES ('AJ-HCL-P', 'LOTE-AJ', 'ACTIVO') ON CONFLICT DO NOTHING""",
    ):
        cur.execute(sentencia)

    lote = cur.execute("SELECT id_lote FROM lote WHERE numero_lote = 'LOTE-AJ'").fetchone()["id_lote"]
    cust = cur.execute("SELECT id_investigador FROM investigador WHERE nombre = 'Custodio Ajuste'").fetchone()["id_investigador"]
    lab = cur.execute("SELECT id_laboratorio FROM laboratorio WHERE codigo = 'LAB-AJ'").fetchone()["id_laboratorio"]

    cur.execute(
        """
        INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_laboratorio_actual,
                            peso_bruto_g, tara_g, peso_neto_inicial_g, peso_neto_actual_g, estado)
        VALUES ('FRASCO-AJ-1', %s, %s, %s, 1500, 310, 1190, 1190, 'EN_USO')
        ON CONFLICT DO NOTHING
        """,
        (lote, cust, lab),
    )
    db_connection.connection.commit()
    return {"cust": cust, "lab": lab}


def test_registrar_merma_exito(client: TestClient, admin_headers: dict, escenario_ajuste: dict):
    res = client.post(
        "/api/movimientos/ajuste",
        headers=admin_headers,
        json={
            "id_frasco": "FRASCO-AJ-1",
            "tipo_movimiento": "SALIDA",
            "motivo": "merma",
            "cantidad_g": "50.0000",
            "observaciones": "Merma por evaporación en manipulación",
        },
    )
    assert res.status_code == 201
    datos = res.json()
    assert datos["id_frasco"] == "FRASCO-AJ-1"
    assert datos["tipo_movimiento"] == "SALIDA"
    assert datos["motivo"] == "merma"
    assert Decimal(datos["saldo_resultante_g"]) == Decimal("1140.0000")

    # Verificar que el Kardex y la ficha reflejen el nuevo saldo
    ficha = client.get("/api/frascos/FRASCO-AJ-1", headers=admin_headers).json()
    assert Decimal(ficha["peso_neto_actual_g"]) == Decimal("1140.0000")
    ult_mov = ficha["movimientos"][0]
    assert ult_mov["tipo_movimiento"] == "SALIDA"
    assert ult_mov["motivo"] == "merma"


def test_merma_incoherente_falla(client: TestClient, admin_headers: dict, escenario_ajuste: dict):
    res = client.post(
        "/api/movimientos/ajuste",
        headers=admin_headers,
        json={
            "id_frasco": "FRASCO-AJ-1",
            "tipo_movimiento": "ENTRADA",
            "motivo": "merma",
            "cantidad_g": "50.0000",
            "observaciones": "Intento inválido de merma como entrada",
        },
    )
    assert res.status_code == 422
