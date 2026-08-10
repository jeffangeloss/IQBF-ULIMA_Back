# Épica E4 — Autorizaciones de uso y excepciones

Fecha de corte: 7 de agosto de 2026.

Cuánto puede consumir un titular, de qué y hasta cuándo — y qué pasa cuando la
regla dice que no.

| Ítem | Issue | Estado del Project | Qué cubre |
|---|---:|---|---|
| US-023 | [#23](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/23) | Hecho | Registrar la autorización |
| US-024 | [#24](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/24) | Hecho | Soporte documental versionado |
| US-025 | [#25](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/25) | Hecho | Saldo autorizado derivado del kardex |
| US-026 | [#26](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/26) | En revisión | «Mis autorizaciones» |
| US-027 | [#27](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/27) | Hecho | Validar antes de entregar |
| US-028 | [#28](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/28) | Hecho | Solicitar excepción |
| US-029 | [#29](https://github.com/jeffangeloss/IQBF-ULIMA_Back/issues/29) | Hecho | Aprobar o rechazar |

## Contrato

```
GET    /api/autorizaciones                              listar y filtrar
POST   /api/autorizaciones                              registrar (borrador)
GET    /api/autorizaciones/{id}                         consultar
PATCH  /api/autorizaciones/{id}                         poner en vigor o revocar
GET    /api/autorizaciones/{id}/documentos              versiones del soporte
POST   /api/autorizaciones/{id}/documentos              adjuntar (añade versión)
GET    /api/autorizaciones/{id}/documentos/{v}/contenido descargar
GET    /api/excepciones                                 bandeja
POST   /api/excepciones                                 solicitar
POST   /api/excepciones/{id}/resolver                   aprobar o rechazar
```

Roles: mantener autorizaciones es de `RESPONSABLE_IQBF`; resolver excepciones,
de `APROBADOR` o `RESPONSABLE_IQBF`. **A diferencia de los maestros, E4 no
exige alcance global.**

## Seis decisiones que conviene no deshacer

**1 · El saldo autorizado no se guarda en ninguna columna.** Se recalcula desde
el kardex en cada consulta (`v_autorizacion_saldo`). Un saldo almacenado se
queda rancio en cuanto entra un movimiento por otra vía, y aquí hay tres: la
API, el cargador del censo y las correcciones por SQL. La prueba lo ejercita
**consumiendo por SQL directo** y comprobando que la cifra se mueve igual.

**2 · La cantidad autorizada va siempre en gramos**, además de en la unidad que
tecleó el responsable. Autorizar en volumen se rechaza si el insumo tiene
varias densidades entre sus presentaciones: entonces el número es ambiguo.

**3 · El estado que se enseña se calcula, no se guarda.** `estado_efectivo`
combina el registro con el reloj y el consumo: `BORRADOR`, `VIGENTE`,
`POR_VENCER` (30 días), `AGOTADA`, `VENCIDA`, `REVOCADA`, `FUTURA`. Guardarlo
lo dejaría rancio al día siguiente.

**4 · Sustituir el soporte no borra: añade versión.** En un sistema fiscalizado
el documento que sustentaba una autorización el año pasado tiene que seguir
recuperable. El binario vive en la base a propósito: un oficio son unos cientos
de kB, y un almacén de objetos añade un sitio más donde el respaldo puede
desincronizarse del dato que lo justifica.

**5 · Aprobar una excepción ejecuta el consumo en el mismo acto.** Si el
consumo falla, la aprobación se revierte con él: una excepción aprobada que no
se pudo ejecutar sería una mentira en el expediente. La unicidad la impone la
base — `excepcion.id_movimiento` es `UNIQUE` y solo se llena al ejecutar—, así
que dos aprobaciones simultáneas no pueden producir dos consumos.

**6 · La regla infringida la recalcula el servidor**, no la declara el cliente.
Si quien solicita pudiera declararla, declararía una más benigna que la real.

## El control nace apagado

`establecimiento.exige_autorizacion = FALSE`. Encenderlo con cero
autorizaciones cargadas dejaría al laboratorio sin poder registrar nada, y un
control que obliga a saltárselo el primer día no es un control: es un estorbo
que enseña a ignorarlo. Se enciende con un `UPDATE` cuando las autorizaciones
estén cargadas.

Desde el [PR #82](https://github.com/jeffangeloss/IQBF-ULIMA_Back/pull/82) ese
interruptor **se publica** en `metadata.exige_autorizacion` del catálogo de
establecimientos, y la pantalla avisa cuando está apagado. Sin ese dato, una
interfaz de control callaría que el control está apagado.

## Un hueco encontrado probando

La primera versión resolvía el establecimiento solo por la ubicación del
frasco, así que **un frasco sin ubicación se colaba en silencio**. Ahora cae al
laboratorio del frasco o al de su custodio y, si nada resuelve, aplica la
política de cualquier establecimiento que la exija. Fallar en abierto ahí sería
peor que no tener control, porque nadie se enteraría.

## Evidencia

- `migrations/010_autorizaciones.sql`
- `app/modules/autorizaciones/` — router y esquemas
- `tests/test_autorizaciones_e4.py` — 8 pruebas
- Pantallas: [`specs/e4/README.md`](https://github.com/jeffangeloss/IQBF-ULIMA_Front/blob/jeff/specs/e4/README.md) del frontend
