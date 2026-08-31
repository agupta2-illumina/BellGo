# Firebase Integration Guide for BellGo

Complete guide to setting up and deploying Firebase SMS notifications for production.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Firebase Project Setup](#firebase-project-setup)
3. [Firebase CLI Setup](#firebase-cli-setup)
4. [Twilio Configuration](#twilio-configuration)
5. [Deploy Cloud Functions](#deploy-cloud-functions)
6. [Flutter App Configuration](#flutter-app-configuration)
7. [Running in Production Mode](#running-in-production-mode)
8. [Testing](#testing)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Accounts
- [ ] Firebase account (https://console.firebase.google.com)
- [ ] Twilio account (https://www.twilio.com)
- [ ] Node.js 18+ installed
- [ ] Firebase CLI installed

### Install Firebase CLI

```bash
npm install -g firebase-tools
firebase --version  # Verify installation
```

---

## Firebase Project Setup

### 1. Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click "Add project"
3. Enter project name: `bellgo-prod` (or your choice)
4. Enable Google Analytics (recommended)
5. Create project

### 2. Enable Authentication

1. In Firebase Console → Authentication
2. Click "Get Started"
3. Enable "Phone" sign-in method
4. Add your domain to authorized domains

### 3. Enable Firestore

1. In Firebase Console → Firestore Database
2. Click "Create database"
3. Start in **production mode**
4. Choose Cloud Firestore location (select closest to users)

### 4. Enable Cloud Functions

1. In Firebase Console → Functions
2. Click "Get Started"
3. Upgrade to Blaze (Pay as you go) plan
   - Required for Cloud Functions with external API calls (Twilio)
   - Free tier: 2M invocations/month

---

## Firebase CLI Setup

### 1. Login to Firebase

```bash
cd bellgo
firebase login
```

### 2. Initialize Firebase

```bash
firebase init
```

Select:
- [x] Functions
- [x] Firestore

Configuration:
- Use existing project: `bellgo-prod`
- Language: TypeScript
- Use ESLint: Yes
- Install dependencies: Yes

### 3. Link Project

```bash
firebase use --add
# Select your project
# Alias: default
```

---

## Twilio Configuration

### 1. Create Twilio Account

1. Sign up at https://www.twilio.com
2. Verify your email and phone
3. Get a Twilio phone number:
   - Console → Phone Numbers → Buy a number
   - Choose SMS-capable number

### 2. Get Twilio Credentials

From Twilio Console Dashboard:
- **Account SID**: `AC...`
- **Auth Token**: Click to reveal
- **Phone Number**: `+1234567890`

### 3. Configure Firebase Functions

```bash
cd functions

# Set Twilio credentials
firebase functions:config:set \
  twilio.account_sid="YOUR_ACCOUNT_SID" \
  twilio.auth_token="YOUR_AUTH_TOKEN" \
  twilio.phone_number="+1234567890"

# Verify configuration
firebase functions:config:get
```

---

## Deploy Cloud Functions

### 1. Install Dependencies

```bash
cd functions
npm install
```

### 2. Build TypeScript

```bash
npm run build
```

### 3. Test Locally (Optional)

```bash
# Install Firebase emulators
firebase init emulators
# Select Functions

# Start emulators
npm run serve
```

### 4. Deploy to Production

```bash
# Deploy all functions
firebase deploy --only functions

# Or deploy specific function
firebase deploy --only functions:sendLeaveTimeNotification
```

Expected output:
```
✔ functions[sendLeaveTimeNotification] Successful create operation.
✔ functions[sendScheduleChangeNotification] Successful create operation.
✔ functions[sendTestSms] Successful create operation.
✔ functions[sendDailyPickupReminders] Successful create operation.
```

### 5. Deploy Firestore Rules

```bash
firebase deploy --only firestore:rules
```

---

## Flutter App Configuration

### 1. Get Firebase Configuration

#### Option A: FlutterFire CLI (Recommended)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
cd ..  # Return to bellgo root
flutterfire configure \
  --project=bellgo-prod \
  --platforms=ios,android,web \
  --ios-bundle-id=com.bellgo.app \
  --android-package-name=com.bellgo.app
```

This generates `lib/firebase_options.dart` automatically.

#### Option B: Manual Configuration

1. Download config files from Firebase Console:
   - iOS: `GoogleService-Info.plist`
   - Android: `google-services.json`

2. Place files:
   ```
   ios/Runner/GoogleService-Info.plist
   android/app/google-services.json
   ```

3. Update `lib/firebase_options.dart` with your project credentials

### 2. Update iOS Configuration

**File: `ios/Runner/Info.plist`**

Add URL scheme:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>bellgo</string>
    </array>
  </dict>
</array>
```

**File: `ios/Podfile`**

```ruby
platform :ios, '13.0'

# Add Firebase SDK version
$FirebaseSDKVersion = '10.18.0'
```

Run:
```bash
cd ios
pod install
cd ..
```

### 3. Update Android Configuration

**File: `android/app/build.gradle`**

Add at top:
```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
    id "com.google.gms.google-services"  // Add this
}
```

Add dependencies:
```gradle
dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-functions'
    implementation 'com.google.firebase:firebase-firestore'
}
```

**File: `android/build.gradle`**

Add:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

---

## Running in Production Mode

### Development Mode (Mock Services - Default)

```bash
flutter run
```

### Production Mode (Firebase Services)

```bash
flutter run --dart-define=USE_FIREBASE=true
```

### Build Production Release

**iOS:**
```bash
flutter build ios \
  --release \
  --dart-define=USE_FIREBASE=true \
  --dart-define=FIREBASE_PROJECT_ID=bellgo-prod
```

**Android:**
```bash
flutter build apk \
  --release \
  --dart-define=USE_FIREBASE=true \
  --dart-define=FIREBASE_PROJECT_ID=bellgo-prod
```

**Web:**
```bash
flutter build web \
  --release \
  --dart-define=USE_FIREBASE=true
```

---

## Testing

### 1. Test Phone Verification

1. Run app in production mode
2. Go to Settings → Phone Number
3. Enter your phone number
4. Check Firebase Console → Authentication
   - Should see new user with phone number
5. Verify OTP code received via SMS

### 2. Test SMS Notifications

1. After phone verification, click "Send test SMS"
2. Check your phone for test message
3. Check Twilio Console → Logs
   - Should see SMS sent successfully

### 3. Test Cloud Functions

```bash
# View function logs
firebase functions:log

# Test function directly
curl -X POST \
  -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "phoneNumber": "+15551234567",
      "childName": "Test Child",
      "leaveTime": "2:42 PM",
      "dismissalTime": "3:05 PM"
    }
  }' \
  https://us-central1-bellgo-prod.cloudfunctions.net/sendLeaveTimeNotification
```

### 4. Check Firestore

Firebase Console → Firestore:
- `users/{userId}` - User phone data
- `notifications/{id}` - Notification log

---

## Troubleshooting

### Phone Verification Fails

**Error:** "The phone number format is invalid"
- Ensure number is in E.164 format: `+15551234567`
- Country code (+1) is required

**Error:** "reCAPTCHA verification failed"
- Add your domain to Firebase Console → Authentication → Settings → Authorized domains

### SMS Not Sending

**Error:** "Twilio credentials not found"
```bash
# Verify config
firebase functions:config:get

# Reset config if needed
firebase functions:config:set twilio.account_sid="AC..."
firebase deploy --only functions
```

**Error:** "Unable to send SMS"
- Check Twilio account balance
- Verify phone number is SMS-capable
- Check Twilio logs for errors

### Cloud Functions Error

**Error:** "Function deployment failed"
```bash
# Check Node version
node --version  # Should be 18+

# Reinstall dependencies
cd functions
rm -rf node_modules package-lock.json
npm install
npm run build
firebase deploy --only functions
```

**Error:** "CORS error when calling function"
- Functions are automatically CORS-enabled for authenticated requests
- Ensure user is signed in with Firebase Auth

### Build Errors

**iOS Pod Install Fails:**
```bash
cd ios
rm -rf Pods Podfile.lock
pod repo update
pod install
```

**Android Build Fails:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

---

## Cost Estimates

### Firebase (Blaze Plan)

**Free tier monthly:**
- Cloud Functions: 2M invocations
- Firestore: 50K reads, 20K writes
- Authentication: Unlimited

**Typical costs for 1,000 active users:**
- Functions: ~$5/month
- Firestore: ~$2/month
- **Total: ~$7/month**

### Twilio

**SMS Costs (US):**
- Outbound SMS: $0.0079/message
- Phone number: $1.15/month

**For 1,000 users, 2 SMS/day:**
- SMS: 2,000 messages × $0.0079 = $15.80/month
- Phone: $1.15/month
- **Total: ~$17/month**

### Total Monthly Cost
**~$24/month for 1,000 active users**

Scales linearly with usage.

---

## Production Checklist

- [ ] Firebase project created
- [ ] Blaze plan enabled
- [ ] Phone authentication enabled
- [ ] Twilio account configured
- [ ] Cloud Functions deployed
- [ ] Firestore rules deployed
- [ ] iOS app configured
- [ ] Android app configured
- [ ] Production build tested
- [ ] SMS delivery tested
- [ ] Monitoring setup (Firebase Console)

---

## Next Steps

1. **Configure monitoring:**
   - Firebase Console → Functions → Logs
   - Set up alerts for function errors

2. **Add scheduled notifications:**
   - Modify `sendDailyPickupReminders` function
   - Customize schedule and logic

3. **Implement retry logic:**
   - Add exponential backoff for failed SMS
   - Queue system for bulk notifications

4. **Add analytics:**
   - Track SMS delivery rates
   - Monitor user engagement

---

## Support

- Firebase docs: https://firebase.google.com/docs
- Twilio docs: https://www.twilio.com/docs
- FlutterFire: https://firebase.flutter.dev

## License

Proprietary - BellGo
