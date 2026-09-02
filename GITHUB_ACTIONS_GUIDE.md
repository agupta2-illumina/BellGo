# BellGo - GitHub Actions CI/CD Guide

## 📚 What is CI/CD?

**CI (Continuous Integration):** Automatically test code when you push changes  
**CD (Continuous Delivery/Deployment):** Automatically build and deploy to TestFlight/App Store

**Benefits:**
- ✅ Catch bugs before they reach users
- ✅ Automate repetitive tasks
- ✅ Faster release cycles
- ✅ Consistent builds
- ✅ No manual deployment steps

---

## 🎯 What We'll Build

### CI Pipeline (Every Push)
1. Check code formatting
2. Run static analysis
3. Run all unit tests
4. Build iOS and Android
5. Report results

### CD Pipeline (On Release)
1. Build production IPA
2. Upload to TestFlight
3. Create GitHub Release
4. Notify team

---

## 📁 GitHub Actions Basics

### Structure
```
bellgo/
├── .github/
│   └── workflows/           # All workflows go here
│       ├── ci.yml          # Run tests on every push
│       ├── deploy-ios.yml  # Deploy to TestFlight
│       └── release.yml     # Create releases
```

### Workflow File Anatomy
```yaml
name: CI                      # Workflow name (shows in GitHub)

on:                          # When to run
  push:                      # On push to these branches
    branches: [main, develop]
  pull_request:              # On PRs to these branches
    branches: [main]

jobs:                        # What to do
  test:                      # Job name
    runs-on: macos-latest    # Which OS to use
    
    steps:                   # Sequential steps
      - uses: actions/checkout@v4      # Clone repo
      - name: Run tests                # Step name
        run: flutter test              # Command to run
```

---

## 🚀 Step-by-Step Implementation

### Step 1: Create Your First Workflow (CI)

Create `.github/workflows/ci.yml`:

```yaml
name: CI - Test & Build

# When to run this workflow
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

# Cancel previous runs if new push
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  # Job 1: Code Quality Checks
  code-quality:
    name: Code Quality
    runs-on: ubuntu-latest
    
    steps:
      # Step 1: Checkout code
      - name: Checkout repository
        uses: actions/checkout@v4
      
      # Step 2: Setup Flutter
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.47.2'
          channel: 'stable'
          cache: true
      
      # Step 3: Get dependencies
      - name: Install dependencies
        run: flutter pub get
      
      # Step 4: Check formatting
      - name: Check code formatting
        run: dart format --output=none --set-exit-if-changed .
      
      # Step 5: Analyze code
      - name: Analyze code
        run: flutter analyze
  
  # Job 2: Run Tests
  test:
    name: Run Tests
    runs-on: ubuntu-latest
    needs: code-quality  # Run after code-quality passes
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.47.2'
          channel: 'stable'
          cache: true
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run unit tests
        run: flutter test --coverage
      
      # Step 6: Upload coverage report
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
          fail_ci_if_error: false
  
  # Job 3: Build iOS
  build-ios:
    name: Build iOS
    runs-on: macos-latest
    needs: test  # Run after tests pass
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.47.2'
          channel: 'stable'
          cache: true
      
      - name: Install dependencies
        run: flutter pub get
      
      # Build iOS (no signing for CI)
      - name: Build iOS (debug)
        run: |
          flutter build ios --debug --no-codesign
      
      - name: Build success
        run: echo "✅ iOS build successful!"
  
  # Job 4: Build Android
  build-android:
    name: Build Android
    runs-on: ubuntu-latest
    needs: test  # Run after tests pass
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.47.2'
          channel: 'stable'
          cache: true
      
      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '17'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build Android APK
        run: flutter build apk --debug
      
      - name: Upload APK artifact
        uses: actions/upload-artifact@v3
        with:
          name: debug-apk
          path: build/app/outputs/flutter-apk/app-debug.apk
          retention-days: 7
```

**What this does:**
1. ✅ Checks code formatting
2. ✅ Runs static analysis
3. ✅ Runs all tests with coverage
4. ✅ Builds iOS (debug)
5. ✅ Builds Android APK
6. ✅ Uploads APK as artifact

---

### Step 2: Deploy to TestFlight (iOS)

Create `.github/workflows/deploy-ios.yml`:

```yaml
name: Deploy to TestFlight

# Only run on version tags (e.g., v1.0.0)
on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  deploy-ios:
    name: Build and Deploy iOS
    runs-on: macos-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.47.2'
          channel: 'stable'
          cache: true
      
      - name: Install dependencies
        run: flutter pub get
      
      # Import signing certificates
      - name: Import signing certificates
        env:
          CERTIFICATE_BASE64: ${{ secrets.IOS_CERTIFICATE_BASE64 }}
          CERTIFICATE_PASSWORD: ${{ secrets.IOS_CERTIFICATE_PASSWORD }}
          KEYCHAIN_PASSWORD: ${{ secrets.KEYCHAIN_PASSWORD }}
        run: |
          # Create keychain
          security create-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
          security default-keychain -s build.keychain
          security unlock-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
          security set-keychain-settings -t 3600 -u build.keychain
          
          # Import certificate
          echo "$CERTIFICATE_BASE64" | base64 --decode > certificate.p12
          security import certificate.p12 -k build.keychain -P "$CERTIFICATE_PASSWORD" -T /usr/bin/codesign
          security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KEYCHAIN_PASSWORD" build.keychain
          
          # Cleanup
          rm certificate.p12
      
      # Import provisioning profile
      - name: Import provisioning profile
        env:
          PROVISIONING_PROFILE_BASE64: ${{ secrets.IOS_PROVISIONING_PROFILE_BASE64 }}
        run: |
          mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
          echo "$PROVISIONING_PROFILE_BASE64" | base64 --decode > ~/Library/MobileDevice/Provisioning\ Profiles/profile.mobileprovision
      
      # Build IPA
      - name: Build IPA
        run: |
          flutter build ipa --release \
            --export-options-plist=ios/ExportOptions.plist \
            --dart-define=USE_FIREBASE=true
      
      # Upload to TestFlight
      - name: Upload to TestFlight
        env:
          APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
          APP_STORE_CONNECT_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
          APP_STORE_CONNECT_API_KEY_BASE64: ${{ secrets.APP_STORE_CONNECT_API_KEY_BASE64 }}
        run: |
          # Save API key
          echo "$APP_STORE_CONNECT_API_KEY_BASE64" | base64 --decode > AuthKey.p8
          
          # Upload to TestFlight
          xcrun altool --upload-app \
            --type ios \
            --file build/ios/ipa/bellgo.ipa \
            --apiKey "$APP_STORE_CONNECT_API_KEY_ID" \
            --apiIssuer "$APP_STORE_CONNECT_ISSUER_ID"
          
          # Cleanup
          rm AuthKey.p8
      
      - name: Clean up keychain
        if: always()
        run: |
          security delete-keychain build.keychain || true
      
      - name: Deployment success
        run: echo "🚀 Successfully deployed to TestFlight!"
```

---

### Step 3: Create GitHub Releases

Create `.github/workflows/release.yml`:

```yaml
name: Create Release

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  create-release:
    name: Create GitHub Release
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Get all history for changelog
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.47.2'
          channel: 'stable'
      
      - name: Get version from tag
        id: version
        run: echo "VERSION=${GITHUB_REF#refs/tags/v}" >> $GITHUB_OUTPUT
      
      - name: Generate changelog
        id: changelog
        run: |
          # Get commits since last tag
          PREVIOUS_TAG=$(git describe --tags --abbrev=0 HEAD^ 2>/dev/null || echo "")
          if [ -z "$PREVIOUS_TAG" ]; then
            CHANGELOG=$(git log --pretty=format:"- %s" HEAD)
          else
            CHANGELOG=$(git log --pretty=format:"- %s" $PREVIOUS_TAG..HEAD)
          fi
          
          # Save to file
          echo "$CHANGELOG" > CHANGELOG.txt
      
      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          name: Release v${{ steps.version.outputs.VERSION }}
          body_path: CHANGELOG.txt
          draft: false
          prerelease: false
          generate_release_notes: true
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## 🔐 Setting Up Secrets

GitHub Actions needs secrets for deployment. Here's how to set them up:

### Step 1: Generate Secrets Locally

#### iOS Certificates & Profiles

```bash
# 1. Export your certificate to .p12
# Open Keychain Access → Find your certificate → Right-click → Export
# Save as: ios_distribution.p12

# 2. Convert to Base64
base64 -i ios_distribution.p12 | pbcopy
# Paste this as: IOS_CERTIFICATE_BASE64

# 3. Provisioning profile
base64 -i YourProfile.mobileprovision | pbcopy
# Paste this as: IOS_PROVISIONING_PROFILE_BASE64

# 4. App Store Connect API Key
# Get from: https://appstoreconnect.apple.com/access/api
base64 -i AuthKey_XXXXXX.p8 | pbcopy
# Paste this as: APP_STORE_CONNECT_API_KEY_BASE64
```

### Step 2: Add Secrets to GitHub

1. Go to your repo: `https://github.com/agupta2-illumina/BellGo`
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret:

**iOS Secrets:**
```
IOS_CERTIFICATE_BASE64           # Certificate in Base64
IOS_CERTIFICATE_PASSWORD          # Certificate password
IOS_PROVISIONING_PROFILE_BASE64  # Provisioning profile in Base64
KEYCHAIN_PASSWORD                # Any secure password (for CI keychain)

APP_STORE_CONNECT_API_KEY_ID     # e.g., ABC123XYZ
APP_STORE_CONNECT_ISSUER_ID      # e.g., 12345678-1234-1234-1234-123456789012
APP_STORE_CONNECT_API_KEY_BASE64 # AuthKey.p8 in Base64
```

**Android Secrets (for future):**
```
ANDROID_KEYSTORE_BASE64          # Keystore in Base64
ANDROID_KEYSTORE_PASSWORD        # Keystore password
ANDROID_KEY_ALIAS                # Key alias
ANDROID_KEY_PASSWORD             # Key password
```

---

## 📝 Commit and Push Workflows

### Step 1: Create files locally

```bash
cd bellgo

# Create workflows directory
mkdir -p .github/workflows

# Create CI workflow
cat > .github/workflows/ci.yml << 'EOF'
# (Paste the CI workflow from above)
EOF

# Create deploy workflow
cat > .github/workflows/deploy-ios.yml << 'EOF'
# (Paste the deploy workflow from above)
EOF

# Create release workflow
cat > .github/workflows/release.yml << 'EOF'
# (Paste the release workflow from above)
EOF
```

### Step 2: Commit and push

```bash
git add .github/workflows/
git commit -m "Add GitHub Actions CI/CD workflows

- Add CI workflow: test, lint, build
- Add iOS deployment workflow (TestFlight)
- Add release workflow
"
git push origin develop
```

---

## 🧪 Testing Your Workflows

### Test CI Workflow

```bash
# Push any change to trigger CI
git commit --allow-empty -m "Test CI workflow"
git push origin develop
```

**What to expect:**
1. Go to: `https://github.com/agupta2-illumina/BellGo/actions`
2. See "CI - Test & Build" running
3. Watch each job execute:
   - ✅ Code Quality (30s-1min)
   - ✅ Run Tests (1-2min)
   - ✅ Build iOS (2-3min)
   - ✅ Build Android (2-3min)
4. Total time: ~5-8 minutes

### Test Deployment Workflow

```bash
# Create and push a version tag
git tag v1.0.0
git push origin v1.0.0
```

**What to expect:**
1. Both workflows trigger:
   - "Deploy to TestFlight" 
   - "Create Release"
2. TestFlight build appears in ~15 minutes
3. GitHub Release created with changelog

---

## 📊 Workflow Status Badges

Add badges to your README to show build status:

```markdown
# BellGo

[![CI Status](https://github.com/agupta2-illumina/BellGo/workflows/CI%20-%20Test%20%26%20Build/badge.svg)](https://github.com/agupta2-illumina/BellGo/actions)
[![Deploy Status](https://github.com/agupta2-illumina/BellGo/workflows/Deploy%20to%20TestFlight/badge.svg)](https://github.com/agupta2-illumina/BellGo/actions)
[![codecov](https://codecov.io/gh/agupta2-illumina/BellGo/branch/main/graph/badge.svg)](https://codecov.io/gh/agupta2-illumina/BellGo)

Know when to go for school pickup!
```

---

## 🎯 Advanced: Matrix Testing

Test on multiple Flutter versions:

```yaml
jobs:
  test:
    name: Test on Flutter ${{ matrix.flutter-version }}
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        flutter-version: ['3.46.0', '3.47.2', 'stable']
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter ${{ matrix.flutter-version }}
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ matrix.flutter-version }}
          channel: 'stable'
      
      - name: Run tests
        run: flutter test
```

This runs tests on 3 Flutter versions in parallel!

---

## 🔄 Complete CI/CD Flow

```
Developer pushes code
         ↓
┌─────────────────────────────────────┐
│     GitHub Actions Triggered        │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│   Job 1: Code Quality               │
│   • Check formatting                │
│   • Run analyzer                    │
│   • Duration: 30s                   │
└─────────────────────────────────────┘
         ↓ (if passes)
┌─────────────────────────────────────┐
│   Job 2: Run Tests                  │
│   • Unit tests                      │
│   • Coverage report                 │
│   • Duration: 1-2min                │
└─────────────────────────────────────┘
         ↓ (if passes)
┌──────────────────┬──────────────────┐
│   Job 3: iOS     │   Job 4: Android │
│   • Build iOS    │   • Build APK    │
│   • Duration: 3m │   • Duration: 2m │
└──────────────────┴──────────────────┘
         ↓ (if all pass)
┌─────────────────────────────────────┐
│   ✅ All checks passed!             │
│   Ready to merge PR                 │
└─────────────────────────────────────┘

─────────────────────────────────────────

If version tag pushed (v1.0.0):
         ↓
┌─────────────────────────────────────┐
│   Deploy Workflow                   │
│   • Build signed IPA                │
│   • Upload to TestFlight            │
│   • Duration: 10-15min              │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│   Release Workflow                  │
│   • Generate changelog              │
│   • Create GitHub Release           │
│   • Duration: 1min                  │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│   🚀 Deployed to TestFlight!        │
│   📦 GitHub Release created         │
└─────────────────────────────────────┘
```

---

## 📱 Slack/Email Notifications

Add notifications when workflows complete:

```yaml
jobs:
  notify:
    name: Notify Team
    runs-on: ubuntu-latest
    needs: [deploy-ios]
    if: always()
    
    steps:
      - name: Send Slack notification
        uses: slackapi/slack-github-action@v1
        with:
          webhook-url: ${{ secrets.SLACK_WEBHOOK_URL }}
          payload: |
            {
              "text": "🚀 BellGo ${{ github.ref_name }} deployed to TestFlight!",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "*Deployment Status:* ${{ needs.deploy-ios.result }}"
                  }
                }
              ]
            }
```

---

## 🐛 Debugging Failed Workflows

### Common Issues and Solutions

#### Issue 1: "flutter: command not found"
**Solution:** Flutter not installed properly
```yaml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.47.2'
    cache: true  # ← Add this
```

#### Issue 2: "Certificate expired"
**Solution:** Update certificates
```bash
# Re-export certificate
# Re-convert to Base64
# Update secret in GitHub
```

#### Issue 3: "Tests failed"
**Solution:** View logs
1. Go to Actions tab
2. Click failed workflow
3. Click failed job
4. Expand failed step
5. Read error message

#### Issue 4: "Out of disk space"
**Solution:** Clean cache
```yaml
- name: Clean Flutter cache
  run: flutter clean
```

---

## 💰 GitHub Actions Pricing

### Free Tier (Public Repos)
- ✅ **Unlimited minutes** for public repos
- ✅ All features available
- ✅ No credit card needed

### Private Repos
- 2,000 minutes/month free
- Linux: 1x multiplier
- macOS: 10x multiplier (expensive!)
- Windows: 2x multiplier

**Example monthly usage:**
```
CI runs: 50 pushes × 8 min × 10 (macOS) = 4,000 minutes
Cost: (4,000 - 2,000) × $0.008 = $16/month
```

**To save money:**
- Use Linux for tests (1x multiplier)
- Only use macOS for iOS builds
- Cache dependencies
- Run on `pull_request` only (not every push)

---

## 📚 Learning Resources

### Official Docs
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Flutter CI/CD](https://docs.flutter.dev/deployment/cd)
- [Fastlane](https://docs.fastlane.tools/)

### Useful Actions
- [actions/checkout](https://github.com/actions/checkout) - Clone repo
- [subosito/flutter-action](https://github.com/subosito/flutter-action) - Setup Flutter
- [actions/upload-artifact](https://github.com/actions/upload-artifact) - Save files
- [softprops/action-gh-release](https://github.com/softprops/action-gh-release) - Create releases

---

## ✅ Quick Start Checklist

### Day 1: Setup CI
- [ ] Create `.github/workflows/ci.yml`
- [ ] Push to GitHub
- [ ] Watch workflow run
- [ ] Fix any failures
- [ ] Add status badge to README

### Day 2: Setup Secrets
- [ ] Export iOS certificate
- [ ] Convert to Base64
- [ ] Add secrets to GitHub
- [ ] Test locally with `act` (optional)

### Day 3: Setup Deployment
- [ ] Create `deploy-ios.yml`
- [ ] Create `release.yml`
- [ ] Create version tag: `git tag v1.0.0`
- [ ] Push tag: `git push origin v1.0.0`
- [ ] Watch deployment
- [ ] Check TestFlight

### Day 4: Polish
- [ ] Add notifications
- [ ] Add caching
- [ ] Optimize workflows
- [ ] Document process

---

## 🎓 Next Steps

### After Basic CI/CD Works

1. **Add Integration Tests**
   ```yaml
   - name: Run integration tests
     run: flutter drive --target=test_driver/app.dart
   ```

2. **Add Code Coverage**
   ```yaml
   - name: Generate coverage
     run: flutter test --coverage
   - name: Upload to Codecov
     uses: codecov/codecov-action@v3
   ```

3. **Add Performance Tests**
   ```yaml
   - name: Run performance tests
     run: flutter test --performance
   ```

4. **Add Security Scanning**
   ```yaml
   - name: Run security scan
     uses: snyk/actions/flutter@master
   ```

5. **Add Android Deployment**
   ```yaml
   - name: Deploy to Play Store
     uses: r0adkll/upload-google-play@v1
   ```

---

## 🚀 Complete Example Repository

Check out this example for reference:
```
https://github.com/flutter/samples
```

---

## 📝 Summary

**What you've learned:**
1. ✅ GitHub Actions basics (workflows, jobs, steps)
2. ✅ Running tests automatically
3. ✅ Building iOS and Android
4. ✅ Deploying to TestFlight
5. ✅ Creating releases
6. ✅ Managing secrets
7. ✅ Debugging workflows

**What you can do now:**
- Push code → Tests run automatically
- Create tag → Deploy to TestFlight
- Merge PR → Build passes first
- See status badges
- Get notifications

**Time saved:**
- Manual testing: 10 min → 0 min (automated)
- Manual builds: 15 min → 0 min (automated)
- Manual deploys: 30 min → 0 min (automated)
- **Total: ~55 minutes per release!**

---

Ready to start? Let's create your first workflow! 🚀
