import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _selectedPickupBuffer = 5;
  int _selectedReminderTime = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            'General',
            [
              ListTile(
                leading: const Icon(Icons.child_care),
                title: const Text('Children'),
                subtitle: const Text('Manage your children'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/children'),
              ),
              ListTile(
                leading: const Icon(Icons.place),
                title: const Text('Locations'),
                subtitle: const Text('Set your pickup location'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showLocationsBottomSheet(context);
                },
              ),
            ],
          ),
          _buildSection(
            context,
            'Notifications',
            [
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Enable Notifications'),
                subtitle: const Text('Get reminders when to leave'),
                trailing: Switch(
                  value: true,
                  onChanged: (value) {},
                ),
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Reminder Time'),
                subtitle: Text('$_selectedReminderTime minutes before'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showReminderTimePicker(context),
              ),
            ],
          ),
          _buildSection(
            context,
            'Travel',
            [
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Travel Buffer'),
                subtitle: Text('Extra $_selectedPickupBuffer minutes'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showPickupBufferPicker(context),
              ),
            ],
          ),
          _buildSection(
            context,
            'About',
            [
              const ListTile(
                leading: Icon(Icons.info),
                title: Text('Version'),
                subtitle: Text('1.0.0'),
              ),
              const ListTile(
                leading: Icon(Icons.copyright),
                title: Text('About BellGo'),
                subtitle: Text('Know when to go.'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 1.2,
                ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showPickupBufferPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Travel Buffer',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            ...AppConstants.pickupBufferOptions.map((minutes) {
              return ListTile(
                title: Text(
                  minutes == 0 ? 'No buffer' : '$minutes minutes',
                ),
                trailing: _selectedPickupBuffer == minutes
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedPickupBuffer = minutes;
                  });
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showReminderTimePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Reminder Time',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            ...AppConstants.reminderTimeOptions.map((minutes) {
              return ListTile(
                title: Text('$minutes minutes before'),
                trailing: _selectedReminderTime == minutes
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedReminderTime = minutes;
                  });
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLocationsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Locations',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const Text('Manage your pickup locations in the app.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/settings');
                },
                child: const Text('Go to Locations'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
