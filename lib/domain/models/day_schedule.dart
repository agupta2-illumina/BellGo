import 'package:equatable/equatable.dart';
import 'schedule_type.dart';

/// Represents a day's schedule information
class DaySchedule extends Equatable {
  const DaySchedule({
    required this.date,
    required this.scheduleType,
    required this.dismissalTime,
    this.notes,
  });

  final DateTime date;
  final ScheduleType scheduleType;
  final DateTime? dismissalTime;
  final String? notes;

  bool get hasSchool => scheduleType.hasSchool;

  @override
  List<Object?> get props => [date, scheduleType, dismissalTime, notes];

  DaySchedule copyWith({
    DateTime? date,
    ScheduleType? scheduleType,
    DateTime? dismissalTime,
    String? notes,
  }) {
    return DaySchedule(
      date: date ?? this.date,
      scheduleType: scheduleType ?? this.scheduleType,
      dismissalTime: dismissalTime ?? this.dismissalTime,
      notes: notes ?? this.notes,
    );
  }
}
