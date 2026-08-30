import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/models/leave_time_info.dart';
import 'today_provider.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayState = ref.watch(todayProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Today'),
            Text(
              DateFormat('EEEE, MMMM d').format(DateTime.now()),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: todayState.when(
        data: (data) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data.leaveTimeInfo != null)
                _buildLeaveTimeCard(context, data.leaveTimeInfo!),
              const SizedBox(height: 24),
              if (data.child != null && data.school != null) ...[
                _buildChildInfoCard(context, ref, data),
                const SizedBox(height: 24),
              ],
              if (data.tomorrowSchedule != null &&
                  data.tomorrowSchedule!.scheduleType.displayName !=
                      'Regular Day')
                _buildTomorrowCard(context, ref, data),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildLeaveTimeCard(
    BuildContext context,
    LeaveTimeInfo leaveTimeInfo,
  ) {
    final status = leaveTimeInfo.status;
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case LeaveTimeStatus.allGood:
        statusColor = Theme.of(context).colorScheme.primary;
        statusIcon = Icons.check_circle;
        statusText = status.displayText;
        break;
      case LeaveTimeStatus.getReady:
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.warning;
        statusText = status.displayText;
        break;
      case LeaveTimeStatus.timeToLeave:
      case LeaveTimeStatus.late:
        statusColor = const Color(0xFFEF4444);
        statusIcon = Icons.directions_car;
        statusText = status.displayText;
        break;
    }

    final timeUntilDismissal = leaveTimeInfo.timeUntilDismissal;
    final hoursLeft = timeUntilDismissal.inHours;
    final minutesLeft = timeUntilDismissal.inMinutes % 60;

    String timeLeftText;
    if (hoursLeft > 0) {
      timeLeftText = '$hoursLeft hr ${minutesLeft} min';
    } else if (minutesLeft > 0) {
      timeLeftText = '$minutesLeft min';
    } else {
      timeLeftText = 'now';
    }

    return Card(
      child: Container(
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: statusColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              statusIcon,
              size: 48,
              color: statusColor,
            ),
            const SizedBox(height: 16),
            Text(
              statusText.toUpperCase(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "School ends in $timeLeftText",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Leave by',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('h:mm a')
                        .format(leaveTimeInfo.recommendedLeaveTime),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTimeDetail(
                        context,
                        'Drive',
                        '${leaveTimeInfo.driveTime.inMinutes} min',
                      ),
                      _buildTimeDetail(
                        context,
                        'Buffer',
                        '${leaveTimeInfo.pickupBuffer.inMinutes} min',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDetail(
    BuildContext context,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildChildInfoCard(
    BuildContext context,
    WidgetRef ref,
    TodayData data,
  ) {
    final leaveTimeInfo = data.leaveTimeInfo;
    final child = data.child!;
    final school = data.school!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    child.firstName[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.fullName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        '${school.name} · Grade ${child.grade}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (leaveTimeInfo != null) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoColumn(
                      context,
                      'School ends',
                      DateFormat('h:mm a')
                          .format(leaveTimeInfo.schoolDismissalTime),
                    ),
                  ),
                  Expanded(
                    child: _buildInfoColumn(
                      context,
                      'Leave by',
                      DateFormat('h:mm a')
                          .format(leaveTimeInfo.recommendedLeaveTime),
                    ),
                  ),
                  Expanded(
                    child: _buildInfoColumn(
                      context,
                      'Drive',
                      '${leaveTimeInfo.driveTime.inMinutes} min',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
    BuildContext context,
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  Widget _buildTomorrowCard(
    BuildContext context,
    WidgetRef ref,
    TodayData data,
  ) {
    final tomorrowSchedule = data.tomorrowSchedule!;
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    return Card(
      color: const Color(0xFFFEF3C7),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warning_amber,
                  color: Color(0xFFF59E0B),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'TOMORROW',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFF92400E),
                        letterSpacing: 1.2,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              tomorrowSchedule.scheduleType.displayName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF92400E),
                  ),
            ),
            if (tomorrowSchedule.dismissalTime != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'School ends',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF92400E),
                                  ),
                        ),
                        Text(
                          DateFormat('h:mm a')
                              .format(tomorrowSchedule.dismissalTime!),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: const Color(0xFF92400E),
                                  ),
                        ),
                      ],
                    ),
                  ),
                  if (data.tomorrowLeaveTime != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Leave by',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: const Color(0xFF92400E),
                                    ),
                          ),
                          Text(
                            DateFormat('h:mm a').format(
                              data.tomorrowLeaveTime!.recommendedLeaveTime,
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: const Color(0xFF92400E),
                                ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
