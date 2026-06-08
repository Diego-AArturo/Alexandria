## Alexandria Backend

API para generar cursos personalizados mediante agentes CrewAI y servirlos via FastAPI.

### Componentes principales

- **FastAPI** (`src/main.py`): expone la API y registra routers.
- **Routers** (`src/routers`): incluye `health` y `ai/course_generation`.
- **Agentes** (`src/agents`): pipelines de CrewAI para curso, conceptos y preguntas.
- **Esquemas** (`src/schemas`): Pydantic para peticiones/respuestas.
- **Persistencia**: PostgreSQL (ver tablas en `database/00-schema_tables.sql`).

### Requisitos

- Docker & Docker Compose
- Python 3.11 (para ejecucion local sin contenedores)
- Variables de entorno: `GEMINI_API_KEY`, `DATABASE_URL`, etc.

### Ejecucion con Docker

```bash
docker compose up -d --build
# API expuesta en http://localhost:8000
```

#### Orden recomendado para el modelo auto-hosteado (Ollama)

El `docker-compose.yml` incluye tres servicios para preparar el modelo `hf.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF:Q4_K_M` dentro de Ollama:

1. `ollama`: levanta el servidor Ollama (`serve`) y mantiene el modelo residente.
2. `ollama-pull`: se conecta al servicio anterior y descarga el modelo requerido (solo se ejecuta una vez o cuando necesites actualizarlo).
3. `ollama-warmup`: realiza una primera peticion `generate` para calentar el modelo y evitar la latencia del primer request real.

Al usar `docker compose up --build` los servicios se lanzan en ese orden gracias a `depends_on`. Si prefieres hacerlo paso a paso:

```bash
docker compose up -d ollama
docker compose run --rm ollama-pull
docker compose run --rm ollama-warmup
docker compose up -d api db
```

Asi garantizas que la API inicie cuando el modelo ya esta listo para responder.

### Ejecucion local

```bash
python -m venv .venv
.venv\Scripts\activate  # Windows
pip install -r requirements.txt
uvicorn src.main:app --reload
```

### Flujo principal de generacion y consulta

1) Disparar la generacion (respuesta inmediata, asincrona):

```bash
curl -X POST http://localhost:8000/ai/courses \
  -H "Content-Type: application/json" \
  -d '{ "prompt": "Quiero un curso introductorio de IA generativa enfocado en marketing" }'
```

Ejemplo de respuesta:

```json
{ "job_id": 1, "status": "queued", "progress": 0 }
```

2) Consultar estado con polling:

```bash
curl http://localhost:8000/ai/courses/status/1
```

Respuestas posibles:

```json
{ "job_id": 1, "status": "processing", "progress": 65 }
```

Cuando termina:

```json
{ "job_id": 1, "status": "completed", "progress": 100, "course_id": 42 }
```

Si hay error:

```json
{ "job_id": 1, "status": "failed", "progress": 100, "error": "mensaje" }
```

3) Obtener el curso generado:

```bash
curl http://localhost:8000/ai/courses/42
```

### Endpoints

- `GET /health` – verificacion basica.
- `POST /ai/courses` – encola la generacion de curso y devuelve `job_id` + estado `queued`.
- `GET /ai/courses/status/{job_id}` – estado del job (queued|processing|completed|failed) y progreso.
- `GET /ai/courses/{course_id}` – recupera la informacion almacenada previamente.
- `GET /ai/generate-courselist/{user_id}` – recupera nombre, progreso e ID de cada curso asociado al usuario.
- `POST /progress/` – guarda o actualiza el progreso del usuario en un curso (unidad, concepto, pregunta y porcentaje de avance).
- `GET /progress/` – recupera el progreso almacenado de un usuario para un curso especifico.
- `POST /users/` – crea un nuevo usuario en la base de datos usando su `google_uid`, correo y nombre.
- `GET /users/{google_uid}` – obtiene la informacion de un usuario a partir de su `google_uid`.
- `PUT /users/{google_uid}` – actualiza el correo y el nombre de un usuario existente segun su `google_uid`.

### Lo que falta (segun plan)

- Autenticacion: hay callback Google (`/google/callback`) que devuelve JWT; falta aplicar middleware/decorador `auth_required`, exponer `/users/me` protegido y asegurar persistencia/lookup de usuarios.

### Estado funcional backend + base de datos

- API activa: `/ai/courses` persiste la generacion via job asincrono; `/ai/courses/{id}` lee desde `courses`; `/health` para verificacion.
- Auth: `/google/callback` valida `id_token` y emite JWT usando `verify_google_token_and_get_user` y `create_access_token`; decoradores `auth_required`/`role_required` existen en `src/deps/auth.py` pero no estan aplicados en los routers.
- Esquema actual (`database/00-schema_tables.sql`): tablas `users`, `courses` (campos `user_id`, `is_public`), `user_courses` (nuevos/completados), `progress` (unidad/concepto/pregunta, porcentaje), `jobs` (estado/progreso/result_id/error).
- Campos no contemplados por los endpoints actuales:
  - `courses.user_id` e `is_public` no se setean al generar curso.
  - `user_courses` y `progress` no tienen endpoints para crear/actualizar.
  - No existe `/users/me` para devolver email/nombre/foto/fecha registro del usuario autenticado.
