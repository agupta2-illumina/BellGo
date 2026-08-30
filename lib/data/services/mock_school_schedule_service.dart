import '../../domain/models/bell_schedule.dart';
import '../../domain/models/day_schedule.dart';
import '../../domain/models/schedule_type.dart';
import '../../domain/services/school_schedule_service.dart';
import '../mock/mock_data.dart';

/// Mock implementation of SchoolScheduleService
class MockSchoolScheduleService implements SchoolScheduleService {
  @override
  Future<BellSchedule> getBellSchedule(String schoolId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();
    return BellSchedule(
      schoolId: schoolId,
      regularDismissal: DateTime(now.year, now.month, now.day, 15, 5),
      fridayDismissal: DateTime(now.year, now.month, now.day, 14, 5),
      minimumDayDismissal: DateTime(now.year, now.month, now.day, 12, 45),
      earlyReleaseDismissal: DateTime(now.year, now.month, now.day, 13, 35),
    );
  }

  @override
  Future<DaySchedule> getScheduleForDate(
    String schoolId,
    DateTime date,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final scheduleType = determineScheduleType(schoolId, date);
    final bellSchedule = await getBellSchedule(schoolId);

    DateTime? dismissalTime;
    if (scheduleType.hasSchool) {
      if (date.weekday == DateTime.friday) {
        dismissalTime = DateTime(
          date.year,
          date.month,
          date.day,
          bellSchedule.fridayDismissal.hour,
          bellSchedule.fridayDismissal.minute,
        );
      } else {
        final baseTime = bellSchedule.getDismissalTime(scheduleType);
        dismissalTime = DateTime(
          date.year,
          date.month,
          date.day,
          baseTime.hour,
          baseTime.minute,
        );
      }
    }

    return DaySchedule(
      date: date,
      scheduleType: scheduleType,
      dismissalTime: dismissalTime,
    );
  }

  @override
  Future<List<DaySchedule>> getSchedulesForRange(
    String schoolId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final schedules = <DaySchedule>[];
    var currentDate = startDate;

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      final schedule = await getScheduleForDate(schoolId, currentDate);
      schedules.add(schedule);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return schedules;
  }

  @override
  ScheduleType determineScheduleType(String schoolId, DateTime date) {
    if (date.weekday == DateTime.saturday ||
        date.weekday == DateTime.sunday) {
      return ScheduleType.noSchool;
    }

    final specialDates = MockData.getSpecialScheduleDates();
    final dateKey = _formatDate(date);

    if (specialDates.containsKey(dateKey)) {
      return specialDates[dateKey]!;
    }

    if (date.weekday == DateTime.wednesday) {
      return ScheduleType.earlyRelease;
    }

    return ScheduleType.regularDay;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
