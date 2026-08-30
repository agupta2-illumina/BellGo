import 'package:equatable/equatable.dart';
import 'schedule_type.dart';

/// Represents a school's bell schedule for different types of days
class BellSchedule extends Equatable {
  const BellSchedule({
    required this.schoolId,
    required this.regularDismissal,
    required this.fridayDismissal,
    required this.minimumDayDismissal,
    required this.earlyReleaseDismissal,
  });

  final String schoolId;
  final DateTime regularDismissal;
  final DateTime fridayDismissal;
  final DateTime minimumDayDismissal;
  final DateTime earlyReleaseDismissal;

  DateTime getDismissalTime(ScheduleType scheduleType) {
    switch (scheduleType) {
      case ScheduleType.regularDay:
        return regularDismissal;
      case ScheduleType.earlyRelease:
        return earlyReleaseDismissal;
      case ScheduleType.minimumDay:
        return minimumDayDismissal;
      case ScheduleType.holiday:
      case ScheduleType.noSchool:
      case ScheduleType.custom:
        return regularDismissal;
    }
  }

  @override
  List<Object?> get props => [
        schoolId,
        regularDismissal,
        fridayDismissal,
        minimumDayDismissal,
        earlyReleaseDismissal,
      ];
}
