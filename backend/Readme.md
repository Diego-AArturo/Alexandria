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
docker compose up --build
# API expuesta en http://localhost:8000
```

### Ejecución local
```bash
python -m venv .venv
.venv\Scripts\activate  # Windows
pip install -r requirements.txt
uvicorn src.main:app --reload
```

### Endpoints
- `GET /health` – verificación básica.
- `POST /ai/course-generation` – genera curso, conceptos y preguntas almacenables en PostgreSQL.
