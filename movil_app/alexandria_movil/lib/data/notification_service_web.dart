// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

bool _initialized = false;
bool _permissionGranted = false;

Future<void> initNotifications() async {
  if (_initialized) return;
  _initialized = true;

  if (!html.Notification.supported) return;

  final permission = await html.Notification.requestPermission();
  _permissionGranted = permission == 'granted';
}

Future<void> showCourseReady({
  required int courseId, // kept for API parity
  String? courseTitle,
}) async {
  if (!_initialized) await initNotifications();
  if (!_permissionGranted || !html.Notification.supported) return;

  final body = (courseTitle != null && courseTitle.trim().isNotEmpty)
      ? 'The course "${courseTitle.trim()}" is ready to view.'
      : 'Your course is ready to view.';
  html.Notification('Course ready', body: body);
}

Future<void> showError({String? reason}) async {
  if (!_initialized) await initNotifications();
  if (!_permissionGranted || !html.Notification.supported) return;

  const fallbackBody =
      'We could not create your course. Please try again in a moment.';
  final body = _stripUrls(reason) ?? fallbackBody;

  html.Notification('Course generation failed', body: body);
}

String? _stripUrls(String? input) {
  if (input == null || input.trim().isEmpty) return null;
  final withoutUrls =
      input.replaceAll(RegExp('https?://\\S+', caseSensitive: false), '').trim();
  if (withoutUrls.isEmpty) return null;
  return withoutUrls.length > 140 ? '${withoutUrls.substring(0, 140)}...' : withoutUrls;
}
