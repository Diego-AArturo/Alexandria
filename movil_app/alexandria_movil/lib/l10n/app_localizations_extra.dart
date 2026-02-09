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
