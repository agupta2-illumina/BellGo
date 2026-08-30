import '../models/school.dart';

/// Repository for managing schools
abstract class SchoolRepository {
  /// Get all schools
  Future<List<School>> getSchools();

  /// Get a school by ID
  Future<School?> getSchoolById(String id);

  /// Search schools by name or location
  Future<List<School>> searchSchools(String query);
}
