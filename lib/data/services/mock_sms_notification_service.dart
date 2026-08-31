import 'package:intl/intl.dart';

import '../../domain/services/sms_notification_service.dart';

/// Mock implementation of SmsNotificationService
class MockSmsNotificationService implements SmsNotificationService {
  @override
  Future<void> sendLeaveTimeNotification({
    required String phoneNumber,
    required String childName,
    required DateTime leaveTime,
    required DateTime dismissalTime,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final leaveTimeStr = DateFormat('h:mm a').format(leaveTime);
    final dismissalTimeStr = DateFormat('h:mm a').format(dismissalTime);

    final message = '''
🚗 BellGo: Time to leave!

$childName's school ends at $dismissalTimeStr.
Leave by $leaveTimeStr to arrive on time.
''';

    _simulateSms(phoneNumber, message);
  }

  @override
  Future<void> sendScheduleChangeNotification({
    required String phoneNumber,
    required String childName,
    required DateTime date,
    required String scheduleType,
    required DateTime dismissalTime,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final dateStr = DateFormat('EEEE, MMM d').format(date);
    final timeStr = DateFormat('h:mm a').format(dismissalTime);

    final message = '''
⚠️ BellGo: Schedule Change

$childName has a $scheduleType on $dateStr.
School ends at $timeStr.
''';

    _simulateSms(phoneNumber, message);
  }

  @override
  Future<void> sendTestSms(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final message = '''
✅ BellGo Test

Your phone is verified! You'll receive pickup reminders at this number.
''';

    _simulateSms(phoneNumber, message);
  }

  void _simulateSms(String phoneNumber, String message) {
    print('📱 SMS to $phoneNumber:\n$message');
  }
}
