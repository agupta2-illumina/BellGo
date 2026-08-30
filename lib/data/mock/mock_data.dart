import '../../domain/models/child.dart';
import '../../domain/models/location.dart';
import '../../domain/models/school.dart';
import '../../domain/models/schedule_type.dart';

/// Mock data for the application
class MockData {
  static const String defaultChildId = 'child-1';
  static const String defaultSchoolId = 'school-1';
  static const String homeLocationId = 'location-home';
  static const String workLocationId = 'location-work';

  static Child getDefaultChild() {
    return const Child(
      id: defaultChildId,
      firstName: 'Viaan',
      lastName: 'Gupta',
      grade: 5,
      schoolId: defaultSchoolId,
    );
  }

  static School getMissionSanJoseElementary() {
    return const School(
      id: defaultSchoolId,
      name: 'Mission San Jose Elementary',
      address: '43775 Mission Blvd',
      city: 'Fremont',
      state: 'California',
      zipCode: '94539',
      gradeRangeStart: 0,
      gradeRangeEnd: 5,
      latitude: 37.5319,
      longitude: -121.9190,
    );
  }

  static List<School> getAllSchools() {
    return [
      getMissionSanJoseElementary(),
      const School(
        id: 'school-2',
        name: 'John M. Horner Middle School',
        address: '43800 Mission Blvd',
        city: 'Fremont',
        state: 'California',
        zipCode: '94539',
        gradeRangeStart: 6,
        gradeRangeEnd: 8,
        latitude: 37.5325,
        longitude: -121.9195,
      ),
      const School(
        id: 'school-3',
        name: 'Mission San Jose High School',
        address: '41717 Palm Ave',
        city: 'Fremont',
        state: 'California',
        zipCode: '94539',
        gradeRangeStart: 9,
        gradeRangeEnd: 12,
        latitude: 37.5290,
        longitude: -121.9230,
      ),
    ];
  }

  static Location getHomeLocation() {
    return const Location(
      id: homeLocationId,
      name: 'Home',
      address: '123 Main St',
      city: 'Fremont',
      state: 'CA',
      latitude: 37.5485,
      longitude: -121.9886,
    );
  }

  static Location getWorkLocation() {
    return const Location(
      id: workLocationId,
      name: 'Work',
      address: '456 Business Pkwy',
      city: 'San Jose',
      state: 'CA',
      latitude: 37.3382,
      longitude: -121.8863,
    );
  }

  static List<Location> getAllLocations() {
    return [
      getHomeLocation(),
      getWorkLocation(),
    ];
  }

  static Map<String, ScheduleType> getSpecialScheduleDates() {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1);

    return {
      _formatDate(now.add(const Duration(days: 1))): ScheduleType.minimumDay,
      _formatDate(nextMonth): ScheduleType.holiday,
      _formatDate(now.add(const Duration(days: 14))): ScheduleType.minimumDay,
    };
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
