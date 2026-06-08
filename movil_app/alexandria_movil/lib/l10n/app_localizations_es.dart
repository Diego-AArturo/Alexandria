// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';


// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get authFillRequiredFields =>
      'Por favor completa todos los campos requeridos.';

  @override
  String get authTitleSignIn => 'Iniciar sesión';

  @override
  String get authTitleCreateAccount => 'Crear cuenta';

  @override
  String get authLabelEmail => 'Correo electrónico';

  @override
  String get authLabelName => 'Nombre';

  @override
  String get authLabelPassword => 'Contraseña';

  @override
  String get authPrimaryContinue => 'Continuar';

  @override
  String get authPrimaryCreateAccount => 'Crear cuenta';

  @override
  String get authGoogleSigningIn => 'Iniciando sesión...';

  @override
  String get authGoogleContinue => 'Continuar con Google';

  @override
  String get authToggleNoAccount => '¿No tienes cuenta? Regístrate';

  @override
  String get authToggleHasAccount => '¿Ya tienes una cuenta? Inicia sesión';

  @override
  String authSnackbarAuthFailed(String error) {
    return 'Error de autenticación: $error';
  }

  @override
  String authSnackbarGoogleFailed(String error) {
    return 'Error al iniciar con Google: $error';
  }

  @override
  String get authErrorGoogleCancelled => 'El inicio con Google fue cancelado.';

  @override
  String get authErrorGoogleMissingIdToken => 'Falta el idToken de Google';

  @override
  String get courseHomeSignInPrompt => 'Inicia sesión para cargar tus cursos.';

  @override
  String get courseHomeTitle => 'Mis cursos';

  @override
  String courseHomeLoadFailed(String error) {
    return 'No se pudieron cargar los cursos: $error';
  }

  @override
  String get courseHomeEmptyState =>
      'Aún no tienes cursos. Genera uno para comenzar.';

  @override
  String get courseHomeEmptyMockTitle => 'Crea tu primer curso';

  @override
  String get courseHomeEmptyMockDescription =>
      'Usa la pestaña Craft course para describir lo que quieres aprender. Así se verán tus cursos.';

  @override
  String get courseHomeEmptyMockSampleTitle =>
      'Ejemplo: Python para automatizar tareas pequeñas';

  @override
  String get courseHomeEmptyMockSampleDescription =>
      '3 unidades cortas · Nivel inicial · Ejercicios prácticos';

  @override
  String get courseHomeEmptyMockAction => 'Ir a Craft course';

  @override
  String get courseHomeEmptyMockActionHint =>
      'Abre la pestaña Craft course abajo para crear tu primer curso.';

  @override
  String courseHomeProgressLabel(int percent) {
    return 'Progreso $percent%';
  }

  @override
  String unitNumberLabel(int number) {
    return 'Unidad $number';
  }

  @override
  String courseUnitsProgressLabel(int percent) {
    return 'Progreso $percent%';
  }

  @override
  String courseUnitsCurrentLabel(int current, int total) {
    return 'Estás en la unidad $current de $total';
  }

  @override
  String courseUnitsLoadFailed(String error) {
    return 'No se pudo cargar el progreso: $error';
  }

  @override
  String courseScreenConceptCounter(int current, int total) {
    return 'Concepto $current de $total';
  }

  @override
  String courseScreenQuestionCounter(int current, int total) {
    return 'Pregunta $current de $total';
  }

  @override
  String courseScreenRetryCounter(int current, int total) {
    return 'Repaso $current de $total';
  }

  @override
  String get courseScreenSubmitAnswer => 'Enviar respuesta';

  @override
  String get courseScreenPrevious => 'Anterior';

  @override
  String get courseScreenContinue => 'Continuar';

  @override
  String get courseScreenNoContent =>
      'No hay contenido disponible para esta unidad.';

  @override
  String get courseScreenPlaceholderContent =>
      'El contenido de esta unidad aún no está disponible.';

  @override
  String courseScreenFallbackConceptTitle(String unitTitle, int number) {
    return '$unitTitle - Concepto $number';
  }

  @override
  String get craftCourseTitle => 'Crear un curso';

  @override
  String get craftCourseSubtitle =>
      'Describe lo que quieres aprender y crearemos un curso breve y personalizado para ti.';

  @override
  String get craftCoursePromptHint =>
      'Ejemplo: Quiero aprender lo básico de Python para automatizar tareas sencillas.';

  @override
  String get craftCourseSubmitLabel => 'Crear curso';

  @override
  String get craftCourseSubmittingLabel => 'Creando...';

  @override
  String get craftCourseToastEmptyPrompt => 'Describe el curso que quieres.';

  @override
  String get craftCourseQueuedMessage =>
      'Curso en cola. Te avisaremos cuando esté listo.';

  @override
  String craftCourseLimitReached(int limit) {
    return 'Límite beta alcanzado: solo puedes crear hasta $limit cursos.';
  }

  @override
  String craftCourseLimitCheckFailed(String error) {
    return 'No pudimos validar tus cursos: $error';
  }

  @override
  String craftCourseGenerateFailed(String error) {
    return 'No se pudo generar el curso: $error';
  }

  @override
  String get craftCourseGeneratedTitleFallback => 'Curso generado';

  @override
  String get craftCourseGeneratedDescriptionFallback => 'Tu curso generado';

  @override
  String craftCourseOpenFailed(String error) {
    return 'El curso se generó pero no se pudo abrir: $error';
  }

  @override
  String get craftCourseTipsTitle => 'Consejos para grandes cursos:';

  @override
  String get craftCourseTipSpecificGoals =>
      'Sé específico con tus objetivos de aprendizaje';

  @override
  String get craftCourseTipKnowledgeLevel =>
      'Menciona tu nivel de conocimiento actual';

  @override
  String get craftCourseTipTopics =>
      'Incluye los temas específicos que quieres cubrir';

  @override
  String get profileSignInPrompt => 'Inicia sesión para ver tu perfil.';

  @override
  String profileLoadFailed(String error) {
    return 'No se pudo cargar el perfil: $error';
  }

  @override
  String get profileTitle => 'Mi perfil';

  @override
  String get profileGuestName => 'Invitado';

  @override
  String get profileNotSignedIn => 'Sesión no iniciada';

  @override
  String get profileCoursesTitle => 'Cursos';

  @override
  String get profileCoursesTotalLabel => 'Cursos totales';

  @override
  String get profileCompletedTitle => 'Completados';

  @override
  String get profileCoursesCompletedLabel => 'Cursos completados';

  @override
  String get profileInProgressTitle => 'En curso';

  @override
  String get profileCoursesActiveLabel => 'Cursos activos';

  @override
  String get profileAccountInfoTitle => 'Información de la cuenta';

  @override
  String get courseScreenSelectOne => 'Selecciona una';

  @override
  String get courseScreenTrueOrFalse => 'Verdadero o Falso';

  @override
  String get courseScreenTrue => 'Verdadero';

  @override
  String get courseScreenFalse => 'Falso';

  @override
  String get courseScreenCorrectLabel => '¡Lo lograste!';

  @override
  String get courseScreenIncorrectLabel => 'No del todo.';

  @override
  String get courseScreenFillBlanks => 'Completa los espacios';
}
