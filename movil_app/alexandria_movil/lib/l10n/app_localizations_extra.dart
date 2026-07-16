import 'package:alexandria_movil/l10n/app_localizations.dart';

/// Temporary extension to provide course limit messages without touching
/// the generated localization files. Remove once `flutter gen-l10n` is
/// rerun and the ARB strings are regenerated.
extension ProfileStatsLocalization on AppLocalizations {
  String profileCoursesTotalSublabel(int count) {
    if (localeName.startsWith('es')) {
      return count == 1 ? 'curso en total' : 'cursos en total';
    }
    return count == 1 ? 'total course' : 'total courses';
  }

  String profileCoursesCompletedSublabel(int count) {
    if (localeName.startsWith('es')) {
      return count == 1 ? 'curso completado' : 'cursos completados';
    }
    return count == 1 ? 'course completed' : 'courses completed';
  }

  String profileCoursesActiveSublabel(int count) {
    if (localeName.startsWith('es')) {
      return count == 1 ? 'curso activo' : 'cursos activos';
    }
    return count == 1 ? 'course active' : 'courses active';
  }
}

extension NavLabelsLocalization on AppLocalizations {
  String get navMyCourses =>
      localeName.startsWith('es') ? 'Mis cursos' : 'My courses';
  String get navCraftCourse =>
      localeName.startsWith('es') ? 'Crear curso' : 'Craft course';
  String get navMyProfile =>
      localeName.startsWith('es') ? 'Mi perfil' : 'My profile';
}

extension CraftCourseLimitLocalization on AppLocalizations {
  String craftCourseLimitReached(int limit) {
    final template = localeName.startsWith('es')
        ? 'Límite beta alcanzado: solo puedes crear hasta {limit} cursos.'
        : 'Beta limit reached: you can create up to {limit} courses.';
    return template.replaceFirst('{limit}', '$limit');
  }

  String craftCourseLimitCheckFailed(String error) {
    final template = localeName.startsWith('es')
        ? 'No pudimos validar tus cursos: {error}'
        : 'Could not validate your courses: {error}';
    return template.replaceFirst('{error}', error);
  }
}

extension CourseUnitsLocalization on AppLocalizations {
  String courseUnitsUnitsComplete(int completed, int total) {
    if (localeName.startsWith('es')) {
      return '$completed de $total unidades completadas';
    }
    return '$completed of $total units complete';
  }

  String get courseUnitsProgressSectionLabel =>
      localeName.startsWith('es') ? 'Progreso' : 'Progress';

  String get courseUnitsLearningPathLabel =>
      localeName.startsWith('es') ? 'TU RUTA DE APRENDIZAJE' : 'YOUR LEARNING PATH';

  String get conceptCardLabel =>
      localeName.startsWith('es') ? 'CONCEPTO' : 'CONCEPT';

  String get courseUnitsBackLabel =>
      localeName.startsWith('es') ? 'Volver' : 'Back';
}

extension AuthScreenLocalization on AppLocalizations {
  String get authHeroTagline => localeName.startsWith('es')
      ? 'Aprende lo que quieres, como quieres.'
      : 'Learn anything. Master everything.';

  String get authSignInButton =>
      localeName.startsWith('es') ? '¡Vamos!' : "Let's go!";

  String get authPlaceholderName =>
      localeName.startsWith('es') ? 'Tu nombre completo' : 'Your full name';

  String get authPlaceholderEmail =>
      localeName.startsWith('es') ? 'tu@ejemplo.com' : 'you@example.com';

  String get authValidationEmail => localeName.startsWith('es')
      ? 'Ingresa un correo electrónico válido'
      : 'Enter a valid email';

  String get authValidationPassword => localeName.startsWith('es')
      ? 'Mínimo 8 caracteres'
      : 'At least 8 characters';

  String get authValidationName => localeName.startsWith('es')
      ? 'El nombre es obligatorio'
      : 'Name is required';
}

extension CraftCourseExpertiseLocalization on AppLocalizations {
  String get craftExpertiseTitle =>
      localeName.startsWith('es') ? 'Nivel de expertise' : 'Expertise level';

  String get craftExpertiseSubtitle => localeName.startsWith('es')
      ? 'Define la profundidad y el rigor del contenido del curso.'
      : 'Sets the depth and rigor of the course content.';

  String get craftExpertiseLabelBeginner =>
      localeName.startsWith('es') ? 'Principiante' : 'Beginner';

  String get craftExpertiseLabelExpert =>
      localeName.startsWith('es') ? 'Experto' : 'Expert';

  String craftExpertiseDescription(int level) {
    if (localeName.startsWith('es')) {
      return switch (level) {
        1 =>
          'Primera aproximación al tema. Sin conocimiento previo. Lenguaje simple y analogías claras.',
        2 =>
          'Conocimiento introductorio. Refuerza los fundamentos con explicaciones claras.',
        3 =>
          'Te sientes confiado en el tema. El curso profundiza y amplía tu comprensión.',
        4 =>
          'Conocimiento significativo. Rigor avanzado y profundidad a nivel profesional.',
        5 =>
          'Eres experto. Máxima profundidad y rigor académico para evaluar los límites del área.',
        _ => '',
      };
    }
    return switch (level) {
      1 => 'First contact with the topic. No prior knowledge assumed. Simple language and clear analogies.',
      2 => 'Introductory awareness. Reinforces fundamentals with clear explanations.',
      3 => "Comfortable with the basics. The course deepens and broadens your understanding.",
      4 => 'Significant knowledge. Advanced rigor and professional-level depth.',
      5 => "Expert level. Maximum academic depth and rigor to test the edges of the field.",
      _ => '',
    };
  }
}

extension RepasoIntroLocalization on AppLocalizations {
  String get repasoIntroBadge =>
      localeName.startsWith('es') ? 'Repaso' : 'Review';

  String get repasoIntroHeading => localeName.startsWith('es')
      ? '¡Excelente trabajo!\nSolo algunos puntos por repasar.'
      : 'Great work!\nJust a few points to revisit.';

  String get repasoIntroBody => localeName.startsWith('es')
      ? 'Reforcemos lo más importante antes de terminar.'
      : "Let's reinforce what matters before we wrap up.";

  String get repasoIntroCta =>
      localeName.startsWith('es') ? '¡Vamos!' : "Let's go!";

  String repasoIntroQuestionCount(int count) {
    if (localeName.startsWith('es')) {
      return count == 1
          ? '1 pregunta por repasar'
          : '$count preguntas por repasar';
    }
    return count == 1 ? '1 question to review' : '$count questions to review';
  }
}

extension CourseCompletionLocalization on AppLocalizations {
  String get courseCompletionHeading =>
      localeName.startsWith('es') ? '¡Felicitaciones!' : 'Congratulations!';

  String get courseCompletionSubtitle => localeName.startsWith('es')
      ? 'Completaste todo el curso'
      : 'You completed the entire course';

  String get courseCompletionBody => localeName.startsWith('es')
      ? 'Dominaste todos los temas de principio a fin. Eso sí es dedicación.'
      : "You mastered every topic from start to finish. Now that's dedication.";

  String get courseCompletionCta =>
      localeName.startsWith('es') ? 'Continuar' : 'Continue';
}

extension UnitCompletionLocalization on AppLocalizations {
  String get unitCompletionHeading =>
      localeName.startsWith('es') ? '¡Unidad completada!' : 'Unit Complete!';

  String get unitCompletionBody => localeName.startsWith('es')
      ? '¿Qué quieres hacer ahora?'
      : 'What would you like to do next?';

  String get unitCompletionReview =>
      localeName.startsWith('es') ? 'Revisar respuestas' : 'Review Answers';

  String get unitCompletionRepeat =>
      localeName.startsWith('es') ? 'Repetir unidad' : 'Repeat Unit';

  String get unitCompletionExit =>
      localeName.startsWith('es') ? 'Salir' : 'Exit';

  String unitReviewLabel(int current, int total) {
    if (localeName.startsWith('es')) {
      return 'Revisando $current / $total';
    }
    return 'Reviewing $current / $total';
  }

  String get unitAlreadyCompletedHeading =>
      localeName.startsWith('es') ? 'Unidad completada' : 'Unit Completed';

  String get unitAlreadyCompletedBody => localeName.startsWith('es')
      ? '¿Quieres repetir esta unidad desde el principio?'
      : 'Would you like to repeat this unit from the beginning?';
}

extension ProfileEditLocalization on AppLocalizations {
  String get profileNameLabel =>
      localeName.startsWith('es') ? 'Nombre de usuario' : 'Username';

  String get profileNewNameLabel =>
      localeName.startsWith('es') ? 'Nuevo nombre de usuario' : 'New username';

  String get profileLanguageFieldLabel =>
      localeName.startsWith('es') ? 'Idioma' : 'Language';

  String get profilePasswordLabel =>
      localeName.startsWith('es') ? 'Nueva contraseña' : 'New password';

  String get profilePasswordHint => localeName.startsWith('es')
      ? 'Déjala vacía para mantener la actual'
      : 'Leave blank to keep the current password';

  String get profileSaveAction =>
      localeName.startsWith('es') ? 'Guardar' : 'Save';

  String get profileCancelAction =>
      localeName.startsWith('es') ? 'Cancelar' : 'Cancel';

  String get profileSavedMessage =>
      localeName.startsWith('es') ? 'Perfil actualizado' : 'Profile updated';

  String get profileRestartLanguageMessage => localeName.startsWith('es')
      ? 'Reinicia la aplicación para ver los cambios de idioma.'
      : 'Restart the application to see the language changes.';

  String get profileSavedRestartLanguageMessage => localeName.startsWith('es')
      ? 'Perfil actualizado. Reinicia la aplicación para ver los cambios de idioma.'
      : 'Profile updated. Restart the application to see the language changes.';

  String get profileNameRequired => localeName.startsWith('es')
      ? 'El nombre de usuario es obligatorio'
      : 'Username is required';

  String profileUpdateFailed(String error) {
    final template = localeName.startsWith('es')
        ? 'No se pudo actualizar el perfil: {error}'
        : 'Could not update profile: {error}';
    return template.replaceFirst('{error}', error);
  }
}
