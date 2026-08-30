import '../models/day_schedule.dart';
import '../models/leave_time_info.dart';
import '../models/location.dart';

/// Service for calculating when to leave for school pickup
class LeaveTimeCalculator {
  const LeaveTimeCalculator();

  /// Calculate recommended leave time based on dismissal time, drive time, and buffer
  LeaveTimeInfo calculateLeaveTime({
    required String childId,
    required DateTime dismissalTime,
    required Duration driveTime,
    required Duration pickupBuffer,
    DateTime? currentTime,
  }) {
    final now = currentTime ?? DateTime.now();
    final recommendedLeaveTime = dismissalTime
        .subtract(driveTime)
        .subtract(pickupBuffer);

    return LeaveTimeInfo(
      childId: childId,
      schoolDismissalTime: dismissalTime,
      recommendedLeaveTime: recommendedLeaveTime,
      driveTime: driveTime,
      pickupBuffer: pickupBuffer,
      currentTime: now,
    );
  }

  /// Calculate leave time for a specific day's schedule
  Future<LeaveTimeInfo?> calculateLeaveTimeForSchedule({
    required String childId,
    required DaySchedule schedule,
    required Location origin,
    required Location schoolLocation,
    required Duration driveTime,
    required Duration pickupBuffer,
    DateTime? currentTime,
  }) async {
    if (!schedule.hasSchool || schedule.dismissalTime == null) {
      return null;
    }

    return calculateLeaveTime(
      childId: childId,
      dismissalTime: schedule.dismissalTime!,
      driveTime: driveTime,
      pickupBuffer: pickupBuffer,
      currentTime: currentTime,
    );
  }
}
