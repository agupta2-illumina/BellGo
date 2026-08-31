/// Service for sending SMS notifications
abstract class SmsNotificationService {
  /// Send SMS notification for leave time
  Future<void> sendLeaveTimeNotification({
    required String phoneNumber,
    required String childName,
    required DateTime leaveTime,
    required DateTime dismissalTime,
  });

  /// Send SMS notification for schedule change
  Future<void> sendScheduleChangeNotification({
    required String phoneNumber,
    required String childName,
    required DateTime date,
    required String scheduleType,
    required DateTime dismissalTime,
  });

  /// Send test SMS
  Future<void> sendTestSms(String phoneNumber);
}
