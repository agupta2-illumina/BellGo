import 'dart:math';

import '../../domain/models/location.dart';
import '../../domain/services/travel_time_service.dart';

/// Mock implementation of TravelTimeService
class MockTravelTimeService implements TravelTimeService {
  @override
  Future<Duration> getTravelTime(
    Location origin,
    Location destination,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final distance = _calculateDistance(
      origin.latitude,
      origin.longitude,
      destination.latitude,
      destination.longitude,
    );

    final travelMinutes = (distance * 1.2).round();

    return Duration(minutes: travelMinutes.clamp(5, 60));
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371.0;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = (dLat / 2) * (dLat / 2) +
        _degreesToRadians(lat1) *
            _degreesToRadians(lat2) *
            (dLon / 2) *
            (dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
