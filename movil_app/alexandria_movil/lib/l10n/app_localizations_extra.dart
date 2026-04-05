import 'package:alexandria_movil/l10n/app_localizations.dart';

/// Temporary extension to provide course limit messages without touching
/// the generated localization files. Remove once `flutter gen-l10n` is
/// rerun and the ARB strings are regenerated.
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

extension ProfileEditLocalization on AppLocalizations {
  String get profileNameLabel =>
      localeName.startsWith('es') ? 'Nombre de usuario' : 'Username';

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
