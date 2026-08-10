# Diagramas del sistema IQBF

`IQBF_Diagramas.drawio` — ocho páginas, se abre en [app.diagrams.net](https://app.diagrams.net)
o con la extensión de Draw.io en VS Code.

## Qué hay dentro

| Página | Qué muestra | Habilitador / historias |
|---|---|---|
| **Caso de Uso de Negocio** | Los 6 roles y las 8 capacidades del sistema | EN-001 |
| **Gestionar Seguridad** | Sesión, cuentas, roles y alcance | US-001 · US-002 · US-003 · US-006 |
| **Gestionar Maestros** | Insumos, presentaciones, densidades y catálogos | US-004 · US-005 · US-007 a US-013 |
| **Gestionar Inventario y Consumo** | Búsqueda, ficha, consumo y declaración | US-018 · US-019 · US-030 · US-033 · US-034 · US-036 · US-050 |
| **Gestionar Autorizaciones** | Épica E4 completa | US-023 a US-029 |
| **Componentes y Despliegue** | Vercel · Render · PostgreSQL · pipeline del censo | EN-005 |
| **DiagramaBD** | 25 tablas con sus claves y las columnas que deciden una regla | EN-002 · EN-006 |
| **Secuencia — Consumo por doble pesada** | El flujo real, con las barreras que impone PostgreSQL | EN-006 |

## Se generan, no se dibujan

    python3 specs/diagramas/generar_diagramas.py

**Un diagrama dibujado a mano envejece en silencio.** El contenido de estos sale
de lo que el sistema *es* —las 41 rutas del OpenAPI, las 25 tablas del esquema,
los 6 roles de `permisos.ts`, los códigos de error de las migraciones—, así que
regenerarlo es la forma de que siga siendo cierto. Si cambias el sistema, cambia
`generar_diagramas.py` y vuelve a ejecutarlo.

Los diagramas se verificaron contra el código con revisores independientes: cada
página se contrastó con las rutas, el esquema y los disparadores reales, y cada
reproche pasó por un refutador antes de aceptarse.

## Convenciones

Se sigue el vocabulario de los diagramas del curso (PideYa, Patronika), para que
no haya que aprender un dialecto nuevo:

- Actores `shape=umlActor`, casos de uso en elipse, frontera del sistema `umlFrame`
- Tablas `shape=table` con aristas `entityRelationEdgeStyle`
- Componentes `shape=module`, base de datos `mxgraph.flowchart.database`
- Secuencia con `umlLifeline`
- Paleta ámbar `#fff2cc` / `#d6b656`; en rojo, solo lo que es un riesgo

## Lo que los diagramas dicen y conviene no perder

**El rol y el alcance son cosas distintas.** El alcance global no otorga roles:
el servidor lo exige *además* del rol, nunca en su lugar.

**Las barreras del consumo viven en PostgreSQL, no en la API.** Un `INSERT` a
mano con `psql` choca contra la misma regla. Es la única forma de que valgan en
un sistema fiscalizado.

**El kardex es inmutable y el saldo solo se mueve por él.** Corregir es añadir
un movimiento de reversa, nunca editar el histórico.

**Un saldo `NULL` es «indeterminado», no cero** — y la base impide moverlo.
