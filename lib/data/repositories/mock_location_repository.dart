import '../../domain/models/location.dart';
import '../../domain/repositories/location_repository.dart';
import '../mock/mock_data.dart';

/// Mock implementation of LocationRepository
class MockLocationRepository implements LocationRepository {
  final List<Location> _locations = MockData.getAllLocations();
  String _currentLocationId = MockData.workLocationId;

  @override
  Future<List<Location>> getLocations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_locations);
  }

  @override
  Future<Location?> getLocationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _locations.firstWhere((location) => location.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addLocation(Location location) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _locations.add(location);
  }

  @override
  Future<void> updateLocation(Location location) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _locations.indexWhere((l) => l.id == location.id);
    if (index != -1) {
      _locations[index] = location;
    }
  }

  @override
  Future<void> deleteLocation(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _locations.removeWhere((location) => location.id == id);
  }

  @override
  Future<Location?> getCurrentLocation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return getLocationById(_currentLocationId);
  }

  @override
  Future<void> setCurrentLocation(String locationId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentLocationId = locationId;
  }
}
