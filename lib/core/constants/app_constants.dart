/// App-wide constants
class AppConstants {
  static const String appName = 'BellGo';
  static const String appTagline = 'Know when to go.';

  static const Duration defaultPickupBuffer = Duration(minutes: 5);
  static const Duration defaultReminderTime = Duration(minutes: 5);

  static const List<int> pickupBufferOptions = [0, 5, 10, 15];
  static const List<int> reminderTimeOptions = [5, 10, 15, 30];

  static const int allGoodThresholdMinutes = 10;
  static const int getReadyThresholdMinutes = 5;
}
