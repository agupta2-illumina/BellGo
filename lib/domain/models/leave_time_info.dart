import 'package:equatable/equatable.dart';

enum LeaveTimeStatus {
  allGood,
  getReady,
  timeToLeave,
  late;

  String get displayText {
    switch (this) {
      case LeaveTimeStatus.allGood:
        return "You're good";
      case LeaveTimeStatus.getReady:
        return 'Get ready';
      case LeaveTimeStatus.timeToLeave:
        return 'Time to leave';
      case LeaveTimeStatus.late:
        return 'Leave now!';
    }
  }
}

/// Represents the calculated leave time information
class LeaveTimeInfo extends Equatable {
  const LeaveTimeInfo({
    required this.childId,
    required this.schoolDismissalTime,
    required this.recommendedLeaveTime,
    required this.driveTime,
    required this.pickupBuffer,
    required this.currentTime,
  });

  final String childId;
  final DateTime schoolDismissalTime;
  final DateTime recommendedLeaveTime;
  final Duration driveTime;
  final Duration pickupBuffer;
  final DateTime currentTime;

  /// Time until school ends
  Duration get timeUntilDismissal {
    return schoolDismissalTime.difference(currentTime);
  }

  /// Time until recommended leave time
  Duration get timeUntilLeave {
    return recommendedLeaveTime.difference(currentTime);
  }

  /// Determine the leave time status based on current time
  LeaveTimeStatus get status {
    final minutesUntilLeave = timeUntilLeave.inMinutes;

    if (minutesUntilLeave < 0) {
      return LeaveTimeStatus.late;
    } else if (minutesUntilLeave <= 0) {
      return LeaveTimeStatus.timeToLeave;
    } else if (minutesUntilLeave <= 10) {
      return LeaveTimeStatus.getReady;
    } else {
      return LeaveTimeStatus.allGood;
    }
  }

  bool get shouldLeaveNow {
    return status == LeaveTimeStatus.timeToLeave ||
        status == LeaveTimeStatus.late;
  }

  @override
  List<Object?> get props => [
        childId,
        schoolDismissalTime,
        recommendedLeaveTime,
        driveTime,
        pickupBuffer,
        currentTime,
      ];
}
