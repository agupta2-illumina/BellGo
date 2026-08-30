import '../models/location.dart';

/// Abstract service for calculating travel time between locations
abstract class TravelTimeService {
  /// Calculate travel time from origin to destination
  Future<Duration> getTravelTime(
    Location origin,
    Location destination,
  );
}
