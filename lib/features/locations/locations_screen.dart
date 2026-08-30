import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'locations_provider.dart';

class LocationsScreen extends ConsumerWidget {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsState = ref.watch(locationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Locations'),
      ),
      body: locationsState.when(
        data: (data) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Where will you be when school ends?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...data.locations.map((location) {
              final isSelected = data.currentLocation?.id == location.id;

              return Card(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : null,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Icon(
                    _getLocationIcon(location.name),
                    size: 32,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(
                    location.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(location.shortAddress),
                    ],
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    ref
                        .read(locationsProvider.notifier)
                        .setCurrentLocation(location.id);
                  },
                ),
              );
            }),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  IconData _getLocationIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('home')) {
      return Icons.home;
    } else if (lowerName.contains('work')) {
      return Icons.work;
    } else {
      return Icons.place;
    }
  }
}
