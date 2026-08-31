import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/mock_child_repository.dart';
import '../../data/repositories/mock_location_repository.dart';
import '../../data/repositories/mock_school_repository.dart';
import '../../data/services/mock_notification_service.dart';
import '../../data/services/mock_phone_verification_service.dart';
import '../../data/services/mock_school_schedule_service.dart';
import '../../data/services/mock_sms_notification_service.dart';
import '../../data/services/mock_travel_time_service.dart';
import '../../domain/repositories/child_repository.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/school_repository.dart';
import '../../domain/services/leave_time_calculator.dart';
import '../../domain/services/notification_service.dart';
import '../../domain/services/phone_verification_service.dart';
import '../../domain/services/school_schedule_service.dart';
import '../../domain/services/sms_notification_service.dart';
import '../../domain/services/travel_time_service.dart';

final childRepositoryProvider = Provider<ChildRepository>((ref) {
  return MockChildRepository();
});

final schoolRepositoryProvider = Provider<SchoolRepository>((ref) {
  return MockSchoolRepository();
});

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return MockLocationRepository();
});

final travelTimeServiceProvider = Provider<TravelTimeService>((ref) {
  return MockTravelTimeService();
});

final schoolScheduleServiceProvider = Provider<SchoolScheduleService>((ref) {
  return MockSchoolScheduleService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return MockNotificationService();
});

final phoneVerificationServiceProvider =
    Provider<PhoneVerificationService>((ref) {
  return MockPhoneVerificationService();
});

final smsNotificationServiceProvider = Provider<SmsNotificationService>((ref) {
  return MockSmsNotificationService();
});

final leaveTimeCalculatorProvider = Provider<LeaveTimeCalculator>((ref) {
  return const LeaveTimeCalculator();
});
