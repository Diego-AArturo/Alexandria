# Alexandria Móvil

Aplicación Flutter para explorar y crear cursos personalizados con una navegación por pestañas y pantallas enfocadas en progreso, generación de cursos y perfil.

## Arquitectura rápida
- `lib/main.dart`: punto de entrada; monta `MaterialApp` y carga `HomeShell`.
- `lib/components/`: componentes reutilizables (`HomeShell` con `NavigationBar`, `CourseCard`, `ProfileCard`) que mantienen estilos y navegación consistente.
- `lib/screens/`: vistas principales: `CourseHomeScreen` (listado y progreso de cursos), `CraftCourseScreen` (formulario para generar un curso), `ProfileScreen` (resumen de cuenta).
- `lib/core/`: recursos de diseño compartidos (`app_colors.dart`, `text_styles.dart`) para paleta y tipografías.
- `lib/data/`: espacio reservado para fuentes de datos, repositorios o servicios cuando se conecte a backend.

`HomeShell` usa un `IndexedStack` para preservar el estado de cada pantalla al cambiar de pestaña y un `NavigationBar` inferior para moverse entre cursos, creación y perfil.

## Estructura de carpetas (`lib/`)
```
lib/
├── components/
│   ├── course_card.dart
│   ├── home_shell.dart
│   └── profile_card.dart
├── core/
│   ├── app_colors.dart
│   └── text_styles.dart
├── data/
├── screens/
│   ├── course_home_screen.dart
│   ├── craft_course_screen.dart
│   └── profile_screen.dart
└── main.dart
```

## Cómo ejecutar
1) Requisitos: Flutter SDK ≥ 3.10, dispositivo/emulador Android o iOS, o navegador para web.
2) Instala dependencias:
```bash
cd movil_app/alexandria_movil
flutter pub get
```
3) Ejecuta la app (elige dispositivo con `flutter devices` si hay varios):
```bash
flutter run
```
   - Web: `flutter run -d chrome`
   - Android/iOS: `flutter run -d <id_dispositivo>`

## Desarrollo
- Hot reload: guarda cambios con la app en ejecución para verlos al instante.
- Estilos: agrega nuevos colores/tipografías en `lib/core` y reutiliza desde componentes y pantallas para mantener coherencia.
- Pruebas: usa `flutter test` (aún no hay tests incluidos).
