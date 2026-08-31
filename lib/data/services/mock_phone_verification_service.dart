import 'dart:math';

import '../../domain/services/phone_verification_service.dart';

/// Mock implementation of PhoneVerificationService
class MockPhoneVerificationService implements PhoneVerificationService {
  String? _verifiedPhoneNumber;
  final Map<String, String> _otpCodes = {};
  final Random _random = Random();

  @override
  Future<String> sendOTP(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final verificationId = _generateVerificationId();
    final otpCode = _generateOTP();

    _otpCodes[verificationId] = otpCode;

    // In a real app, this would send an SMS via Twilio, AWS SNS, etc.
    // For demo purposes, we'll print it to console
    print('📱 SMS to $phoneNumber: Your BellGo verification code is: $otpCode');

    return verificationId;
  }

  @override
  Future<bool> verifyOTP(String verificationId, String otpCode) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final expectedCode = _otpCodes[verificationId];
    if (expectedCode == null) {
      return false;
    }

    final isValid = expectedCode == otpCode;
    if (isValid) {
      _otpCodes.remove(verificationId);
    }

    return isValid;
  }

  @override
  Future<String> resendOTP(String phoneNumber) async {
    return sendOTP(phoneNumber);
  }

  @override
  Future<String?> getVerifiedPhoneNumber() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _verifiedPhoneNumber;
  }

  @override
  Future<void> savePhoneNumber(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _verifiedPhoneNumber = phoneNumber;
  }

  @override
  Future<void> removePhoneNumber() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _verifiedPhoneNumber = null;
  }

  String _generateVerificationId() {
    return 'VID_${_random.nextInt(999999).toString().padLeft(6, '0')}';
  }

  String _generateOTP() {
    return _random.nextInt(999999).toString().padLeft(6, '0');
  }
}
