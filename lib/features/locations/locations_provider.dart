import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/models/location.dart';

class LocationsData {
  const LocationsData({
    required this.locations,
    required this.currentLocation,
  });

  final List<Location> locations;
  final Location? currentLocation;
}

class LocationsNotifier extends AsyncNotifier<LocationsData> {
  @override
  Future<LocationsData> build() async {
    final locationRepository = ref.read(locationRepositoryProvider);

    final locations = await locationRepository.getLocations();
    final currentLocation = await locationRepository.getCurrentLocation();

    return LocationsData(
      locations: locations,
      currentLocation: currentLocation,
    );
  }

  Future<void> setCurrentLocation(String locationId) async {
    final locationRepository = ref.read(locationRepositoryProvider);
    await locationRepository.setCurrentLocation(locationId);
    ref.invalidateSelf();
  }
}

final locationsProvider =
    AsyncNotifierProvider<LocationsNotifier, LocationsData>(() {
  return LocationsNotifier();
});
