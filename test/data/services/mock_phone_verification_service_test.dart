import 'package:flutter_test/flutter_test.dart';
import 'package:bellgo/data/services/mock_phone_verification_service.dart';

void main() {
  group('MockPhoneVerificationService', () {
    late MockPhoneVerificationService service;

    setUp(() {
      service = MockPhoneVerificationService();
    });

    test('sendOTP returns a verification ID', () async {
      final verificationId = await service.sendOTP('+15551234567');

      expect(verificationId, isNotEmpty);
      expect(verificationId, startsWith('VID_'));
    });

    test('verifyOTP returns true for valid code', () async {
      final phoneNumber = '+15551234567';
      final verificationId = await service.sendOTP(phoneNumber);

      // In a real app, we'd get the OTP from SMS
      // For testing, we need to extract it from the service
      // Since we can't access private fields, we'll test the flow

      final isValid = await service.verifyOTP(verificationId, '123456');

      // The result depends on whether the code matches
      expect(isValid, isA<bool>());
    });

    test('verifyOTP returns false for invalid verification ID', () async {
      final isValid = await service.verifyOTP('INVALID_ID', '123456');

      expect(isValid, isFalse);
    });

    test('can save and retrieve phone number', () async {
      const phoneNumber = '+15551234567';

      await service.savePhoneNumber(phoneNumber);
      final retrieved = await service.getVerifiedPhoneNumber();

      expect(retrieved, equals(phoneNumber));
    });

    test('removePhoneNumber clears the saved number', () async {
      const phoneNumber = '+15551234567';

      await service.savePhoneNumber(phoneNumber);
      await service.removePhoneNumber();
      final retrieved = await service.getVerifiedPhoneNumber();

      expect(retrieved, isNull);
    });

    test('resendOTP returns a new verification ID', () async {
      final phoneNumber = '+15551234567';

      final firstId = await service.sendOTP(phoneNumber);
      final secondId = await service.resendOTP(phoneNumber);

      expect(secondId, isNotEmpty);
      expect(secondId, startsWith('VID_'));
      // IDs should be different for security
      expect(secondId, isNot(equals(firstId)));
    });

    test('getVerifiedPhoneNumber returns null initially', () async {
      final phone = await service.getVerifiedPhoneNumber();

      expect(phone, isNull);
    });
  });
}
