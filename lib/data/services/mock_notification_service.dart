import '../../domain/services/notification_service.dart';

/// Mock implementation of NotificationService
class MockNotificationService implements NotificationService {
  bool _initialized = false;
  bool _permissionsGranted = false;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _initialized = true;
  }

  @override
  Future<bool> requestPermissions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _permissionsGranted = true;
    return true;
  }

  @override
  Future<void> scheduleLeaveTimeReminder({
    required String childName,
    required DateTime leaveTime,
    required DateTime dismissalTime,
  }) async {
    if (!_initialized) {
      await initialize();
    }
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> scheduleScheduleChangeNotification({
    required String childName,
    required DateTime date,
    required String scheduleType,
    required DateTime dismissalTime,
    required DateTime leaveTime,
  }) async {
    if (!_initialized) {
      await initialize();
    }
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> cancelAllNotifications() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> cancelNotificationsForChild(String childId) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
