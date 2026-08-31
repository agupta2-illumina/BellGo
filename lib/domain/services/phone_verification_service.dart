/// Service for phone number verification via OTP
abstract class PhoneVerificationService {
  /// Send OTP to the phone number
  Future<String> sendOTP(String phoneNumber);

  /// Verify the OTP code
  Future<bool> verifyOTP(String verificationId, String otpCode);

  /// Resend OTP
  Future<String> resendOTP(String phoneNumber);

  /// Get current verified phone number
  Future<String?> getVerifiedPhoneNumber();

  /// Save verified phone number
  Future<void> savePhoneNumber(String phoneNumber);

  /// Remove phone number
  Future<void> removePhoneNumber();
}
