/// Abstract service for notification management
abstract class NotificationService {
  /// Initialize the notification service
  Future<void> initialize();

  /// Request notification permissions
  Future<bool> requestPermissions();

  /// Schedule a leave time reminder
  Future<void> scheduleLeaveTimeReminder({
    required String childName,
    required DateTime leaveTime,
    required DateTime dismissalTime,
  });

  /// Schedule a schedule change notification
  Future<void> scheduleScheduleChangeNotification({
    required String childName,
    required DateTime date,
    required String scheduleType,
    required DateTime dismissalTime,
    required DateTime leaveTime,
  });

  /// Cancel all scheduled notifications
  Future<void> cancelAllNotifications();

  /// Cancel notifications for a specific child
  Future<void> cancelNotificationsForChild(String childId);
}
