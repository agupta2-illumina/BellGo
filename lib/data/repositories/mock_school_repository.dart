import '../../domain/models/school.dart';
import '../../domain/repositories/school_repository.dart';
import '../mock/mock_data.dart';

/// Mock implementation of SchoolRepository
class MockSchoolRepository implements SchoolRepository {
  final List<School> _schools = MockData.getAllSchools();

  @override
  Future<List<School>> getSchools() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_schools);
  }

  @override
  Future<School?> getSchoolById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _schools.firstWhere((school) => school.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<School>> searchSchools(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (query.isEmpty) {
      return _schools;
    }

    final lowerQuery = query.toLowerCase();
    return _schools
        .where(
          (school) =>
              school.name.toLowerCase().contains(lowerQuery) ||
              school.city.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }
}
