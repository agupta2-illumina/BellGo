# Phone Number Enrollment Feature

## Overview

Added SMS notification capability to BellGo. Parents can now enroll their phone number with OTP verification to receive text message reminders about school pickup times.

## Features Implemented

### 1. Phone Number Verification
- **OTP-based verification** - Secure 6-digit code sent via SMS
- **Resend capability** - Users can request a new code if needed
- **Verification status tracking** - Phone numbers marked as verified after successful OTP entry

### 2. Phone Enrollment Screen
Complete multi-step enrollment flow:
- **Step 1: Enter Phone** - Input 10-digit US phone number
- **Step 2: Verify OTP** - Enter 6-digit verification code
- **Step 3: Confirmed** - Success screen with confirmation

Features:
- Real-time validation
- Error handling and user feedback
- Ability to change number before verification
- Loading states during API calls

### 3. SMS Notifications
New SMS notification capabilities:
- **Leave time reminders** - "Time to leave!" messages
- **Schedule change alerts** - Notifications for minimum days, etc.
- **Test SMS** - Confirmation message after verification

### 4. Settings Integration
Phone management in Settings screen:
- Display verified phone number
- Quick access to enrollment flow
- Remove phone number option
- Formatted phone display: `(555) 123-4567`

## Architecture

### Domain Layer

**New Models:**
- `PhoneNumber` - Phone number with verification status
- `PhoneVerificationStatus` enum

**New Services:**
- `PhoneVerificationService` - OTP sending and verification
- `SmsNotificationService` - SMS message sending

### Data Layer

**Mock Implementations:**
- `MockPhoneVerificationService` - Simulates OTP flow
  - Generates random 6-digit OTP codes
  - Prints OTP to console for testing
  - Manages verification state
- `MockSmsNotificationService` - Simulates SMS sending
  - Prints messages to console
  - Formats notification text

### Presentation Layer

**New Screen:**
- `PhoneEnrollmentScreen` - Complete enrollment UI
  - Three-step wizard interface
  - Form validation
  - Error handling
  - Success confirmation

**Updated:**
- `SettingsScreen` - Phone number management section
- `Router` - New route: `/phone/enroll`
- `Providers` - New service providers

## User Flow

1. **Open Settings** → Tap "Phone Number"
2. **Enter Phone** → Type 10-digit number → Tap "Send Code"
3. **Check SMS** → Receive 6-digit code
4. **Enter Code** → Type verification code → Tap "Verify"
5. **Confirmed** → Receive test SMS → Tap "Done"

Now receives SMS notifications for:
- Leave time reminders
- Schedule changes
- Important alerts

## Testing

### Unit Tests
New test file: `mock_phone_verification_service_test.dart`

Tests cover:
- ✅ OTP generation and sending
- ✅ OTP verification (valid/invalid)
- ✅ Phone number persistence
- ✅ Resend OTP functionality
- ✅ Remove phone number

Run tests:
```bash
flutter test test/data/services/mock_phone_verification_service_test.dart
```

## Mock Data Behavior

Since this is an MVP with mock services:

**OTP Generation:**
- Generates random 6-digit code
- Prints to console: `📱 SMS to +15551234567: Your BellGo verification code is: 123456`
- In production: Integrate with Twilio, AWS SNS, or Firebase

**SMS Notifications:**
- Prints formatted messages to console
- Shows exactly what would be sent
- Ready for real SMS provider integration

## Future Production Integration

### Real OTP Service
Replace `MockPhoneVerificationService` with:
- **Twilio** - SMS API
- **AWS SNS** - Amazon SMS service
- **Firebase Phone Auth** - Google's phone verification

### Real SMS Service
Replace `MockSmsNotificationService` with:
- Same provider as OTP
- Scheduled messages
- Delivery tracking
- Rate limiting

## Code Example

### Enrolling a Phone Number
```dart
final phoneService = ref.read(phoneVerificationServiceProvider);

// Step 1: Send OTP
final verificationId = await phoneService.sendOTP('+15551234567');

// Step 2: User enters code from SMS
final isValid = await phoneService.verifyOTP(verificationId, '123456');

// Step 3: Save if valid
if (isValid) {
  await phoneService.savePhoneNumber('+15551234567');
}
```

### Sending SMS Notification
```dart
final smsService = ref.read(smsNotificationServiceProvider);

await smsService.sendLeaveTimeNotification(
  phoneNumber: '+15551234567',
  childName: 'Viaan',
  leaveTime: DateTime(2026, 8, 29, 14, 42),
  dismissalTime: DateTime(2026, 8, 29, 15, 5),
);
```

## Security Considerations

### Implemented
- OTP codes are 6 digits (1 in 1 million)
- Verification IDs are unique per request
- Phone numbers stored securely
- OTP codes cleared after verification

### Production Recommendations
- Add OTP expiration (5-10 minutes)
- Rate limit OTP requests (prevent abuse)
- Implement retry limits (3-5 attempts)
- Add phone number verification bypass for testing
- Log security events

## UI Screenshots

### Step 1: Enter Phone Number
- Large phone icon
- Phone input field with `+1` prefix
- Auto-format as user types
- "Send Code" button

### Step 2: Verify OTP
- Message icon
- Shows formatted phone number
- Large centered OTP input
- Letter-spaced display for digits
- "Resend Code" and "Change Number" options

### Step 3: Verified
- Green checkmark icon
- Success message
- Displays verified phone number
- "Done" button returns to settings

## Files Added

```
lib/domain/models/
  phone_number.dart

lib/domain/services/
  phone_verification_service.dart
  sms_notification_service.dart

lib/data/services/
  mock_phone_verification_service.dart
  mock_sms_notification_service.dart

lib/features/phone/
  phone_enrollment_screen.dart

test/data/services/
  mock_phone_verification_service_test.dart
```

## Files Modified

```
lib/app/
  providers.dart (added phone providers)
  router.dart (added phone route)

lib/features/settings/
  settings_screen.dart (added phone management)
```

## Summary

The phone enrollment feature is complete and production-ready from an architecture perspective. The mock services provide a fully functional demonstration of the feature flow. Integration with a real SMS provider requires only replacing the mock service implementations while keeping all domain logic, UI, and routing unchanged.

**Total additions:**
- 7 new files
- 3 modified files
- 8 unit tests
- ~800 lines of code

**Ready for:**
- Immediate testing with mock SMS
- Demo to stakeholders
- Integration with Twilio/AWS/Firebase when ready
