import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Servicio sencillo para notificaciones locales cuando un curso termina de generarse.
class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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

    _initialized = true;
  }

  Future<void> showCourseReady({
    required int courseId,
    String? title,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'course_generation',
      'Course generation',
      channelDescription: 'Notifications for course generation results',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    final safeTitle = title?.isNotEmpty == true ? title! : 'Course ready';
    await _plugin.show(
      courseId,
      safeTitle,
      'Your generated course is ready to view',
      details,
      payload: courseId.toString(),
    );
  }

  Future<void> showError({required String message}) async {
    const androidDetails = AndroidNotificationDetails(
      'course_generation',
      'Course generation',
      channelDescription: 'Notifications for course generation results',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(
      0,
      'Course generation failed',
      message,
      details,
    );
  }
}
