import 'package:flutter_test/flutter_test.dart';
import 'package:bellgo/data/services/mock_travel_time_service.dart';
import 'package:bellgo/domain/models/location.dart';

void main() {
  group('MockTravelTimeService', () {
    late MockTravelTimeService service;

    setUp(() {
      service = MockTravelTimeService();
    });

    test('returns travel time between locations', () async {
      final origin = const Location(
        id: '1',
        name: 'Home',
        address: '123 Main St',
        city: 'Fremont',
        state: 'CA',
        latitude: 37.5485,
        longitude: -121.9886,
      );

      final destination = const Location(
        id: '2',
        name: 'School',
        address: '456 School St',
        city: 'Fremont',
        state: 'CA',
        latitude: 37.5319,
        longitude: -121.9190,
      );

      final travelTime = await service.getTravelTime(origin, destination);

      expect(travelTime.inMinutes, greaterThan(0));
      expect(travelTime.inMinutes, lessThanOrEqualTo(60));
    });

    test('travel time is clamped between 5 and 60 minutes', () async {
      final sameLocation = const Location(
        id: '1',
        name: 'Same',
        address: '123 Main St',
        city: 'Fremont',
        state: 'CA',
        latitude: 37.5485,
        longitude: -121.9886,
      );

      final travelTime = await service.getTravelTime(
        sameLocation,
        sameLocation,
      );

      expect(travelTime.inMinutes, greaterThanOrEqualTo(5));
      expect(travelTime.inMinutes, lessThanOrEqualTo(60));
    });

    test('longer distances have longer travel times', () async {
      final origin = const Location(
        id: '1',
        name: 'Fremont',
        address: '123 Main St',
        city: 'Fremont',
        state: 'CA',
        latitude: 37.5485,
        longitude: -121.9886,
      );

      final nearDestination = const Location(
        id: '2',
        name: 'Near School',
        address: '456 School St',
        city: 'Fremont',
        state: 'CA',
        latitude: 37.5319,
        longitude: -121.9190,
      );

      final farDestination = const Location(
        id: '3',
        name: 'Far Location',
        address: '789 Far St',
        city: 'San Jose',
        state: 'CA',
        latitude: 37.3382,
        longitude: -121.8863,
      );

      final nearTime = await service.getTravelTime(origin, nearDestination);
      final farTime = await service.getTravelTime(origin, farDestination);

      expect(farTime.inMinutes, greaterThan(nearTime.inMinutes));
    });
  });
}
