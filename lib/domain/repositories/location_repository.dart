import '../models/location.dart';

/// Repository for managing locations
abstract class LocationRepository {
  /// Get all locations
  Future<List<Location>> getLocations();

  /// Get a location by ID
  Future<Location?> getLocationById(String id);

  /// Add a new location
  Future<void> addLocation(Location location);

  /// Update an existing location
  Future<void> updateLocation(Location location);

  /// Delete a location
  Future<void> deleteLocation(String id);

  /// Get the currently selected location
  Future<Location?> getCurrentLocation();

  /// Set the current location
  Future<void> setCurrentLocation(String locationId);
}
