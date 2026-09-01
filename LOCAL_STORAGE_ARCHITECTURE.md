# BellGo - Local Storage Technical Architecture

## Overview

BellGo implements a **local-first data architecture** where all user data is stored on the device. Authentication via Google or Apple ID is used solely for identity verification and optional cloud backup, but the primary data store remains on the user's phone.

## Architecture Principles

### 1. Local-First Strategy
- ✅ All data stored on device
- ✅ App works offline by default
- ✅ No server dependency for core features
- ✅ Fast, instant access
- ✅ User data privacy and control

### 2. Authentication Purpose
- Identity verification only
- Optional cloud backup/sync
- Multi-device support (optional)
- Account recovery

### 3. Data Ownership
- User owns all data
- Data stays on device
- User can export/delete anytime
- No server-side processing required

---

## Technical Stack

### Local Storage Technologies

#### 1. Hive (Primary Database)
**Purpose:** Structured data storage (children, locations, schedules)

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.0
```

**Why Hive:**
- ✅ Fast (NoSQL, key-value store)
- ✅ Lightweight (~1.5 MB)
- ✅ No native dependencies
- ✅ Type-safe with code generation
- ✅ Encryption support built-in
- ✅ Works on all platforms (iOS, Android, Web)

#### 2. SharedPreferences (Settings)
**Purpose:** Simple key-value storage for user preferences

```yaml
dependencies:
  shared_preferences: ^2.2.0
```

**What to store:**
- Notification preferences
- Travel buffer settings
- UI preferences
- Last selected child/location
- Onboarding completion

#### 3. Flutter Secure Storage (Sensitive Data)
**Purpose:** Encrypted storage for authentication tokens

```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

**What to store:**
- OAuth tokens (Google/Apple)
- User ID
- Phone number (if enrolled)
- Encryption keys

---

## Data Model

### Hive Boxes (Collections)

#### Box 1: Users
```dart
@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  String id; // Google/Apple user ID
  
  @HiveField(1)
  String email;
  
  @HiveField(2)
  String? displayName;
  
  @HiveField(3)
  String? photoUrl;
  
  @HiveField(4)
  AuthProvider provider; // google, apple
  
  @HiveField(5)
  DateTime createdAt;
  
  @HiveField(6)
  DateTime lastLoginAt;
  
  @HiveField(7)
  String? phoneNumber;
  
  @HiveField(8)
  bool phoneVerified;
}
```

#### Box 2: Children
```dart
@HiveType(typeId: 1)
class Child extends HiveObject {
  @HiveField(0)
  String id; // UUID
  
  @HiveField(1)
  String firstName;
  
  @HiveField(2)
  String lastName;
  
  @HiveField(3)
  int grade;
  
  @HiveField(4)
  String schoolId; // Reference to School
  
  @HiveField(5)
  DateTime createdAt;
  
  @HiveField(6)
  DateTime updatedAt;
  
  @HiveField(7)
  int pickupBuffer; // minutes
  
  @HiveField(8)
  int reminderTime; // minutes
  
  @HiveField(9)
  bool notificationsEnabled;
}
```

#### Box 3: Schools
```dart
@HiveType(typeId: 2)
class School extends HiveObject {
  @HiveField(0)
  String id; // UUID
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  String address;
  
  @HiveField(3)
  String city;
  
  @HiveField(4)
  String state;
  
  @HiveField(5)
  String zipCode;
  
  @HiveField(6)
  double latitude;
  
  @HiveField(7)
  double longitude;
  
  @HiveField(8)
  int minGrade;
  
  @HiveField(9)
  int maxGrade;
  
  @HiveField(10)
  BellSchedule bellSchedule;
  
  @HiveField(11)
  bool isCustom; // User-created school
  
  @HiveField(12)
  DateTime createdAt;
}
```

#### Box 4: Locations
```dart
@HiveType(typeId: 3)
class Location extends HiveObject {
  @HiveField(0)
  String id; // UUID
  
  @HiveField(1)
  String name; // "Home", "Work", "Custom"
  
  @HiveField(2)
  LocationType type; // home, work, custom
  
  @HiveField(3)
  String address;
  
  @HiveField(4)
  String city;
  
  @HiveField(5)
  String state;
  
  @HiveField(6)
  String zipCode;
  
  @HiveField(7)
  double latitude;
  
  @HiveField(8)
  double longitude;
  
  @HiveField(9)
  bool isDefault;
  
  @HiveField(10)
  DateTime createdAt;
}
```

#### Box 5: Day Schedules
```dart
@HiveType(typeId: 4)
class DaySchedule extends HiveObject {
  @HiveField(0)
  String id; // UUID
  
  @HiveField(1)
  String schoolId; // Reference to School
  
  @HiveField(2)
  DateTime date;
  
  @HiveField(3)
  ScheduleType type; // regular, earlyRelease, minimumDay, holiday, noSchool
  
  @HiveField(4)
  DateTime? dismissalTime;
  
  @HiveField(5)
  String? notes;
  
  @HiveField(6)
  bool isCustom; // User manually set
  
  @HiveField(7)
  DateTime createdAt;
  
  @HiveField(8)
  DateTime updatedAt;
}
```

#### Box 6: Travel Time Cache
```dart
@HiveType(typeId: 5)
class TravelTimeCache extends HiveObject {
  @HiveField(0)
  String id; // "{originId}_{destinationId}"
  
  @HiveField(1)
  String originId;
  
  @HiveField(2)
  String destinationId;
  
  @HiveField(3)
  Duration travelTime;
  
  @HiveField(4)
  DateTime calculatedAt;
  
  @HiveField(5)
  DateTime expiresAt; // Refresh after 7 days
}
```

---

## Storage Implementation

### Directory Structure

```
lib/
├── data/
│   ├── local/
│   │   ├── hive_service.dart              # Hive initialization
│   │   ├── secure_storage_service.dart    # Secure storage wrapper
│   │   ├── preferences_service.dart       # SharedPreferences wrapper
│   │   ├── models/                        # Hive type adapters
│   │   │   ├── user_profile.dart
│   │   │   ├── user_profile.g.dart        # Generated
│   │   │   ├── child.dart
│   │   │   ├── child.g.dart
│   │   │   ├── school.dart
│   │   │   ├── location.dart
│   │   │   ├── day_schedule.dart
│   │   │   └── travel_time_cache.dart
│   │   └── repositories/
│   │       ├── local_user_repository.dart
│   │       ├── local_child_repository.dart
│   │       ├── local_school_repository.dart
│   │       ├── local_location_repository.dart
│   │       └── local_schedule_repository.dart
│   └── auth/
│       ├── google_auth_service.dart
│       ├── apple_auth_service.dart
│       └── auth_repository.dart
```

### Core Services

#### 1. Hive Service (Initialization)

```dart
// lib/data/local/hive_service.dart
class HiveService {
  static const String userBox = 'users';
  static const String childrenBox = 'children';
  static const String schoolsBox = 'schools';
  static const String locationsBox = 'locations';
  static const String schedulesBox = 'schedules';
  static const String travelCacheBox = 'travel_cache';
  
  Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();
    
    // Register type adapters
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(ChildAdapter());
    Hive.registerAdapter(SchoolAdapter());
    Hive.registerAdapter(LocationAdapter());
    Hive.registerAdapter(DayScheduleAdapter());
    Hive.registerAdapter(TravelTimeCacheAdapter());
    Hive.registerAdapter(AuthProviderAdapter());
    Hive.registerAdapter(LocationTypeAdapter());
    Hive.registerAdapter(ScheduleTypeAdapter());
    Hive.registerAdapter(BellScheduleAdapter());
    
    // Open boxes
    await Hive.openBox<UserProfile>(userBox);
    await Hive.openBox<Child>(childrenBox);
    await Hive.openBox<School>(schoolsBox);
    await Hive.openBox<Location>(locationsBox);
    await Hive.openBox<DaySchedule>(schedulesBox);
    await Hive.openBox<TravelTimeCache>(travelCacheBox);
  }
  
  Future<void> clearAll() async {
    await Hive.box<UserProfile>(userBox).clear();
    await Hive.box<Child>(childrenBox).clear();
    await Hive.box<School>(schoolsBox).clear();
    await Hive.box<Location>(locationsBox).clear();
    await Hive.box<DaySchedule>(schedulesBox).clear();
    await Hive.box<TravelTimeCache>(travelCacheBox).clear();
  }
  
  Future<void> close() async {
    await Hive.close();
  }
}
```

#### 2. Repository Example (Children)

```dart
// lib/data/local/repositories/local_child_repository.dart
class LocalChildRepository implements ChildRepository {
  final Box<Child> _box;
  
  LocalChildRepository(this._box);
  
  @override
  Future<List<Child>> getAll() async {
    return _box.values.toList();
  }
  
  @override
  Future<Child?> getById(String id) async {
    return _box.get(id);
  }
  
  @override
  Future<void> add(Child child) async {
    await _box.put(child.id, child);
  }
  
  @override
  Future<void> update(Child child) async {
    child.updatedAt = DateTime.now();
    await _box.put(child.id, child);
  }
  
  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }
  
  @override
  Stream<List<Child>> watchAll() {
    return _box.watch().map((_) => _box.values.toList());
  }
}
```

---

## Authentication Integration

### Dependencies

```yaml
dependencies:
  google_sign_in: ^6.1.0
  sign_in_with_apple: ^5.0.0
  firebase_auth: ^4.15.0  # Optional, for token validation
```

### Google Sign-In Implementation

```dart
// lib/data/auth/google_auth_service.dart
class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  
  Future<UserProfile?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) return null;
      
      final GoogleSignInAuthentication auth = await account.authentication;
      
      // Store tokens securely
      await _secureStorage.write(
        key: 'google_access_token',
        value: auth.accessToken,
      );
      await _secureStorage.write(
        key: 'google_id_token',
        value: auth.idToken,
      );
      
      // Create user profile
      final profile = UserProfile(
        id: account.id,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
        provider: AuthProvider.google,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      // Save to local storage
      await _userRepository.save(profile);
      
      return profile;
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }
  
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _secureStorage.delete(key: 'google_access_token');
    await _secureStorage.delete(key: 'google_id_token');
  }
}
```

### Apple Sign-In Implementation

```dart
// lib/data/auth/apple_auth_service.dart
class AppleAuthService {
  Future<UserProfile?> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      // Store tokens securely
      await _secureStorage.write(
        key: 'apple_user_id',
        value: credential.userIdentifier,
      );
      await _secureStorage.write(
        key: 'apple_id_token',
        value: credential.identityToken,
      );
      
      // Create user profile
      final profile = UserProfile(
        id: credential.userIdentifier,
        email: credential.email ?? 'private@appleid.com',
        displayName: _getFullName(credential.givenName, credential.familyName),
        provider: AuthProvider.apple,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      // Save to local storage
      await _userRepository.save(profile);
      
      return profile;
    } catch (e) {
      print('Apple Sign-In Error: $e');
      return null;
    }
  }
  
  String? _getFullName(String? givenName, String? familyName) {
    if (givenName == null && familyName == null) return null;
    return '${givenName ?? ''} ${familyName ?? ''}'.trim();
  }
}
```

---

## Data Flow Architecture

### 1. App Initialization

```
App Start
    ↓
Initialize Hive
    ↓
Open All Boxes
    ↓
Check Authentication Status
    ↓
    ├─ Authenticated → Load User Profile → Main App
    └─ Not Authenticated → Login Screen
```

### 2. User Sign-In Flow

```
User Taps "Sign in with Google/Apple"
    ↓
Google/Apple Authentication
    ↓
Receive User Credentials
    ↓
Store Tokens (Secure Storage)
    ↓
Create/Update User Profile (Hive)
    ↓
Initialize Default Data (if new user)
    ↓
Navigate to Main App
```

### 3. Data Access Pattern

```
UI Layer (Widgets)
    ↓
Riverpod Providers
    ↓
Repository Interface
    ↓
Local Repository Implementation
    ↓
Hive Box Operations
    ↓
Local Storage (Device)
```

### 4. Offline-First Operations

```
User Action (Add Child)
    ↓
Validation
    ↓
Generate UUID
    ↓
Save to Hive (Instant)
    ↓
Update UI (Reactive)
    ↓
[Optional] Queue for Cloud Backup
```

---

## Security Considerations

### 1. Data Encryption

**Hive Encryption:**
```dart
Future<void> openEncryptedBox<T>(String boxName) async {
  // Generate encryption key on first run
  final encryptionKeyString = await _secureStorage.read(key: 'hive_key');
  
  List<int> encryptionKey;
  if (encryptionKeyString == null) {
    // Generate new key
    encryptionKey = Hive.generateSecureKey();
    await _secureStorage.write(
      key: 'hive_key',
      value: base64Encode(encryptionKey),
    );
  } else {
    encryptionKey = base64Decode(encryptionKeyString);
  }
  
  await Hive.openBox<T>(
    boxName,
    encryptionCipher: HiveAesCipher(encryptionKey),
  );
}
```

### 2. Secure Storage (iOS/Android)

**iOS:** Keychain Services  
**Android:** KeyStore  

```dart
final storage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ),
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  ),
);
```

### 3. Biometric Authentication (Optional)

```yaml
dependencies:
  local_auth: ^2.1.0
```

```dart
Future<bool> authenticateWithBiometrics() async {
  final LocalAuthentication auth = LocalAuthentication();
  
  try {
    return await auth.authenticate(
      localizedReason: 'Authenticate to access BellGo',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );
  } catch (e) {
    return false;
  }
}
```

---

## Data Migration Strategy

### Version Management

```dart
class HiveMigrationService {
  static const int currentVersion = 1;
  
  Future<void> migrate() async {
    final prefs = await SharedPreferences.getInstance();
    final storedVersion = prefs.getInt('hive_version') ?? 0;
    
    if (storedVersion < currentVersion) {
      for (int v = storedVersion + 1; v <= currentVersion; v++) {
        await _runMigration(v);
      }
      await prefs.setInt('hive_version', currentVersion);
    }
  }
  
  Future<void> _runMigration(int version) async {
    switch (version) {
      case 1:
        await _migrateToV1();
        break;
      // Add future migrations here
    }
  }
  
  Future<void> _migrateToV1() async {
    // Example: Add new field to existing records
    final childrenBox = Hive.box<Child>('children');
    for (var child in childrenBox.values) {
      if (child.notificationsEnabled == null) {
        child.notificationsEnabled = true;
        await child.save();
      }
    }
  }
}
```

---

## Storage Size Management

### Data Cleanup Strategy

```dart
class StorageMaintenanceService {
  // Clean old travel time cache (> 7 days)
  Future<void> cleanOldCache() async {
    final box = Hive.box<TravelTimeCache>('travel_cache');
    final now = DateTime.now();
    
    final toDelete = box.values
        .where((cache) => cache.expiresAt.isBefore(now))
        .map((cache) => cache.key)
        .toList();
    
    await box.deleteAll(toDelete);
  }
  
  // Clean old schedules (> 1 year)
  Future<void> cleanOldSchedules() async {
    final box = Hive.box<DaySchedule>('schedules');
    final oneYearAgo = DateTime.now().subtract(Duration(days: 365));
    
    final toDelete = box.values
        .where((schedule) => schedule.date.isBefore(oneYearAgo))
        .map((schedule) => schedule.key)
        .toList();
    
    await box.deleteAll(toDelete);
  }
  
  // Get storage usage
  Future<int> getStorageSize() async {
    final dir = await getApplicationDocumentsDirectory();
    int totalSize = 0;
    
    await for (var file in dir.list(recursive: true)) {
      if (file is File) {
        totalSize += await file.length();
      }
    }
    
    return totalSize; // bytes
  }
}
```

---

## Testing Strategy

### Unit Tests

```dart
void main() {
  group('LocalChildRepository', () {
    late Box<Child> mockBox;
    late LocalChildRepository repository;
    
    setUp(() async {
      await Hive.initFlutter();
      Hive.registerAdapter(ChildAdapter());
      mockBox = await Hive.openBox<Child>('test_children');
      repository = LocalChildRepository(mockBox);
    });
    
    tearDown(() async {
      await mockBox.clear();
      await mockBox.close();
    });
    
    test('should add child to storage', () async {
      final child = Child(
        id: '123',
        firstName: 'John',
        lastName: 'Doe',
        grade: 5,
        schoolId: 'school-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await repository.add(child);
      
      final retrieved = await repository.getById('123');
      expect(retrieved, isNotNull);
      expect(retrieved!.firstName, 'John');
    });
  });
}
```

---

## Performance Optimization

### 1. Lazy Loading
```dart
// Don't load all data at once
Future<List<Child>> getChildren() async {
  return Hive.box<Child>('children').values.toList();
}

// Load one at a time for large datasets
Future<Child?> getChild(String id) async {
  return Hive.box<Child>('children').get(id);
}
```

### 2. Indexing
```dart
// Create compound keys for fast lookups
String buildScheduleKey(String schoolId, DateTime date) {
  return '${schoolId}_${date.toIso8601String().split('T')[0]}';
}

// Store with indexed key
await schedulesBox.put(
  buildScheduleKey(schoolId, date),
  schedule,
);
```

### 3. Batch Operations
```dart
// Bad: Multiple individual writes
for (var schedule in schedules) {
  await box.put(schedule.id, schedule);
}

// Good: Single batch write
await box.putAll(Map.fromEntries(
  schedules.map((s) => MapEntry(s.id, s)),
));
```

---

## Export/Import Functionality

### Export User Data

```dart
Future<File> exportUserData() async {
  final data = {
    'user': Hive.box<UserProfile>('users').values.first.toJson(),
    'children': Hive.box<Child>('children').values.map((c) => c.toJson()).toList(),
    'schools': Hive.box<School>('schools').values.map((s) => s.toJson()).toList(),
    'locations': Hive.box<Location>('locations').values.map((l) => l.toJson()).toList(),
    'schedules': Hive.box<DaySchedule>('schedules').values.map((s) => s.toJson()).toList(),
    'exportedAt': DateTime.now().toIso8601String(),
  };
  
  final json = jsonEncode(data);
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/bellgo_export_${DateTime.now().millisecondsSinceEpoch}.json');
  
  await file.writeAsString(json);
  return file;
}
```

### Import User Data

```dart
Future<void> importUserData(File file) async {
  final json = await file.readAsString();
  final data = jsonDecode(json) as Map<String, dynamic>;
  
  // Clear existing data
  await HiveService().clearAll();
  
  // Import user
  final user = UserProfile.fromJson(data['user']);
  await Hive.box<UserProfile>('users').put(user.id, user);
  
  // Import children
  for (var childJson in data['children']) {
    final child = Child.fromJson(childJson);
    await Hive.box<Child>('children').put(child.id, child);
  }
  
  // Import other data...
}
```

---

## Summary

### Key Benefits of This Architecture

✅ **Privacy First** - All data stays on device  
✅ **Fast Performance** - No network latency  
✅ **Offline-First** - Works without internet  
✅ **Secure** - Encrypted storage with biometrics  
✅ **Scalable** - Hive handles thousands of records efficiently  
✅ **Simple Auth** - Google/Apple ID for identity only  
✅ **User Control** - Export/delete data anytime  
✅ **Cost Effective** - No backend costs  

### Storage Estimates

**Per User:**
- User Profile: ~500 bytes
- Children (3): ~3 KB
- Schools (3): ~5 KB
- Locations (2): ~2 KB
- Schedules (365 days): ~200 KB
- **Total: ~210 KB per user**

**Device Storage Requirements:**
- App size: ~15 MB
- User data: ~1 MB (worst case)
- **Total: ~16 MB**

Very efficient for mobile devices!
