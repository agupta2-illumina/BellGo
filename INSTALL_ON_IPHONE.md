# Installing BellGo on Your iPhone

## Quick Start: USB Installation (Recommended)

### Prerequisites
- Mac with Xcode installed
- iPhone with USB cable
- Apple Developer account (free tier works)

### Steps

1. **Install Xcode** (if not already installed)
```bash
# Check if Xcode is installed
xcode-select --install

# Or download from Mac App Store
# Search for "Xcode" and install (large download, ~15GB)
```

2. **Connect iPhone to Mac**
- Plug in iPhone via USB cable
- Unlock iPhone and trust the computer when prompted

3. **Configure Xcode**
```bash
cd bellgo
open ios/Runner.xcworkspace
```

In Xcode:
- Click on "Runner" in the left sidebar
- Go to "Signing & Capabilities" tab
- Select your Apple ID under "Team"
- Change Bundle Identifier if needed: `com.yourname.bellgo`

4. **Select Your iPhone**
- Top toolbar: Select your iPhone from device dropdown
- Should show "Your iPhone's Name"

5. **Run the App**
```bash
# From terminal (recommended)
cd bellgo
flutter run

# Or in Xcode: Click the Play button ▶️
```

6. **Trust Developer on iPhone**
- First launch will fail with "Untrusted Developer"
- On iPhone: Settings → General → VPN & Device Management
- Tap your Apple ID → Trust

7. **Launch App**
- Tap BellGo icon on your iPhone home screen
- App should open!

**Time: ~5 minutes after Xcode setup**

---

## Option 2: TestFlight (Best for Beta Testing)

Share the app with others or test like a real App Store app.

### Setup Steps

1. **Enroll in Apple Developer Program** ($99/year)
   - Go to https://developer.apple.com/programs/
   - Complete enrollment

2. **Create App in App Store Connect**
```bash
# Go to https://appstoreconnect.apple.com
# Click "My Apps" → "+" → "New App"

Bundle ID: com.yourname.bellgo
Name: BellGo
Language: English
SKU: bellgo-001
```

3. **Build Archive**
```bash
cd bellgo

# Build iOS archive
flutter build ipa --release

# Or with Firebase
flutter build ipa --release --dart-define=USE_FIREBASE=true
```

4. **Upload to App Store Connect**
```bash
# Open Xcode
open ios/Runner.xcworkspace

# In Xcode menu:
# Product → Archive
# (Wait for build to complete)

# When Archive Organizer appears:
# Click "Distribute App"
# Select "App Store Connect"
# Click "Upload"
```

5. **Configure TestFlight**
- Go to App Store Connect → TestFlight tab
- Add yourself as internal tester
- Wait for processing (~10 minutes)
- Install TestFlight app on iPhone
- Accept invitation and install BellGo

**Time: ~30 minutes (first time), ~5 minutes (updates)**

---

## Option 3: Ad-Hoc Distribution (Without Developer Program)

For personal use or small team (up to 100 devices).

### Using Free Apple Developer Account

1. **Register Devices**
```bash
# Get your iPhone UDID
# Connect iPhone to Mac
# Open Finder → Click on iPhone → Click on device info
# Copy UDID
```

2. **Build for Device**
```bash
cd bellgo

# Build signed IPA
flutter build ipa --export-options-plist=ios/exportOptions.plist
```

3. **Install via iTunes or Xcode**
- Drag `.ipa` file to Xcode Devices window
- Or use third-party tools like Diawi

---

## Troubleshooting

### "Unable to install"
**Solution:** Bundle ID conflict
```bash
# Change bundle ID in Xcode
# Runner → General → Bundle Identifier
# Use: com.yourname.bellgo
```

### "Untrusted Developer"
**Solution:** Trust your certificate
```
iPhone: Settings → General → VPN & Device Management
→ Tap your Apple ID → Trust
```

### "Xcode build failed"
**Solution:** Clean and rebuild
```bash
cd bellgo/ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

### "Provisioning profile error"
**Solution:** Automatic signing
```
Xcode → Runner → Signing & Capabilities
☑️ Automatically manage signing
Select your team
```

---

## Comparison

| Method | Cost | Time | Best For |
|--------|------|------|----------|
| USB Install | Free | 5 min | Quick testing |
| TestFlight | $99/year | 30 min | Beta testing, sharing |
| Ad-Hoc | Free | 15 min | Personal use |
| App Store | $99/year | Days | Public release |

---

## Recommended Path

**For personal testing:**
1. Start with USB installation (Option 1)
2. Test all features
3. Use Firebase in dev mode (mock SMS)

**For real testing:**
1. Setup Firebase
2. Deploy Cloud Functions
3. Run with `--dart-define=USE_FIREBASE=true`
4. Test real SMS notifications

**For sharing with others:**
1. Use TestFlight (Option 2)
2. Invite beta testers
3. Collect feedback

---

## Quick Commands

### Development Build (Mock SMS)
```bash
cd bellgo
flutter run
```

### Production Build (Real SMS)
```bash
flutter run --dart-define=USE_FIREBASE=true
```

### Release Build for TestFlight
```bash
flutter build ipa --release --dart-define=USE_FIREBASE=true
```

---

## Next Steps

1. **Connect iPhone** to Mac via USB
2. **Run** `flutter run` from bellgo directory
3. **Trust developer** on iPhone in Settings
4. **Launch** BellGo app
5. **Test** the enrollment and notification features

Need help with any step? Let me know!
