verifica si los certificad

# Alexandria Project Report

## 1. Executive Overview

Alexandria is an AI-powered microlearning product that lets a learner request a personalized course in natural language, generates a structured learning path, and delivers the course through a Flutter mobile experience.

The project is composed of three main layers:

- Mobile app: a Flutter client for authentication, course creation, learning path navigation, lesson delivery, question interaction, progress tracking, localization, and notifications.
- Backend API: a FastAPI service that handles authentication, user records, course generation jobs, course retrieval, progress storage, and health checks.
- AI generation pipeline: a CrewAI-based orchestration layer that converts learner prompts into a course topic, units, concepts, and interactive questions.

The system is designed around asynchronous course generation. When a learner requests a course, the backend immediately creates a job and returns a job ID. The mobile app polls job status while the backend generates content. The backend saves partial course data as each unit is completed, allowing the app to open a partially generated course while generation continues.

The current project is a working product foundation rather than a final production release. Core flows exist, including login/register, Google sign-in integration, queued course generation, partial results, course playback, progress persistence, bilingual localization, and local notification hooks. Remaining work is mostly around production hardening: auth coverage, environment management, test coverage, schema migrations, security settings, API consistency, observability, deployment workflow, and cleanup of prototype assets.

## 2. Product Workflow

### 2.1 User Entry and Authentication

The user starts in the Flutter `AuthScreen`. They can create a local email/password account, sign in with email/password, or sign in through Google.

After authentication:

- The backend issues a JWT access token.
- The app fetches the user record by email.
- The app stores the session in the in-memory `Session` holder.
- The app applies the user's preferred language when available.
- The user is routed into the main home shell.

Relevant files:

- `movil_app/alexandria_movil/lib/screens/auth_screen.dart`
- `movil_app/alexandria_movil/lib/data/auth_service.dart`
- `movil_app/alexandria_movil/lib/data/users_service.dart`
- `movil_app/alexandria_movil/lib/data/session.dart`
- `backend/src/routers/auth.py`
- `backend/src/routers/users.py`
- `backend/src/deps/auth.py`

### 2.2 Main Mobile Navigation

After sign-in, the mobile app uses `HomeShell` as the primary navigation frame. The app is organized around the learner's main jobs:

- View existing courses.
- Create a new AI-generated course.
- Review and manage the user profile.

Relevant files:

- `movil_app/alexandria_movil/lib/components/home_shell.dart`
- `movil_app/alexandria_movil/lib/screens/course_home_screen.dart`
- `movil_app/alexandria_movil/lib/screens/craft_course_screen.dart`
- `movil_app/alexandria_movil/lib/screens/profile_screen.dart`

### 2.3 Course Creation

The learner writes a prompt describing what they want to learn. The app sends the prompt and the current user ID to the backend.

Backend behavior:

1. `POST /ai/courses` creates a row in the `jobs` table with status `queued`.
2. The backend schedules a background task.
3. The background task updates the job to `processing`.
4. The AI pipeline generates course structure first.
5. For each unit, the backend generates concepts and questions.
6. After each unit, the backend saves the latest course payload to the `courses` table and updates the job to `partial`.
7. When all units complete, the job is marked `completed`.
8. If generation fails, the job is marked `failed` with an error message.

Mobile behavior:

1. The app displays a queued/generating state.
2. The app polls `GET /ai/courses/status/{job_id}` every two seconds.
3. If the backend returns `partial` and a `course_id`, the app can open the partial course.
4. If the backend returns `completed`, the app fetches the final course and navigates to the course unit screen.
5. On completion or error, the notification service can notify the user.

Relevant files:

- `backend/src/routers/ai/course_generation.py`
- `backend/src/agents/orchestatior_agents.py`
- `movil_app/alexandria_movil/lib/data/course_generation_service.dart`
- `movil_app/alexandria_movil/lib/screens/craft_course_screen.dart`
- `movil_app/alexandria_movil/lib/data/notification_service.dart`

### 2.4 Learning Path

Generated courses are shown as a unit path. The course unit screen displays:

- Course title.
- Unit completion count.
- Overall progress percentage.
- Unit cards with status: locked, current, or completed.
- A banner when remaining course content is still being generated.

When a partial course is open, the screen polls the course record periodically to refresh generated content.

Relevant files:

- `movil_app/alexandria_movil/lib/screens/course_units_screen.dart`
- `movil_app/alexandria_movil/lib/components/unit_card.dart`
- `movil_app/alexandria_movil/lib/data/course_generation_service.dart`

### 2.5 Lesson Experience

Each unit is rendered as a linear microlearning flow. The user moves through concept cards and questions.

Supported question types:

- Multiple choice.
- True/false.
- Fill in the blank.

The lesson screen tracks:

- Current concept and question position.
- Correct and incorrect answers.
- Retry questions for incorrect responses.
- Local lesson completion state.
- Persisted course progress through the backend.

Relevant files:

- `movil_app/alexandria_movil/lib/screens/course_screen.dart`
- `movil_app/alexandria_movil/lib/components/concept_card.dart`
- `movil_app/alexandria_movil/lib/components/questions_components/mul_choice_card.dart`
- `movil_app/alexandria_movil/lib/components/questions_components/true_false_card.dart`
- `movil_app/alexandria_movil/lib/components/questions_components/fill_blank_card.dart`
- `movil_app/alexandria_movil/lib/data/progress_service.dart`
- `backend/src/routers/progress.py`

### 2.6 Progress Persistence

The app saves progress to the backend using `POST /progress/`. The backend either inserts a new progress row or updates the existing row for the same user/course pair.

Stored progress includes:

- Current unit.
- Current concept.
- Current question.
- Completion percentage.

The learning path screen fetches progress with `GET /progress/?user_id=...&course_id=...` to unlock completed and current units.

Relevant files:

- `backend/src/routers/progress.py`
- `backend/src/schemas/course_progression.py`
- `backend/src/models/tables.py`
- `movil_app/alexandria_movil/lib/data/progress_service.dart`

## 3. Component Descriptions

### 3.1 Flutter Mobile App

Path: `movil_app/alexandria_movil`

The mobile app is a Flutter application using Material UI, generated localization files, HTTP service classes, and platform-specific shells for Android, iOS, web, macOS, Linux, and Windows.

Primary responsibilities:

- Authenticate users.
- Hold session information.
- Create AI-generated courses.
- Poll backend jobs.
- Render course units.
- Render concept and question lessons.
- Save and restore progress.
- Show local notifications.
- Support English and Spanish localization.

Important folders:

- `lib/screens`: top-level screens and user flows.
- `lib/components`: reusable visual components.
- `lib/components/questions_components`: question interaction widgets.
- `lib/data`: API client and domain service classes.
- `lib/core`: colors and text styles.
- `lib/l10n`: localization ARB files and generated localization classes.
- `assets`: icon and splash assets.
- `new_design`, `new_design_2`, `new_design_3`: prototype/design reference folders.

Key dependencies:

- `http`: backend API calls.
- `google_sign_in`: Google authentication.
- `flutter_local_notifications`: local notifications.
- `flutter_localizations` and `intl`: localization.
- `flutter_native_splash` and `flutter_launcher_icons`: app branding assets.

### 3.2 Backend API

Path: `backend`

The backend is a FastAPI application using SQLAlchemy Core tables, PostgreSQL, and Pydantic schemas.

Primary responsibilities:

- Register API routers.
- Handle CORS.
- Manage user authentication.
- Persist users, jobs, generated courses, and progress.
- Run AI generation in background tasks.
- Provide course status and retrieval endpoints.

Important folders:

- `src/main.py`: application factory and router registration.
- `src/routers`: route handlers for auth, users, progress, health, and AI generation.
- `src/schemas`: Pydantic request and response models.
- `src/models`: SQLAlchemy database connection and table definitions.
- `src/agents`: CrewAI pipeline and supporting LLM utilities.
- `database`: PostgreSQL schema.

Key dependencies:

- `fastapi` and `uvicorn`: API runtime.
- `sqlalchemy` and `psycopg2`: database access.
- `pydantic`: request/response validation.
- `crewai`: agent orchestration.
- `openai`/CrewAI LLM integration: AI content generation.
- `bcrypt` and `PyJWT`: password hashing and token handling.
- `google-auth`: Google token verification.
- `loguru`: logging.

### 3.3 AI Generation Pipeline

Path: `backend/src/agents`

The AI layer is organized as multiple CrewAI crews with a lightweight orchestrator.

Course structure generation:

- Extracts learner intent, level, language, and teachability.
- Produces a course topic and 7 to 10 learning units.
- Uses the learner prompt as the starting input.

Concept generation:

- Runs per unit.
- Produces 10 to 12 short microlearning concepts per unit.
- Keeps content conceptual and mobile-friendly.

Question generation:

- Runs per unit.
- Produces multiple choice, true/false, and fill-in-blank questions.
- Includes correct and incorrect explanations.
- Runs an additional fill-in-blank cleanup pipeline to review, deduplicate, and reintegrate fill-in-blank questions.

Orchestration:

- `get_course_structure()` generates the topic and units.
- `get_unit_content()` generates concepts and questions for one unit.
- `get_course_generation_crews()` runs the full sequence in memory.
- The active API path uses progressive per-unit generation so partial results can be persisted.

Relevant files:

- `backend/src/agents/course_generation.py`
- `backend/src/agents/concept_generation.py`
- `backend/src/agents/question_generation.py`
- `backend/src/agents/fill_blank_extraction.py`
- `backend/src/agents/fill_blank_reviewer.py`
- `backend/src/agents/fill_blank_reintegration.py`
- `backend/src/agents/orchestatior_agents.py`
- `backend/src/agents/llm_config.py`
- `backend/src/agents/execution_limits.py`

### 3.4 Database

Path: `backend/database/00-schema_tables.sql`

The database is PostgreSQL with pgvector enabled. The schema includes both application tables and a `meta` schema for embeddings/migrations.

Application tables:

- `users`: user identity, email, name, profile photo, language, Google UID, and password hash.
- `courses`: generated course JSON payloads, owner user ID, public flag, and creation timestamp.
- `jobs`: async job type, status, progress, result course ID, timestamps, and error.
- `progress`: learner progress through a course.
- `user_courses`: association table intended for course enrollment/completion state.

Meta tables:

- `meta.embeddings`: pgvector-ready embedding storage.
- `meta.migrations`: migration tracking.

Current persistence model:

- Generated course content is stored as JSONB in `courses.course_data`.
- Job state is stored in `jobs`.
- User course progress is stored in `progress`.
- User/course enrollment state exists in schema but is not currently central to the active flows.

### 3.5 DevOps and Runtime

Backend Docker support exists through `backend/docker-compose.yml`.

Services:

- `api`: FastAPI app exposed on port 8000.
- `db`: PostgreSQL/pgvector exposed on port 5432.
- Optional Ollama services are present but commented out.

The compose file initializes the database using `database/00-schema_tables.sql`.

Runtime environment:

- `DATABASE_URL` controls backend database connection.
- `OPENAI_API_KEY` is required by the current LLM configuration.
- `MODEL` can override the default model.
- `JWT_SECRET` should be provided in production.
- `ACCESS_EXPIRE` can tune JWT expiration.

## 4. API Surface

### 4.1 Health

- `GET /health`

Purpose: simple backend health check.

### 4.2 Authentication

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/google/callback`

Purpose: create local users, authenticate local users, authenticate Google users, and issue JWTs.

### 4.3 Users

- `POST /users/`
- `GET /users/by-email`
- `PUT /users/profile`
- `GET /users/{google_uid}`
- `PUT /users/{google_uid}`

Purpose: create users, look users up, and update profile fields. `PUT /users/profile` uses bearer token auth.

### 4.4 Course Generation

- `POST /ai/courses`
- `GET /ai/courses/status/{job_id}`
- `GET /ai/courses/{course_id}`
- `GET /ai/generate-courselist/{user_id}`

Purpose: queue course generation, poll status, fetch generated course data, and list a user's courses with progress.

### 4.5 Progress

- `POST /progress/`
- `GET /progress/`

Purpose: save/update progress and retrieve progress for a user/course pair.

## 5. Data Flow

### 5.1 Course Generation Data Flow

1. Flutter captures learner prompt in `CraftCourseScreen`.
2. `CourseGenerationService.generateCourse()` posts to `/ai/courses`.
3. FastAPI inserts a `jobs` row.
4. FastAPI background task starts the generation pipeline.
5. Course crew extracts topic, level, language, teachability, and units.
6. For each unit:
   - Concept crew generates microlearning concepts.
   - Question crew generates assessment questions.
   - Fill-in-blank pipeline cleans up applicable questions.
   - Backend writes the accumulated course payload into `courses`.
   - Backend updates `jobs.progress` and `jobs.status`.
7. Flutter polls status.
8. Flutter fetches `courses.course_data` by course ID.
9. Flutter maps JSON into unit cards, concepts, and question widgets.

### 5.2 Progress Data Flow

1. User advances through concepts and questions in `CourseScreen`.
2. The screen calculates trackable progress for the current unit and course.
3. `ProgressService.saveProgress()` posts progress to the backend.
4. The backend upserts by `user_id` and `course_id`.
5. `CourseUnitsScreen` fetches progress when opened or when returning from a lesson.
6. Unit status is recalculated on the client.

### 5.3 Authentication Data Flow

Local auth:

1. User submits email/password.
2. Backend verifies password hash.
3. Backend signs JWT with user email as `sub`.
4. Flutter fetches user by email and stores session data.

Google auth:

1. Flutter gets Google ID token.
2. Backend verifies the ID token with Google.
3. Backend creates or updates the user row.
4. Backend signs JWT.
5. Flutter fetches the user by email and stores session data.

## 6. Engineering Details

### 6.1 Backend Architecture

The FastAPI app is created in `create_app()` and registers routers directly. The project uses SQLAlchemy Core `Table` definitions rather than ORM models. Sessions are managed through `get_db()` for request-scoped database access and `session_scope()` for background task writes.

The course generation router has two important runtime patterns:

- Request path: lightweight job creation and response.
- Background path: long-running AI work with independent DB sessions.

This is a practical structure for AI workloads because it avoids holding the HTTP request open while generation runs.

### 6.2 Course Payload Shape

Generated course data is stored as a JSON object with this top-level shape:

```json
{
  "topic": {},
  "units": {},
  "concepts": [],
  "questions": []
}
```

The Flutter app expects:

- `topic.learning_topic` for the course title.
- `units.units[]` for the learning path.
- `concepts` containing unit-specific concept lists.
- `questions` containing unit-specific question lists.

The client includes defensive parsing for more than one concept/question payload shape, which is useful while the AI output format is still evolving.

### 6.3 Job States

The backend defines these job states:

- `queued`: job row exists but generation has not started.
- `processing`: generation has started.
- `partial`: at least one partial course payload has been saved.
- `completed`: final course payload is available.
- `failed`: generation failed and an error message is stored.

The mobile app currently displays queued, processing, completed, failed, timeout, and generic error states. It also treats `partial` as a navigation opportunity.

### 6.4 LLM Configuration

The current default model is `gpt-4.1-mini` in `backend/src/agents/llm_config.py`, overridable by the `MODEL` environment variable. The code currently expects `OPENAI_API_KEY`, although the error message still references `GEMINI_API_KEY`; this should be corrected to avoid environment setup confusion.

Docker contains commented support for Ollama and a Qwen model, but the active compose path currently runs the API and database only.

### 6.5 Mobile State Management

The Flutter app uses local `StatefulWidget` state and service classes rather than a global state management framework. Session data is stored in static fields on `Session`.

This is acceptable for an early product stage, but production behavior will require persistent token storage, refresh behavior, logout cleanup, error recovery, and app restart session restoration.

### 6.6 Localization

The app includes English and Spanish ARB files and generated localization classes. Some UI text remains hardcoded in English in individual screens. For full stakeholder-ready internationalization, all visible strings should move into ARB files.

### 6.7 Notifications

The app initializes `NotificationService` at startup. Course generation can notify when a course is ready or when generation errors. Platform-specific notification service files exist for mobile and web.

### 6.8 Prototypes and Design Assets

The mobile project includes several prototype folders:

- `new_design`
- `new_design_2`
- `new_design_3`

These appear to contain external HTML/JSX design explorations and zipped frontend artifacts. They are useful references but should be separated from production source or documented clearly before sharing with executives or external engineering teams.

## 7. Current Strengths

- Clear separation between mobile app, backend API, AI agents, and database.
- Async job design avoids long-running HTTP requests.
- Partial course persistence improves perceived speed and enables progressive UX.
- Course generation is split into meaningful AI stages: topic/units, concepts, questions, fill-in-blank review.
- Backend schema already anticipates users, courses, jobs, progress, enrollment state, and embeddings.
- Flutter app has real screens for authentication, course creation, course path, lesson playback, profile, and progress.
- The app supports English and Spanish localization infrastructure.
- Docker Compose can run the backend and PostgreSQL locally.

## 8. Gaps, Risks, and Technical Debt

### 8.1 Security and Auth

- Several backend endpoints accept `user_id` from the request instead of deriving it from the authenticated JWT.
- Some user lookup endpoints are public and may expose user records by email or Google UID.
- `JWT_SECRET` has a default value of `change-me`; production must require an explicit secret.
- CORS is currently `allow_origins=["*"]`, which is appropriate for local development but not production.
- Session storage in Flutter is in-memory only and does not survive app restart.

### 8.2 API Consistency

- Some README references mention older endpoints such as `/ai/generate-course`, while the current backend uses `/ai/courses`.
- The backend includes `user_courses`, but active course listing reads directly from `courses`.
- Course generation request includes optional `user_id`, but this should eventually come from authentication.

### 8.3 Reliability

- FastAPI `BackgroundTasks` are process-local. If the API process restarts, running jobs are lost even though the job row remains.
- A production system should use a durable worker queue such as Celery, RQ, Dramatiq, Cloud Tasks, or a managed queue.
- Job cancellation, retry policy, and stuck-job recovery are not implemented.
- AI output parsing is defensive but still depends on LLM compliance with JSON instructions.

### 8.4 Data and Migrations

- The schema is loaded through a SQL dump rather than a formal migration tool.
- There is no migration versioning workflow for future schema changes.
- Course payload is stored as JSONB, which is flexible but makes validation, querying, and analytics harder.
- `meta.embeddings` exists but is not integrated into active workflows.

### 8.5 Quality and Testing

- There are no visible backend automated tests for routes, jobs, or agent payload parsing.
- Flutter has generated platform test scaffolding but no meaningful app tests.
- AI pipeline behavior should have contract tests using representative fixed payloads.
- Critical client parsing paths should have unit tests because the AI payload can vary.

### 8.6 Code Hygiene

- Some filenames and comments contain typos, for example `orchestatior_agents.py`.
- Some terminal/encoding output shows mojibake characters in comments and strings, suggesting encoding cleanup may be needed.
- There is a temporary debug block in `backend/src/agents/question_generation.py` under `if __name__ == "__main__"`.
- Prototype ZIPs and generated frontend experiments may inflate repository size and distract from production code.

## 9. Recommended Roadmap

### 9.1 Before Stakeholder Demo

- Confirm the app runs end-to-end locally with Docker backend and Flutter frontend.
- Update README endpoint references to match the current `/ai/courses` API.
- Clean visible hardcoded strings that conflict with localization.
- Set demo environment variables explicitly: `DATABASE_URL`, `OPENAI_API_KEY`, `MODEL`, `JWT_SECRET`.
- Prepare one or two reliable demo prompts that generate high-quality courses.
- Move or label prototype design folders so stakeholders understand they are references, not active app code.

### 9.2 Before Engineering Handoff

- Add architecture diagrams for mobile, backend, AI pipeline, and database.
- Add API examples for every route.
- Define the canonical course JSON contract.
- Add tests for auth, users, course jobs, progress, and client parsing.
- Replace process-local background jobs with a durable worker queue if production reliability is required.
- Add migrations with Alembic or another migration tool.
- Enforce auth on user-specific course and progress APIs.
- Add structured logging and job-level tracing.

### 9.3 Before Production

- Lock down CORS.
- Require strong `JWT_SECRET`.
- Store Flutter tokens securely.
- Add refresh/logout/session restoration.
- Add rate limiting for auth and AI generation endpoints.
- Add per-user course quotas on the backend, not only in the Flutter client.
- Add monitoring for job failures, generation latency, model errors, and database errors.
- Define data retention and privacy policy for user prompts and generated course content.
- Create staging and production deployment pipelines.

## 10. Suggested Presentation Structure

### Executive Section

1. What Alexandria is: AI-personalized microlearning.
2. Why it matters: fast course creation, mobile-first learning, adaptive content.
3. Current demo flow: sign in, create course, watch generation progress, open course, complete lessons.
4. Current maturity: functional prototype/product foundation.
5. Next investment areas: reliability, security, polish, testing, deployment.

### Product Workflow Section

1. User signs in.
2. User requests a course.
3. Backend queues the job.
4. AI agents generate course structure, concepts, and questions.
5. App shows partial/final course.
6. User learns through concepts and questions.
7. Progress is saved.

### Engineering Section

1. Repository structure.
2. Backend API architecture.
3. AI agent orchestration.
4. Database schema.
5. Flutter architecture.
6. Runtime and environment variables.
7. Known technical debt.
8. Recommended engineering roadmap.

## 11. Engineering Handoff Checklist

- Backend runs with `docker compose up -d --build`.
- Database schema initializes correctly from `00-schema_tables.sql`.
- `/health` responds.
- Auth register/login returns JWTs.
- Flutter can authenticate and fetch user profile.
- `POST /ai/courses` returns `job_id`.
- `GET /ai/courses/status/{job_id}` reaches `partial` or `completed`.
- `GET /ai/courses/{course_id}` returns course payload.
- Flutter opens course units from generated payload.
- Lesson screen renders concepts and all question types.
- Progress saves and loads for a user/course pair.
- English and Spanish app flows are reviewed.
- Demo model/API key is configured and cost limits are understood.

## 12. Summary

Alexandria already demonstrates the central product promise: a learner can authenticate, request a course, receive AI-generated learning content, interact with concepts and questions, and persist progress. The architecture is directionally sound for a prototype and early product build: Flutter provides the learner experience, FastAPI handles business/API responsibilities, PostgreSQL stores durable state, and CrewAI coordinates specialized generation tasks.

The most important next step is to turn the current working foundation into an engineering-ready system: tighten auth boundaries, formalize API and data contracts, add tests, introduce durable background processing, clean repo artifacts, and prepare deployment practices. With those improvements, the project can move from stakeholder demo quality toward maintainable team delivery.
