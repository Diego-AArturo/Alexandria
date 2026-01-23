import 'notification_service_mobile.dart'
    if (dart.library.html) 'notification_service_web.dart' as backend;

/// Facade para notificaciones con implementaciones segÃºn plataforma
/// (mÃ³vil: flutter_local_notifications, web: Notifications API).
class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  Future<void> init() => backend.initNotifications();

  Future<void> showCourseReady({
    required int courseId,
    String? courseTitle,
  }) =>
      backend.showCourseReady(courseId: courseId, courseTitle: courseTitle);

  Future<void> showError({String? reason}) =>
      backend.showError(reason: reason);
}
