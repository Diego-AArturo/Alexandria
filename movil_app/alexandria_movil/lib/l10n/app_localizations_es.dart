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

  @override
  String get authHeroTagline => 'Aprende lo que quieres, como quieres.';

  @override
  String get authSignInButton => '¡Vamos!';

  @override
  String get authPlaceholderName => 'Tu nombre completo';

  @override
  String get authPlaceholderEmail => 'tu@ejemplo.com';

  @override
  String get authValidationEmail => 'Ingresa un correo electrónico válido';

  @override
  String get authValidationPassword => 'Mínimo 8 caracteres';

  @override
  String get authValidationName => 'El nombre es obligatorio';

  @override
  String get navMyCourses => 'Mis cursos';

  @override
  String get navCraftCourse => 'Crear curso';

  @override
  String get navMyProfile => 'Mi perfil';

  @override
  String courseUnitsUnitsComplete(int completed, int total) {
    return '$completed de $total unidades completadas';
  }

  @override
  String get courseUnitsProgressSectionLabel => 'Progreso';

  @override
  String get courseUnitsLearningPathLabel => 'TU RUTA DE APRENDIZAJE';

  @override
  String get conceptCardLabel => 'CONCEPTO';

  @override
  String get courseUnitsBackLabel => 'Volver';

  @override
  String get craftExpertiseTitle => 'Nivel de experticia';

  @override
  String get craftExpertiseSubtitle =>
      'Define la profundidad y el rigor del contenido del curso.';

  @override
  String get craftExpertiseLabelBeginner => 'Principiante';

  @override
  String get craftExpertiseLabelExpert => 'Experto';

  @override
  String get craftExpertiseDescription1 =>
      'Primera aproximación al tema. Sin conocimiento previo. Lenguaje simple y analogías claras.';

  @override
  String get craftExpertiseDescription2 =>
      'Conocimiento introductorio. Refuerza los fundamentos con explicaciones claras.';

  @override
  String get craftExpertiseDescription3 =>
      'Te sientes confiado en el tema. El curso profundiza y amplía tu comprensión.';

  @override
  String get craftExpertiseDescription4 =>
      'Conocimiento significativo. Rigor avanzado y profundidad a nivel profesional.';

  @override
  String get craftExpertiseDescription5 =>
      'Eres experto. Máxima profundidad y rigor académico para evaluar los límites del área.';

  @override
  String get craftCourseGeneratingQueued => 'En cola…';

  @override
  String get craftCourseGeneratingProcessing => 'Generando curso…';

  @override
  String get craftCourseGeneratingCompleted => '¡Curso listo!';

  @override
  String get craftCourseGeneratingFailed => 'Error al generar';

  @override
  String get craftCourseGeneratingTimeout => 'Tiempo de generación agotado';

  @override
  String get craftCourseGeneratingSubtitle =>
      'Te avisaremos cuando esté listo — puedes salir de esta pantalla.';

  @override
  String get repasoIntroBadge => 'Repaso';

  @override
  String get repasoIntroHeading =>
      '¡Excelente trabajo!\nSolo algunos puntos por repasar.';

  @override
  String get repasoIntroBody =>
      'Reforcemos lo más importante antes de terminar.';

  @override
  String get repasoIntroCta => '¡Vamos!';

  @override
  String repasoIntroQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count preguntas por repasar',
      one: '1 pregunta por repasar',
    );
    return '$_temp0';
  }

  @override
  String get unitCompletionHeading => '¡Unidad completada!';

  @override
  String get unitCompletionBody => '¿Qué quieres hacer ahora?';

  @override
  String get unitCompletionReview => 'Revisar respuestas';

  @override
  String get unitCompletionRepeat => 'Repetir unidad';

  @override
  String get unitCompletionExit => 'Salir';

  @override
  String unitReviewLabel(int current, int total) {
    return 'Revisando $current / $total';
  }

  @override
  String get unitAlreadyCompletedHeading => 'Unidad completada';

  @override
  String get unitAlreadyCompletedBody =>
      '¿Quieres repetir esta unidad desde el principio?';

  @override
  String get courseCompletionHeading => '¡Felicitaciones!';

  @override
  String get courseCompletionSubtitle => 'Completaste todo el curso';

  @override
  String get courseCompletionBody =>
      'Dominaste todos los temas de principio a fin. Eso sí es dedicación.';

  @override
  String get courseCompletionCta => 'Continuar';

  @override
  String get profileNameLabel => 'Nombre de usuario';

  @override
  String get profileNewNameLabel => 'Nuevo nombre de usuario';

  @override
  String get profileLanguageFieldLabel => 'Idioma';

  @override
  String get profilePasswordLabel => 'Nueva contraseña';

  @override
  String get profilePasswordHint => 'Déjala vacía para mantener la actual';

  @override
  String get profileSaveAction => 'Guardar';

  @override
  String get profileCancelAction => 'Cancelar';

  @override
  String get profileSavedMessage => 'Perfil actualizado';

  @override
  String get profileRestartLanguageMessage =>
      'Reinicia la aplicación para ver los cambios de idioma.';

  @override
  String get profileSavedRestartLanguageMessage =>
      'Perfil actualizado. Reinicia la aplicación para ver los cambios de idioma.';

  @override
  String get profileNameRequired => 'El nombre de usuario es obligatorio';

  @override
  String profileUpdateFailed(String error) {
    return 'No se pudo actualizar el perfil: $error';
  }

  @override
  String profileCoursesTotalSublabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cursos en total',
      one: 'curso en total',
    );
    return '$_temp0';
  }

  @override
  String profileCoursesCompletedSublabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cursos completados',
      one: 'curso completado',
    );
    return '$_temp0';
  }

  @override
  String profileCoursesActiveSublabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cursos activos',
      one: 'curso activo',
    );
    return '$_temp0';
  }

  @override
  String get profileSignOut => 'Cerrar sesión';
}
