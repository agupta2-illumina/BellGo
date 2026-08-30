import 'package:flutter_test/flutter_test.dart';
import 'package:bellgo/data/services/mock_school_schedule_service.dart';
import 'package:bellgo/domain/models/schedule_type.dart';

void main() {
  group('MockSchoolScheduleService', () {
    late MockSchoolScheduleService service;

    setUp(() {
      service = MockSchoolScheduleService();
    });

    test('returns bell schedule with correct times', () async {
      final schedule = await service.getBellSchedule('school-1');

      expect(schedule.regularDismissal.hour, equals(15));
      expect(schedule.regularDismissal.minute, equals(5));
      expect(schedule.fridayDismissal.hour, equals(14));
      expect(schedule.fridayDismissal.minute, equals(5));
      expect(schedule.minimumDayDismissal.hour, equals(12));
      expect(schedule.minimumDayDismissal.minute, equals(45));
      expect(schedule.earlyReleaseDismissal.hour, equals(13));
      expect(schedule.earlyReleaseDismissal.minute, equals(35));
    });

    test('weekends are marked as no school', () {
      final saturday = DateTime(2026, 8, 30);
      final sunday = DateTime(2026, 8, 31);

      expect(
        service.determineScheduleType('school-1', saturday),
        equals(ScheduleType.noSchool),
      );
      expect(
        service.determineScheduleType('school-1', sunday),
        equals(ScheduleType.noSchool),
      );
    });

    test('wednesday is early release', () {
      final wednesday = DateTime(2026, 9, 3);

      expect(
        service.determineScheduleType('school-1', wednesday),
        equals(ScheduleType.earlyRelease),
      );
    });

    test('regular weekdays are regular days', () {
      final monday = DateTime(2026, 9, 1);
      final tuesday = DateTime(2026, 9, 2);
      final thursday = DateTime(2026, 9, 4);

      expect(
        service.determineScheduleType('school-1', monday),
        equals(ScheduleType.regularDay),
      );
      expect(
        service.determineScheduleType('school-1', tuesday),
        equals(ScheduleType.regularDay),
      );
      expect(
        service.determineScheduleType('school-1', thursday),
        equals(ScheduleType.regularDay),
      );
    });

    test('getScheduleForDate returns correct dismissal time for regular day', () async {
      final monday = DateTime(2026, 9, 1);
      final schedule = await service.getScheduleForDate('school-1', monday);

      expect(schedule.scheduleType, equals(ScheduleType.regularDay));
      expect(schedule.dismissalTime, isNotNull);
      expect(schedule.dismissalTime!.hour, equals(15));
      expect(schedule.dismissalTime!.minute, equals(5));
    });

    test('getScheduleForDate returns correct dismissal time for Friday', () async {
      final friday = DateTime(2026, 9, 5);
      final schedule = await service.getScheduleForDate('school-1', friday);

      expect(schedule.scheduleType, equals(ScheduleType.regularDay));
      expect(schedule.dismissalTime, isNotNull);
      expect(schedule.dismissalTime!.hour, equals(14));
      expect(schedule.dismissalTime!.minute, equals(5));
    });

    test('getScheduleForDate returns correct dismissal time for early release', () async {
      final wednesday = DateTime(2026, 9, 3);
      final schedule = await service.getScheduleForDate('school-1', wednesday);

      expect(schedule.scheduleType, equals(ScheduleType.earlyRelease));
      expect(schedule.dismissalTime, isNotNull);
      expect(schedule.dismissalTime!.hour, equals(13));
      expect(schedule.dismissalTime!.minute, equals(35));
    });

    test('getScheduleForDate returns no dismissal time for weekends', () async {
      final saturday = DateTime(2026, 8, 30);
      final schedule = await service.getScheduleForDate('school-1', saturday);

      expect(schedule.scheduleType, equals(ScheduleType.noSchool));
      expect(schedule.dismissalTime, isNull);
    });

    test('getSchedulesForRange returns schedules for date range', () async {
      final startDate = DateTime(2026, 9, 1);
      final endDate = DateTime(2026, 9, 7);

      final schedules = await service.getSchedulesForRange(
        'school-1',
        startDate,
        endDate,
      );

      expect(schedules.length, equals(7));
      expect(schedules.first.date, equals(startDate));
      expect(schedules.last.date, equals(endDate));
    });
  });
}
