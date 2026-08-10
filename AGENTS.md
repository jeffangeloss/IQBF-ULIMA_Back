# Reglas de Trabajo y Arquitectura del Proyecto IQBF
*(Alineadas con Ingeniería de Software II - Prof. Hernán Alejandro Quintana Cruz, Universidad de Lima)*

## 1. Principios de Diseño SOLID y Limpieza de Código
- **Single Responsibility (SRP):** Mantener separación estricta entre Routers/Controles HTTP, Servicios de Dominio, Repositorios de Persistencia y Modelos Pydantic/Typescript.
- **Open/Closed (OCP):** Diseñar endpoints y modelos abiertos a extensión (mediante herencia de esquemas o conectores) pero cerrados a modificación destructiva.
- **Dependency Inversion (DIP):** Las capas de negocio (servicios/routers) dependen de abstracciones (interfaces de conexión, `Depends(get_connection)`, repositorios), no de consultas acopladas directamente en la vista.
- **Evitar Code Smells:** Refactorizar métodos largos, clases masivas o duplicación de lógica mediante funciones puras y reutilizables.

## 2. Aseguramiento de la Calidad (SQA) y Pruebas
- **Pruebas Unitarias e Integración Obligatorias:** Ningún cambio de negocio se da por terminado sin su correspondiente prueba en `pytest` (backend) y verificación de tipado `npx tsc --noEmit` (frontend).
- **Aislamiento con Test Doubles / Fixtures:** Utilizar fixtures aisladas en base de datos de pruebas (`db_connection`, `admin_headers`) sin afectar datos de producción.

## 3. Actualización Obligatoria del Backlog con Evidencias en GitHub
- Cada avance o User Story completada DEBE ser actualizada inmediatamente en `IQBF-ULIMA_Front/BACKLOG_COMPLETO_IQBF.md` y sincronizada con [GitHub Projects #2](https://github.com/users/jeffangeloss/projects/2/views/1?groupedBy%5BcolumnId%5D=372729508).
- La entrada debe incluir: ID de US, estado (`Hecho`), commits en backend (`IQBF-ULIMA_Back`) y frontend (`IQBF-ULIMA_Front`), endpoints FastAPI, componentes React UI y resultado empírico de pruebas.

## 4. Integración Continua (CI/CD) y Sincronización Remota Git
- **Backend (`IQBF-ULIMA_Back`)**: Commitear y ejecutar `git push origin agent/s0-architecture`.
- **Frontend (`IQBF-ULIMA_Front`)**: Commitear y ejecutar `git push origin jeff`.
- Preservar trazabilidad e inmutabilidad en el historial de Git y en la bitácora de auditoría (`iqbf.kardex`).
