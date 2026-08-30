import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/models/child.dart';
import '../../domain/models/day_schedule.dart';
import '../../domain/models/leave_time_info.dart';
import '../../domain/models/location.dart';
import '../../domain/models/school.dart';

class TodayData {
  const TodayData({
    this.child,
    this.school,
    this.currentLocation,
    this.todaySchedule,
    this.tomorrowSchedule,
    this.leaveTimeInfo,
    this.tomorrowLeaveTime,
  });

  final Child? child;
  final School? school;
  final Location? currentLocation;
  final DaySchedule? todaySchedule;
  final DaySchedule? tomorrowSchedule;
  final LeaveTimeInfo? leaveTimeInfo;
  final LeaveTimeInfo? tomorrowLeaveTime;
}

final todayProvider = FutureProvider<TodayData>((ref) async {
  final childRepository = ref.read(childRepositoryProvider);
  final schoolRepository = ref.read(schoolRepositoryProvider);
  final locationRepository = ref.read(locationRepositoryProvider);
  final scheduleService = ref.read(schoolScheduleServiceProvider);
  final travelTimeService = ref.read(travelTimeServiceProvider);
  final calculator = ref.read(leaveTimeCalculatorProvider);

  final children = await childRepository.getChildren();
  if (children.isEmpty) {
    return const TodayData();
  }

  final child = children.first;
  final school = await schoolRepository.getSchoolById(child.schoolId);
  if (school == null) {
    return TodayData(child: child);
  }

  final currentLocation = await locationRepository.getCurrentLocation();
  if (currentLocation == null) {
    return TodayData(child: child, school: school);
  }

  final schoolLocation = Location(
    id: 'school-location',
    name: school.name,
    address: school.address,
    city: school.city,
    state: school.state,
    latitude: school.latitude,
    longitude: school.longitude,
  );

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));

  final todaySchedule = await scheduleService.getScheduleForDate(
    school.id,
    today,
  );

  final tomorrowSchedule = await scheduleService.getScheduleForDate(
    school.id,
    tomorrow,
  );

  final driveTime = await travelTimeService.getTravelTime(
    currentLocation,
    schoolLocation,
  );

  LeaveTimeInfo? leaveTimeInfo;
  if (todaySchedule.hasSchool && todaySchedule.dismissalTime != null) {
    leaveTimeInfo = calculator.calculateLeaveTime(
      childId: child.id,
      dismissalTime: todaySchedule.dismissalTime!,
      driveTime: driveTime,
      pickupBuffer: AppConstants.defaultPickupBuffer,
    );
  }

  LeaveTimeInfo? tomorrowLeaveTime;
  if (tomorrowSchedule.hasSchool && tomorrowSchedule.dismissalTime != null) {
    tomorrowLeaveTime = calculator.calculateLeaveTime(
      childId: child.id,
      dismissalTime: tomorrowSchedule.dismissalTime!,
      driveTime: driveTime,
      pickupBuffer: AppConstants.defaultPickupBuffer,
    );
  }

  return TodayData(
    child: child,
    school: school,
    currentLocation: currentLocation,
    todaySchedule: todaySchedule,
    tomorrowSchedule: tomorrowSchedule,
    leaveTimeInfo: leaveTimeInfo,
    tomorrowLeaveTime: tomorrowLeaveTime,
  );
});
