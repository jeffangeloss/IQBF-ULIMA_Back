"""Aceptación del inventario físico y el consumo — US-05, US-10, US-11, US-12,
US-13, US-20 y US-21.

Cada prueba corresponde a una demo del backlog. Se montan datos mínimos con SQL
directo (no hay API de alta de frascos todavía: el inventario inicial entra por
la carga del censo) y se ejercita la API.
"""

from decimal import Decimal

import pytest
from fastapi.testclient import TestClient


@pytest.fixture
def escenario(db_connection):
    """Dos frascos de ácido clorhídrico, dos custodios y dos laboratorios.

    Reproduce en pequeño lo que carga el censo: un insumo con alias, una
    presentación con densidad, un lote, y frascos con custodio y laboratorio.
    """
    cur = db_connection
    # psycopg3 usa el protocolo extendido: una sentencia por execute.
    for sentencia in (
        """INSERT INTO insumo (id_insumo, nombre_comercial, tipo, unidad_base,
                               densidad_variable)
           VALUES ('TEST-HCL', 'Ácido clorhídrico de prueba', 'LIQUIDO', 'g', FALSE)
           ON CONFLICT DO NOTHING""",
        """INSERT INTO insumo_alias (id_insumo, alias)
           VALUES ('TEST-HCL', 'ZZZ-alias-hcl') ON CONFLICT DO NOTHING""",
        """INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
                                     capacidad, unidad, equivalencia_g, densidad)
           VALUES ('TEST-HCL-P', 'TEST-HCL', '000999', 2.5, 'L', 2950, 1.18)
           ON CONFLICT DO NOTHING""",
        """INSERT INTO laboratorio (nombre, codigo)
           VALUES ('Lab Prueba Alfa', 'LAB-TEST-A'), ('Lab Prueba Beta', 'LAB-TEST-B')
           ON CONFLICT DO NOTHING""",
        """INSERT INTO investigador (nombre, tipo)
           VALUES ('Custodio Alfa', 'PERSONA'), ('Custodio Beta', 'PERSONA')
           ON CONFLICT DO NOTHING""",
        """INSERT INTO lote (id_presentacion, numero_lote, fecha_caducidad, estado)
           VALUES ('TEST-HCL-P', 'LOTE-TEST-1', '2030-01-01', 'ACTIVO')
           ON CONFLICT DO NOTHING""",
    ):
        cur.execute(sentencia)

    lote = cur.execute(
        "SELECT id_lote FROM lote WHERE numero_lote = 'LOTE-TEST-1'"
    ).fetchone()["id_lote"]
    alfa = cur.execute(
        "SELECT id_investigador FROM investigador WHERE nombre = 'Custodio Alfa'"
    ).fetchone()["id_investigador"]
    beta = cur.execute(
        "SELECT id_investigador FROM investigador WHERE nombre = 'Custodio Beta'"
    ).fetchone()["id_investigador"]
    lab_alfa = cur.execute(
        "SELECT id_laboratorio FROM laboratorio WHERE nombre = 'Lab Prueba Alfa'"
    ).fetchone()["id_laboratorio"]
    usuario = cur.execute(
        "SELECT id_usuario FROM usuario ORDER BY id_usuario LIMIT 1"
    ).fetchone()["id_usuario"]

    cur.execute(
        """
        INSERT INTO frasco (id_frasco, id_lote, id_investigador, id_laboratorio_actual,
                            peso_bruto_g, tara_g, peso_neto_actual_g,
                            condicion_envase, estado)
        VALUES
          ('TEST-FRASCO-CON-TARA', %(lote)s, %(alfa)s, %(lab)s,
           4200, 1250, 0, 'Sellado', 'EN_USO'),
          -- Sin tara: su saldo es INDETERMINADO, no cero.
          ('TEST-FRASCO-SIN-TARA', %(lote)s, %(alfa)s, NULL,
           4200, NULL, NULL, 'Abierto', 'EN_USO')
        ON CONFLICT DO NOTHING
        """,
        {"lote": lote, "alfa": alfa, "lab": lab_alfa},
    )
    cur.execute(
        """
        INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
                            cantidad_registrada, unidad_registrada,
                            registrado_por, saldo_resultante_g)
        VALUES ('TEST-FRASCO-CON-TARA', 'ENTRADA', 'censo_inicial', 2950, 2950, 'g',
                %(usuario)s, 0)
        """,
        {"usuario": usuario},
    )
    db_connection.connection.commit()
    return {"alfa": alfa, "beta": beta, "lab_alfa": lab_alfa}


def test_us010_busqueda_encuentra_por_alias_del_insumo(
    client: TestClient, admin_headers, escenario
):
    """«etanol» tiene que encontrar los frascos rotulados «Ethanol».

    Es el caso que llega de viva voz al laboratorio: se pide la sustancia por su
    nombre común, no por el que quiso imprimir el fabricante.
    """
    por_alias = client.get(
        "/api/frascos", headers=admin_headers, params={"q": "ZZZ-alias-hcl"}
    )
    assert por_alias.status_code == 200, por_alias.text
    encontrados = {f["id_frasco"] for f in por_alias.json()["items"]}
    assert "TEST-FRASCO-CON-TARA" in encontrados

    # El mismo frasco por su código interno y por el código SUNAT.
    for termino in ("TEST-FRASCO-CON", "000999"):
        respuesta = client.get(
            "/api/frascos", headers=admin_headers, params={"q": termino}
        )
        assert respuesta.status_code == 200
        assert any(
            f["id_frasco"] == "TEST-FRASCO-CON-TARA"
            for f in respuesta.json()["items"]
        ), termino


def test_us011_filtro_por_laboratorio_y_sin_asignar(
    client: TestClient, admin_headers, escenario
):
    """«Dame lo que hay en tal laboratorio», y también lo que no tiene ninguno."""
    del_lab = client.get(
        "/api/frascos",
        headers=admin_headers,
        params={"laboratorio": escenario["lab_alfa"]},
    )
    assert del_lab.status_code == 200
    ids = {f["id_frasco"] for f in del_lab.json()["items"]}
    assert "TEST-FRASCO-CON-TARA" in ids
    assert "TEST-FRASCO-SIN-TARA" not in ids

    # -1 lista lo que no tiene laboratorio: es una pregunta abierta, no un hueco
    # que se pueda esconder.
    sin_asignar = client.get(
        "/api/frascos", headers=admin_headers, params={"laboratorio": -1}
    )
    assert sin_asignar.status_code == 200
    assert "TEST-FRASCO-SIN-TARA" in {
        f["id_frasco"] for f in sin_asignar.json()["items"]
    }


def test_us005_us020_consumo_descuenta_y_congela_la_densidad(
    client: TestClient, admin_headers, escenario
):
    """El consumo baja el saldo solo, y deja escrito con qué densidad se calculó."""
    antes = client.get("/api/frascos/TEST-FRASCO-CON-TARA", headers=admin_headers)
    assert antes.status_code == 200
    saldo_antes = Decimal(antes.json()["peso_neto_actual_g"])

    respuesta = client.post(
        "/api/movimientos/consumo",
        headers=admin_headers,
        json={
            "id_frasco": "TEST-FRASCO-CON-TARA",
            "cantidad": "250",
            "unidad": "mL",
            "id_investigador": escenario["alfa"],
            "curso": "Química Analítica",
        },
    )
    assert respuesta.status_code == 201, respuesta.text
    cuerpo = respuesta.json()

    # 250 mL x 1.18 g/mL = 295 g. La densidad queda guardada en el movimiento.
    assert Decimal(cuerpo["cantidad_g"]) == Decimal("295.0000")
    assert Decimal(cuerpo["densidad_aplicada"]) == Decimal("1.180000")
    assert cuerpo["unidad_registrada"] == "mL"
    assert Decimal(cuerpo["saldo_despues_g"]) == saldo_antes - Decimal("295")

    despues = client.get("/api/frascos/TEST-FRASCO-CON-TARA", headers=admin_headers)
    assert Decimal(despues.json()["peso_neto_actual_g"]) == saldo_antes - Decimal("295")


def test_us012_no_se_puede_consumir_mas_que_el_saldo(
    client: TestClient, admin_headers, escenario
):
    """Stock negativo bloqueado. Lo rechaza PostgreSQL, no la aplicación."""
    respuesta = client.post(
        "/api/movimientos/consumo",
        headers=admin_headers,
        json={
            "id_frasco": "TEST-FRASCO-CON-TARA",
            "cantidad": "99",
            "unidad": "kg",
            "id_investigador": escenario["alfa"],
        },
    )
    assert respuesta.status_code == 409, respuesta.text
    assert respuesta.json()["code"] == "SALDO_INSUFICIENTE"


def test_us013_no_se_puede_consumir_del_frasco_ajeno(
    client: TestClient, admin_headers, escenario
):
    """El frasco es de Alfa; Beta no puede descontar de él sin una transferencia."""
    respuesta = client.post(
        "/api/movimientos/consumo",
        headers=admin_headers,
        json={
            "id_frasco": "TEST-FRASCO-CON-TARA",
            "cantidad": "10",
            "unidad": "g",
            "id_investigador": escenario["beta"],
        },
    )
    assert respuesta.status_code == 409, respuesta.text
    assert respuesta.json()["code"] == "CUSTODIA_AJENA"


def test_saldo_sin_tara_es_indeterminado_y_no_se_puede_mover(
    client: TestClient, admin_headers, escenario
):
    """Sin tara el neto no se conoce. Y lo que no se conoce no se mueve.

    Es la diferencia entre «no queda nada» y «no sé cuánto queda». La primera es
    una afirmación que acaba en una declaración a SUNAT.
    """
    ficha = client.get("/api/frascos/TEST-FRASCO-SIN-TARA", headers=admin_headers)
    assert ficha.status_code == 200
    assert ficha.json()["saldo_indeterminado"] is True
    assert ficha.json()["peso_neto_actual_g"] is None

    respuesta = client.post(
        "/api/movimientos/consumo",
        headers=admin_headers,
        json={
            "id_frasco": "TEST-FRASCO-SIN-TARA",
            "cantidad": "10",
            "unidad": "g",
            "id_investigador": escenario["alfa"],
        },
    )
    assert respuesta.status_code == 409, respuesta.text
    assert respuesta.json()["code"] == "SALDO_INDETERMINADO"


def test_us021_declaracion_avisa_de_lo_que_no_esta_sumado(
    client: TestClient, admin_headers, escenario
):
    """El total en kg por código SUNAT, y la advertencia de que es un mínimo."""
    respuesta = client.get("/api/declaracion/sunat", headers=admin_headers)
    assert respuesta.status_code == 200, respuesta.text
    datos = respuesta.json()

    linea = next(
        (l for l in datos["lineas"] if l["codigo_bf_sunat"] == "000999"), None
    )
    assert linea is not None, "el código de prueba no aparece en la declaración"
    # Dos frascos del mismo código: uno con saldo y otro indeterminado.
    assert linea["frascos"] == 2
    assert linea["frascos_indeterminados"] == 1
    # Con frascos sin tara, el total NO puede presentarse como completo.
    assert datos["advertencia"] is not None
    assert "mínimo" in datos["advertencia"]


def test_codigo_sunat_numerico_debe_tener_seis_digitos(db_connection):
    """`0000122` y `000122` son dos grupos distintos en el rollup y parten la
    declaración. La regla ataca ese fallo; los códigos con letras no se tocan."""
    with pytest.raises(Exception) as fallo:
        db_connection.execute(
            """
            INSERT INTO presentacion (id_presentacion, id_insumo, codigo_bf_sunat,
                                      capacidad, unidad, equivalencia_g, densidad)
            VALUES ('TEST-CERO', 'TEST-HCL', '0000122', 1, 'L', 1000, 1.18)
            """
        )
    assert "ck_presentacion_sunat_6" in str(fallo.value)
