import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/models/day_schedule.dart';

final calendarProvider = FutureProvider.family<List<DaySchedule>, DateTime>(
  (ref, selectedDate) async {
    final childRepository = ref.read(childRepositoryProvider);
    final schoolRepository = ref.read(schoolRepositoryProvider);
    final scheduleService = ref.read(schoolScheduleServiceProvider);

    final children = await childRepository.getChildren();
    if (children.isEmpty) {
      return [];
    }

    final child = children.first;
    final school = await schoolRepository.getSchoolById(child.schoolId);
    if (school == null) {
      return [];
    }

    final startDate = DateTime(selectedDate.year, selectedDate.month, 1);
    final endDate = DateTime(selectedDate.year, selectedDate.month + 1, 0);

    return scheduleService.getSchedulesForRange(
      school.id,
      startDate,
      endDate,
    );
  },
);
