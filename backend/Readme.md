## Alexandria Backend

API para generar cursos personalizados mediante agentes CrewAI y servirlos vía FastAPI.

### Componentes principales

- **FastAPI** (`src/main.py`): expone la API y registra routers.
- **Routers** (`src/routers`): incluye `health` y `ai/course_generation`.
- **Agentes** (`src/agents`): pipelines de CrewAI para curso, conceptos y preguntas.
- **Esquemas** (`src/schemas`): Pydantic para peticiones/respuestas.
- **Persistencia**: PostgreSQL (ver tablas en `databases/00-schema-tables.sql`).

### Requisitos

- Docker & Docker Compose
- Python 3.11 (para ejecución local sin contenedores)
- Variables de entorno: `GEMINI_API_KEY`, `DATABASE_URL`, etc.

### Ejecución con Docker

```bash
docker compose up -d --build
# API expuesta en http://localhost:8000
```

#### Orden recomendado para el modelo auto-hosteado (Ollama)

El `docker-compose.yml` incluye tres servicios para preparar el modelo `hf.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF:Q4_K_M` dentro de Ollama:

1. `ollama`: levanta el servidor Ollama (`serve`) y mantiene el modelo residente.
2. `ollama-pull`: se conecta al servicio anterior y descarga el modelo requerido (solo se ejecuta una vez o cuando necesites actualizarlo).
3. `ollama-warmup`: realiza una primera petición `generate` para “calentar” el modelo y evitar la latencia del primer request real.

Al usar `docker compose up --build` los servicios se lanzan en ese orden gracias a `depends_on`. Si prefieres hacerlo paso a paso:

```bash
docker compose up -d ollama
docker compose run --rm ollama-pull
docker compose run --rm ollama-warmup
docker compose up -d api db
```

Así garantizas que la API inicie cuando el modelo ya está listo para responder.

### Ejecución local

```bash
python -m venv .venv
.venv\Scripts\activate  # Windows
pip install -r requirements.txt
uvicorn src.main:app --reload
```

### Flujo principal de generación y consulta

```bash
curl -X POST http://localhost:8000/ai/generate-course
 \
  -H "Content-Type: application/json" \
  -d '{ "prompt": "Quiero un curso introductorio de IA generativa enfocado en marketing" }'
```

En PowerShell (Windows) puedes usar:

```powershell
Invoke-RestMethod -Uri "http://localhost:8000/ai/course-generation" `
  -Method Post `
  -Headers @{ "Content-Type" = "application/json" } `
  -Body '{ "prompt": "Quiero un curso introductorio de IA generativa enfocado en marketing" }'
```

Respuesta esperada:

```json
{
  "course_id": 1,
  "status": "ok"
}
```

Con el `course_id` devuelto se puede consultar el payload completo ya persistido:

```bash
curl http://localhost:8000/ai/course-generation/1
```

Respuesta esperada:

```json
{
  "course_id": 1,
  "created_at": "2025-12-11T00:00:00+00:00",
  "course_data": {
    "topic": {...},
    "units": {...},
    "concepts": [...],
    "questions": [...]
  }
}
```

### Endpoints

- `GET /health` – verificación básica.
- `POST /ai/course-generation` – genera la información y la guarda en PostgreSQL devolviendo el `course_id`.
- `GET /ai/generate-course/{course_id}` – recupera la información almacenada previamente.
- `GET/ ai/generate-courselist/{user_id}` – recupera nombre, progreso y ID de cada curso al que un usuario esta inscrito.
- `POST /progress/` – guarda o actualiza el progreso del usuario en un curso (unidad, concepto, pregunta y porcentaje de avance).
- `GET /progress/` – recupera el progreso almacenado de un usuario para un curso específico.
- `POST /users/` – crea un nuevo usuario en la base de datos usando su `google_uid`, correo y nombre.
- `GET /users/{google_uid}` – obtiene la información de un usuario a partir de su `google_uid`.
- `PUT /users/{google_uid}` – actualiza el correo y el nombre de un usuario existente según su `google_uid`.

### Lo que falta (segun plan)

- Autenticacion: hay callback Google (`/google/callback`) que devuelve JWT; falta aplicar middleware/decorador `auth_required`, exponer `/users/me` protegido y asegurar persistencia/lookup de usuarios.
- Pipeline agentico: el orquestador `src/agents/orchestatior_agents.py` ya ejecuta curso->conceptos->preguntas; falta documentarlo como pipeline unico y reutilizarlo en mas endpoints si aplica.
- Persistencia ampliada: las tablas `users`, `courses`, `user_courses`, `progress` existen en el schema, pero los endpoints solo escriben en `courses`; falta asociar `course_id` a `user_id` y crear endpoints para inscripciones/progreso/estado de cursos.

### Estado funcional backend + base de datos

- API activa: `/ai/generate-course` persiste `course_data` en `courses`; `/ai/generate-course/{id}` lee desde `courses`; `/health` para verificacion.
- Auth: `/google/callback` valida `id_token` y emite JWT usando `verify_google_token_and_get_user` y `create_access_token`; decoradores `auth_required`/`role_required` existen en `src/deps/auth.py` pero no estan aplicados en los routers.
- Esquema actual (00-schema_tables.sql): tablas `users`, `courses` (campos `user_id`, `is_public`), `user_courses` (nuevos/completados), `progress` (unidad/concepto/pregunta, porcentaje).
- Campos no contemplados por los endpoints actuales:
  - `courses.user_id` e `is_public` no se setean al generar curso.
  - `user_courses` y `progress` no tienen endpoints para crear/actualizar.
  - No existe `/users/me` para devolver email/nombre/foto/fecha registro del usuario autenticado.
