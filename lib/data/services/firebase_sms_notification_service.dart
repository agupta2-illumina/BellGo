import 'package:cloud_functions/cloud_functions.dart';
import 'package:intl/intl.dart';

import '../../domain/services/sms_notification_service.dart';

/// Firebase Cloud Functions implementation of SmsNotificationService
/// 
/// Sends SMS notifications via Firebase Cloud Functions which can integrate
/// with Twilio, AWS SNS, or other SMS providers.
class FirebaseSmsNotificationService implements SmsNotificationService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  @override
  Future<void> sendLeaveTimeNotification({
    required String phoneNumber,
    required String childName,
    required DateTime leaveTime,
    required DateTime dismissalTime,
  }) async {
    try {
      final callable = _functions.httpsCallable('sendLeaveTimeNotification');
      
      final result = await callable.call<Map<String, dynamic>>({
        'phoneNumber': phoneNumber,
        'childName': childName,
        'leaveTime': DateFormat('h:mm a').format(leaveTime),
        'dismissalTime': DateFormat('h:mm a').format(dismissalTime),
      });

      if (result.data['success'] != true) {
        throw Exception('Failed to send notification: ${result.data['error']}');
      }
    } on FirebaseFunctionsException catch (e) {
      throw Exception('Cloud function error: ${e.message}');
    }
  }

  @override
  Future<void> sendScheduleChangeNotification({
    required String phoneNumber,
    required String childName,
    required DateTime date,
    required String scheduleType,
    required DateTime dismissalTime,
  }) async {
    try {
      final callable = _functions.httpsCallable('sendScheduleChangeNotification');
      
      final result = await callable.call<Map<String, dynamic>>({
        'phoneNumber': phoneNumber,
        'childName': childName,
        'date': DateFormat('EEEE, MMM d').format(date),
        'scheduleType': scheduleType,
        'dismissalTime': DateFormat('h:mm a').format(dismissalTime),
      });

      if (result.data['success'] != true) {
        throw Exception('Failed to send notification: ${result.data['error']}');
      }
    } on FirebaseFunctionsException catch (e) {
      throw Exception('Cloud function error: ${e.message}');
    }
  }

  @override
  Future<void> sendTestSms(String phoneNumber) async {
    try {
      final callable = _functions.httpsCallable('sendTestSms');
      
      final result = await callable.call<Map<String, dynamic>>({
        'phoneNumber': phoneNumber,
      });

      if (result.data['success'] != true) {
        throw Exception('Failed to send test SMS: ${result.data['error']}');
      }
    } on FirebaseFunctionsException catch (e) {
      throw Exception('Cloud function error: ${e.message}');
    }
  }
}
