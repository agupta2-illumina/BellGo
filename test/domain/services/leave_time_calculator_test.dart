import 'package:flutter_test/flutter_test.dart';
import 'package:bellgo/domain/models/leave_time_info.dart';
import 'package:bellgo/domain/services/leave_time_calculator.dart';

void main() {
  group('LeaveTimeCalculator', () {
    late LeaveTimeCalculator calculator;

    setUp(() {
      calculator = const LeaveTimeCalculator();
    });

    test('calculates correct leave time', () {
      final dismissalTime = DateTime(2026, 8, 29, 15, 5);
      final driveTime = const Duration(minutes: 18);
      final pickupBuffer = const Duration(minutes: 5);
      final currentTime = DateTime(2026, 8, 29, 14, 0);

      final result = calculator.calculateLeaveTime(
        childId: 'test-child',
        dismissalTime: dismissalTime,
        driveTime: driveTime,
        pickupBuffer: pickupBuffer,
        currentTime: currentTime,
      );

      expect(result.recommendedLeaveTime.hour, equals(14));
      expect(result.recommendedLeaveTime.minute, equals(42));
      expect(result.driveTime, equals(driveTime));
      expect(result.pickupBuffer, equals(pickupBuffer));
    });

    test('status is allGood when more than 10 minutes until leave time', () {
      final dismissalTime = DateTime(2026, 8, 29, 15, 5);
      final currentTime = DateTime(2026, 8, 29, 14, 0);

      final result = calculator.calculateLeaveTime(
        childId: 'test-child',
        dismissalTime: dismissalTime,
        driveTime: const Duration(minutes: 18),
        pickupBuffer: const Duration(minutes: 5),
        currentTime: currentTime,
      );

      expect(result.status, equals(LeaveTimeStatus.allGood));
      expect(result.shouldLeaveNow, isFalse);
    });

    test('status is getReady when 5-10 minutes until leave time', () {
      final dismissalTime = DateTime(2026, 8, 29, 15, 5);
      final currentTime = DateTime(2026, 8, 29, 14, 35);

      final result = calculator.calculateLeaveTime(
        childId: 'test-child',
        dismissalTime: dismissalTime,
        driveTime: const Duration(minutes: 18),
        pickupBuffer: const Duration(minutes: 5),
        currentTime: currentTime,
      );

      expect(result.status, equals(LeaveTimeStatus.getReady));
      expect(result.shouldLeaveNow, isFalse);
    });

    test('status is timeToLeave at leave time', () {
      final dismissalTime = DateTime(2026, 8, 29, 15, 5);
      final currentTime = DateTime(2026, 8, 29, 14, 42);

      final result = calculator.calculateLeaveTime(
        childId: 'test-child',
        dismissalTime: dismissalTime,
        driveTime: const Duration(minutes: 18),
        pickupBuffer: const Duration(minutes: 5),
        currentTime: currentTime,
      );

      expect(result.status, equals(LeaveTimeStatus.timeToLeave));
      expect(result.shouldLeaveNow, isTrue);
    });

    test('status is late when past leave time', () {
      final dismissalTime = DateTime(2026, 8, 29, 15, 5);
      final currentTime = DateTime(2026, 8, 29, 14, 50);

      final result = calculator.calculateLeaveTime(
        childId: 'test-child',
        dismissalTime: dismissalTime,
        driveTime: const Duration(minutes: 18),
        pickupBuffer: const Duration(minutes: 5),
        currentTime: currentTime,
      );

      expect(result.status, equals(LeaveTimeStatus.late));
      expect(result.shouldLeaveNow, isTrue);
    });

    test('calculates time until dismissal correctly', () {
      final dismissalTime = DateTime(2026, 8, 29, 15, 5);
      final currentTime = DateTime(2026, 8, 29, 14, 42);

      final result = calculator.calculateLeaveTime(
        childId: 'test-child',
        dismissalTime: dismissalTime,
        driveTime: const Duration(minutes: 18),
        pickupBuffer: const Duration(minutes: 5),
        currentTime: currentTime,
      );

      expect(result.timeUntilDismissal.inMinutes, equals(23));
    });

    test('calculates time until leave correctly', () {
      final dismissalTime = DateTime(2026, 8, 29, 15, 5);
      final currentTime = DateTime(2026, 8, 29, 14, 0);

      final result = calculator.calculateLeaveTime(
        childId: 'test-child',
        dismissalTime: dismissalTime,
        driveTime: const Duration(minutes: 18),
        pickupBuffer: const Duration(minutes: 5),
        currentTime: currentTime,
      );

      expect(result.timeUntilLeave.inMinutes, equals(42));
    });
  });
}
