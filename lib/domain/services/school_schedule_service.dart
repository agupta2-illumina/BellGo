import '../models/bell_schedule.dart';
import '../models/day_schedule.dart';
import '../models/schedule_type.dart';

/// Service for managing school schedules
abstract class SchoolScheduleService {
  /// Get the bell schedule for a school
  Future<BellSchedule> getBellSchedule(String schoolId);

  /// Get the schedule for a specific date
  Future<DaySchedule> getScheduleForDate(String schoolId, DateTime date);

  /// Get schedules for a date range
  Future<List<DaySchedule>> getSchedulesForRange(
    String schoolId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Determine schedule type for a specific date
  ScheduleType determineScheduleType(
    String schoolId,
    DateTime date,
  );
}
