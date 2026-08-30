enum ScheduleType {
  regularDay,
  earlyRelease,
  minimumDay,
  holiday,
  noSchool,
  custom;

  String get displayName {
    switch (this) {
      case ScheduleType.regularDay:
        return 'Regular Day';
      case ScheduleType.earlyRelease:
        return 'Early Release';
      case ScheduleType.minimumDay:
        return 'Minimum Day';
      case ScheduleType.holiday:
        return 'Holiday';
      case ScheduleType.noSchool:
        return 'No School';
      case ScheduleType.custom:
        return 'Custom';
    }
  }

  bool get hasSchool {
    return this != ScheduleType.holiday && this != ScheduleType.noSchool;
  }
}
