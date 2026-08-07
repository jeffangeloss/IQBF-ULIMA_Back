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


def _bruto_lleno(client: TestClient, admin_headers) -> Decimal:
    """Lo que la balanza debe marcar ahora mismo: tara + saldo.

    Se consulta en vez de darlo por sabido: otras pruebas de este mismo módulo
    ya han consumido del frasco, y es justo lo que hace la pantalla.
    """
    f = client.get("/api/frascos/TEST-FRASCO-CON-TARA", headers=admin_headers).json()
    return Decimal(f["tara_g"]) + Decimal(f["peso_neto_actual_g"])


def test_consumo_por_pesada_deriva_el_consumo_de_la_balanza(
    client: TestClient, admin_headers, escenario
):
    """Como registra el laboratorio: se pesa antes y después, la resta es el consumo."""
    lleno = _bruto_lleno(client, admin_headers)
    respuesta = client.post(
        "/api/movimientos/consumo-por-pesada",
        headers=admin_headers,
        json={
            "id_frasco": "TEST-FRASCO-CON-TARA",
            "bruto_antes_g": str(lleno),
            "bruto_despues_g": str(lleno - Decimal("100")),
            "id_investigador": escenario["alfa"],
            "curso": "Q. General",
            "usuario_final": "Mery Damazo (practicante)",
        },
    )
    assert respuesta.status_code == 201, respuesta.text
    cuerpo = respuesta.json()
    assert Decimal(cuerpo["cantidad_g"]) == Decimal("100.0000")
    # Las dos lecturas quedan guardadas: son la evidencia, no una estimación.
    assert Decimal(cuerpo["bruto_antes_g"]) == lleno
    assert Decimal(cuerpo["bruto_despues_g"]) == lleno - Decimal("100")
    assert cuerpo["id_ajuste"] is None
    assert (Decimal(cuerpo["saldo_antes_g"]) - Decimal(cuerpo["saldo_despues_g"])
            == Decimal("100"))


def test_pesada_que_no_cuadra_se_rechaza(
    client: TestClient, admin_headers, escenario
):
    """Si la balanza no marca tara+saldo, salió producto sin registrarse.

    Se rechaza en vez de dejar que esa diferencia se disuelva dentro del
    consumo, que es exactamente lo que pasa hoy en sus libros de Excel: 25 de
    713 pares de pesadas no encadenan y nadie se entera hasta el inventario.
    """
    respuesta = client.post(
        "/api/movimientos/consumo-por-pesada",
        headers=admin_headers,
        json={
            "id_frasco": "TEST-FRASCO-CON-TARA",
            "bruto_antes_g": str(_bruto_lleno(client, admin_headers) - Decimal("200")),
            "bruto_despues_g": "1",
            "id_investigador": escenario["alfa"],
        },
    )
    assert respuesta.status_code == 409, respuesta.text
    assert respuesta.json()["code"] == "PESADA_NO_CUADRA"
    assert "sin registrar" in respuesta.json()["detail"]


def test_la_diferencia_se_regulariza_como_movimiento_propio(
    client: TestClient, admin_headers, escenario, db_connection
):
    """Con `ajustar_diferencia` entran DOS movimientos, no uno inflado.

    Quien audite verá el ajuste y el consumo por separado, que es lo que de
    verdad ocurrió. Meter los 200 g perdidos dentro del consumo diría que un
    alumno usó 300 g cuando usó 100.
    """
    lleno = _bruto_lleno(client, admin_headers)
    respuesta = client.post(
        "/api/movimientos/consumo-por-pesada",
        headers=admin_headers,
        json={
            "id_frasco": "TEST-FRASCO-CON-TARA",
            "bruto_antes_g": str(lleno - Decimal("200")),
            "bruto_despues_g": str(lleno - Decimal("300")),
            "id_investigador": escenario["alfa"],
            "ajustar_diferencia": True,
        },
    )
    assert respuesta.status_code == 201, respuesta.text
    cuerpo = respuesta.json()
    assert cuerpo["id_ajuste"] is not None
    assert Decimal(cuerpo["ajuste_g"]) == Decimal("-200.0000")
    # El consumo declarado es solo lo que se sirvió: 100 g, no 300.
    assert Decimal(cuerpo["cantidad_g"]) == Decimal("100.0000")

    fila = db_connection.execute(
        "SELECT motivo, cantidad_g FROM kardex WHERE id_movimiento = %s",
        (cuerpo["id_ajuste"],),
    ).fetchone()
    assert fila["motivo"] == "ajuste_inventario"
    assert fila["cantidad_g"] == Decimal("200.0000")


def test_inventario_confirma_el_saldo_sin_moverlo(
    client: TestClient, admin_headers, escenario
):
    """Las filas «INV.» de sus libros: se pesa, se confirma, no se consume."""
    antes = client.get("/api/frascos/TEST-FRASCO-CON-TARA", headers=admin_headers).json()
    lleno = Decimal(antes["tara_g"]) + Decimal(antes["peso_neto_actual_g"])
    respuesta = client.post(
        "/api/movimientos/inventario",
        headers=admin_headers,
        json={
            "id_frasco": "TEST-FRASCO-CON-TARA",
            "bruto_antes_g": str(lleno),
            "bruto_despues_g": str(lleno),
            "id_investigador": escenario["alfa"],
        },
    )
    assert respuesta.status_code == 201, respuesta.text
    cuerpo = respuesta.json()
    assert cuerpo["motivo"] == "inventario"
    assert Decimal(cuerpo["cantidad_g"]) == Decimal("0")
    # El saldo queda exactamente donde estaba: se confirma, no se mueve.
    assert (Decimal(cuerpo["saldo_resultante_g"])
            == Decimal(antes["peso_neto_actual_g"]))


def test_cantidad_desmesurada_da_422_no_500(
    client: TestClient, admin_headers, escenario
):
    """Un pegado mal hecho no puede acabar en «Error de base de datos».

    `quantize` lanzaba InvalidOperation con números enormes y salía como HTTP
    500 diciendo que había fallado la base — que ni se toca. El operario tiene
    que leer qué hizo mal, no un error de servidor.
    """
    for cantidad in ("99999999999999999999", "1e30"):
        respuesta = client.post(
            "/api/movimientos/consumo",
            headers=admin_headers,
            json={
                "id_frasco": "TEST-FRASCO-CON-TARA",
                "cantidad": cantidad,
                "unidad": "kg",
                "id_investigador": escenario["alfa"],
            },
        )
        assert respuesta.status_code == 422, f"{cantidad}: {respuesta.text}"
        assert respuesta.json()["code"] == "VALIDACION"


def test_un_insert_multifila_no_puede_dejar_saldo_negativo(
    db_connection, escenario
):
    """El BEFORE ROW lee un saldo rancio dentro de una misma sentencia.

    Dos SALIDAS de 3000 g en un solo INSERT sobre un frasco de 2950 g se
    aceptaban enteras y el kardex quedaba sumando negativo. Ningún endpoint lo
    dispara, pero la corrección de datos por SQL directo sí — y es justo donde
    más falta hace la red.
    """
    import psycopg
    saldo = db_connection.execute(
        "SELECT peso_neto_actual_g FROM frasco WHERE id_frasco = 'TEST-FRASCO-CON-TARA'"
    ).fetchone()["peso_neto_actual_g"]
    # Cada fila cabe por separado; juntas no. Ese es el caso que se colaba:
    # las dos leían el mismo saldo antes de que ninguna lo hubiera aplicado.
    cada_una = (saldo * Decimal("0.6")).quantize(Decimal("0.0001"))
    with pytest.raises(psycopg.errors.CheckViolation):
        db_connection.execute(
            """
            INSERT INTO kardex (id_frasco, tipo_movimiento, motivo, cantidad_g,
                                registrado_por, saldo_resultante_g)
            VALUES ('TEST-FRASCO-CON-TARA', 'SALIDA', 'consumo_laboratorio',
                    %(c)s, 1, 0),
                   ('TEST-FRASCO-CON-TARA', 'SALIDA', 'consumo_laboratorio',
                    %(c)s, 1, 0)
            """,
            {"c": cada_una},
        )


def test_no_se_dan_de_alta_frascos_sobre_una_presentacion_inactiva(
    db_connection, escenario
):
    """US-011: inactivar impide nuevas altas también por SQL.

    El cargador del censo inserta frascos por SQL directo, que es la vía real
    de alta de este proyecto: si el guardián solo vive en la API, no guarda
    nada.
    """
    import psycopg
    # El cambio de estado de un maestro exige motivo (US-008/US-011).
    db_connection.execute(
        "SELECT set_config('iqbf.change_reason', 'Prueba de bloqueo de altas', false)"
    )
    db_connection.execute(
        "UPDATE presentacion SET estado = 'INACTIVO' WHERE id_presentacion = 'TEST-HCL-P'"
    )
    lote = db_connection.execute(
        "SELECT id_lote FROM lote WHERE numero_lote = 'LOTE-TEST-1'"
    ).fetchone()["id_lote"]
    with pytest.raises(psycopg.errors.CheckViolation):
        db_connection.execute(
            """
            INSERT INTO frasco (id_frasco, id_lote, peso_bruto_g, tara_g,
                                peso_neto_actual_g, estado)
            VALUES ('TEST-ALTA-BLOQUEADA', %s, 100, 10, 0, 'EN_USO')
            """,
            (lote,),
        )
    db_connection.execute(
        "SELECT set_config('iqbf.change_reason', 'Fin de la prueba', false)"
    )
    db_connection.execute(
        "UPDATE presentacion SET estado = 'VIGENTE' WHERE id_presentacion = 'TEST-HCL-P'"
    )


def test_una_ubicacion_en_uso_no_se_puede_borrar(db_connection, escenario):
    """US-004: el FK era ON DELETE SET NULL y borraba el vínculo en silencio."""
    import psycopg
    db_connection.execute(
        """
        INSERT INTO ubicacion (codigo, nombre, id_establecimiento)
        SELECT 'UBI-BORRAR', 'Ubicación de prueba', id_establecimiento
          FROM establecimiento ORDER BY id_establecimiento LIMIT 1
        ON CONFLICT DO NOTHING
        """
    )
    db_connection.execute(
        """
        UPDATE frasco SET id_ubicacion =
          (SELECT id_ubicacion FROM ubicacion WHERE codigo = 'UBI-BORRAR')
         WHERE id_frasco = 'TEST-FRASCO-CON-TARA'
        """
    )
    with pytest.raises(psycopg.errors.ForeignKeyViolation):
        db_connection.execute(
            "DELETE FROM ubicacion WHERE codigo = 'UBI-BORRAR'"
        )
