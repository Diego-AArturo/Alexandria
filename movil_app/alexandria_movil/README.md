# Alexandria Movil

Aplicacion Flutter para explorar y crear cursos personalizados con navegacion por pestanas y pantallas enfocadas en progreso, generacion de cursos y perfil.

## Arquitectura rapida

- `lib/main.dart`: punto de entrada; monta `MaterialApp` y carga `HomeShell`.
- `lib/components/`: componentes reutilizables (`HomeShell` con `NavigationBar`, `CourseCard`, `ProfileCard`, `questions_components/` para preguntas).
- `lib/screens/`: vistas principales (`CourseHomeScreen`, `CraftCourseScreen`, `ProfileScreen`).
- `lib/core/`: colores y tipografias compartidas.
- `lib/data/`: cliente HTTP y servicios para hablar con el backend.

`HomeShell` usa un `IndexedStack` para preservar el estado de cada pantalla al cambiar de pestana y un `NavigationBar` inferior para moverse entre cursos, creacion y perfil.

## Estructura de carpetas (`lib/`)

```
lib/
├── components/
│   ├── course_card.dart
│   ├── home_shell.dart
│   ├── profile_card.dart
│   └── questions_components/...
├── core/
│   ├── app_colors.dart
│   └── text_styles.dart
├── data/
│   ├── api_client.dart
│   └── course_generation_service.dart
├── screens/
│   ├── course_home_screen.dart
│   ├── craft_course_screen.dart
│   └── profile_screen.dart
└── main.dart
```

## Conexion con backend (FastAPI)

- Backend definido en `backend/src/routers/ai/course_generation.py`.
- Endpoints usados:
  - `POST /ai/generate-course` -> genera y persiste el curso, devuelve `course_id`.
  - `GET /ai/generate-course/{id}` -> recupera el curso almacenado.
- Cliente y servicio:
  - `lib/data/api_client.dart`: cliente HTTP base (paquete `http`).
  - `lib/data/course_generation_service.dart`: modelos y llamadas a los endpoints anteriores.
- Base URL por defecto: `http://localhost:8000`. Ajusta al entorno:
  - Emulador Android: `http://10.0.2.2:8000`.
  - Dispositivo fisico: IP de tu maquina (por ejemplo `http://192.168.x.x:8000`).
  - Puedes pasar `ApiClient(baseUrl: ...)` al crear `CourseGenerationService`.
- Flujo actual en UI: `CraftCourseScreen` llama a `generateCourse` al pulsar **Create Course**, muestra dialog con `course_id` y redirige a `CourseHomeScreen`.

## Backend rapido (resumen de `backend/Readme.md`)

- Requisitos: Docker y Docker Compose, o Python 3.11 con venv.
- Docker:
  ```bash
  docker compose up --build
  # API en http://localhost:8000
  ```
- Local:
  ```bash
  python -m venv .venv
  .venv\Scripts\activate
  pip install -r requirements.txt
  uvicorn src.main:app --reload
  ```
- Endpoints expuestos: `/health`, `/ai/generate-course`, `/ai/generate-course/{id}`.

## Que falta del frontend (segun plan de desarrollo)

- PromptScreen dedicada con diseno motivador (HU-05-01 tarea 6.1) y animacion/estado de carga al llamar `/ai/generate-course` (6.2).
- Roadmap del curso: vista de unidades con progreso y animaciones suaves (HU-05-02 tareas 6.3 y 6.4).
- Microlecciones: render dinamico de conceptos, scroll tipo microlearning, y persistir progreso (HU-05-03 tareas 7.1 y 7.2).
- Autenticacion y JWT en Flutter (HU-02-03 y HU-02-04) para consumir endpoints protegidos cuando se habilite auth en backend.

## Como ejecutar la app Flutter

1) Requisitos: Flutter SDK >= 3.10, dispositivo/emulador Android o iOS, o navegador web.
2) Instala dependencias:
   ```bash
   cd movil_app/alexandria_movil
   flutter pub get
   ```
3) Ejecuta:
   ```bash
   flutter run
   ```

   - Web: `flutter run -d chrome`
   - Android/iOS: `flutter run -d <id_dispositivo>`

## Desarrollo

- Hot reload: guarda cambios con la app en ejecucion para verlos al instante.
- Estilos: agrega nuevos colores/tipografias en `lib/core` y reutiliza desde componentes.
- Pruebas: usa `flutter test` (aun no hay tests incluidos).
