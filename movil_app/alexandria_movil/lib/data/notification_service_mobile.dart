import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
bool _initialized = false;

Future<void> initNotifications() async {
  if (_initialized) return;

  // Use the generated launcher icon to avoid missing-resource crashes on init.
  const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
  const darwinSettings = DarwinInitializationSettings();
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: darwinSettings,
  );

  await _plugin.initialize(initSettings);

  const androidChannel = AndroidNotificationChannel(
    'course_generation',
    'Course generation',
    description: 'Notifications for course generation results',
    importance: Importance.high,
  );
  await _plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidChannel);

  // Android 13+ requires POST_NOTIFICATIONS runtime permission.
  await _plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  // iOS permission prompt.
  await _plugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true, sound: true);

  _initialized = true;
}

Future<void> showCourseReady({
  required int courseId,
  String? courseTitle,
}) async {
  if (!_initialized) await initNotifications();

  const androidDetails = AndroidNotificationDetails(
    'course_generation',
    'Course generation',
    channelDescription: 'Notifications for course generation results',
    importance: Importance.high,
    priority: Priority.high,
  );
  const iosDetails = DarwinNotificationDetails();
  const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

  final body = (courseTitle != null && courseTitle.trim().isNotEmpty)
      ? 'The course "${courseTitle.trim()}" is ready to view.'
      : 'Your course is ready to view.';

  await _plugin.show(
    courseId,
    'Course ready',
    body,
    details,
    payload: courseId.toString(),
  );
}

Future<void> showError({String? reason}) async {
  if (!_initialized) await initNotifications();

  const androidDetails = AndroidNotificationDetails(
    'course_generation',
    'Course generation',
    channelDescription: 'Notifications for course generation results',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );
  const iosDetails = DarwinNotificationDetails();
  const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

  // Avoid leaking backend URLs or course names; keep the message user-friendly.
  const fallbackBody =
      'We could not create your course. Please try again in a moment.';
  final body = _stripUrls(reason) ?? fallbackBody;

  await _plugin.show(
    0,
    'Course generation failed',
    body,
    details,
  );
}

String? _stripUrls(String? input) {
  if (input == null || input.trim().isEmpty) return null;
  final withoutUrls =
      input.replaceAll(RegExp('https?://\\S+', caseSensitive: false), '').trim();
  if (withoutUrls.isEmpty) return null;
  return withoutUrls.length > 140 ? '${withoutUrls.substring(0, 140)}...' : withoutUrls;
}
