# BellGo - Local Storage Architecture Diagrams

## System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                          BellGo App                              │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                     UI Layer (Flutter)                     │ │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │ │
│  │  │  Today   │  │ Calendar │  │ Children │  │ Settings │  │ │
│  │  │  Screen  │  │  Screen  │  │  Screen  │  │  Screen  │  │ │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │ │
│  └────────────────────────────────────────────────────────────┘ │
│                            ▲                                      │
│                            │                                      │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              State Management (Riverpod)                   │ │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐      │ │
│  │  │  User   │  │ Child   │  │Location │  │Schedule │      │ │
│  │  │Provider │  │Provider │  │Provider │  │Provider │      │ │
│  │  └─────────┘  └─────────┘  └─────────┘  └─────────┘      │ │
│  └────────────────────────────────────────────────────────────┘ │
│                            ▲                                      │
│                            │                                      │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                  Repository Layer                          │ │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐          │ │
│  │  │    User    │  │   Child    │  │  Location  │          │ │
│  │  │ Repository │  │ Repository │  │ Repository │  ...     │ │
│  │  └────────────┘  └────────────┘  └────────────┘          │ │
│  └────────────────────────────────────────────────────────────┘ │
│                            ▲                                      │
│                            │                                      │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              Local Storage Services                        │ │
│  │  ┌─────────┐  ┌──────────┐  ┌──────────────┐             │ │
│  │  │  Hive   │  │  Secure  │  │    Shared    │             │ │
│  │  │ Service │  │ Storage  │  │ Preferences  │             │ │
│  │  └─────────┘  └──────────┘  └──────────────┘             │ │
│  └────────────────────────────────────────────────────────────┘ │
│                            ▲                                      │
└────────────────────────────┼──────────────────────────────────────┘
                             │
        ┌────────────────────┴────────────────────┐
        │                                         │
   ┌────▼─────┐                            ┌─────▼─────┐
   │          │                            │           │
   │  Device  │                            │   iOS     │
   │  Storage │                            │ Keychain  │
   │  (Hive)  │                            │ / Android │
   │          │                            │ KeyStore  │
   └──────────┘                            └───────────┘
   
   [Encrypted]                             [Encrypted]
   User Data                               Auth Tokens
   - Children                              - OAuth Tokens
   - Schools                               - User ID
   - Locations                             - Encryption Keys
   - Schedules
```

## Authentication Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    User Opens App                                │
└──────────────────────┬──────────────────────────────────────────┘
                       │
                       ▼
        ┌──────────────────────────────┐
        │  Check Authentication Status │
        │  (Secure Storage)            │
        └──────────┬───────────────────┘
                   │
          ┌────────┴────────┐
          │                 │
          ▼                 ▼
    ┌──────────┐      ┌──────────┐
    │   Token  │      │    No    │
    │  Found   │      │  Token   │
    └────┬─────┘      └────┬─────┘
         │                 │
         │                 ▼
         │          ┌─────────────────┐
         │          │  Login Screen   │
         │          │  [Google/Apple] │
         │          └────────┬────────┘
         │                   │
         │                   ▼
         │          ┌──────────────────┐
         │          │ User Selects     │
         │          │ Sign-in Method   │
         │          └─────────┬────────┘
         │                    │
         │          ┌─────────┴─────────┐
         │          │                   │
         │          ▼                   ▼
         │   ┌────────────┐      ┌────────────┐
         │   │  Google    │      │   Apple    │
         │   │  Sign-In   │      │  Sign-In   │
         │   └──────┬─────┘      └──────┬─────┘
         │          │                   │
         │          └─────────┬─────────┘
         │                    │
         │                    ▼
         │          ┌──────────────────┐
         │          │ Receive OAuth    │
         │          │ Credentials      │
         │          └────────┬─────────┘
         │                   │
         │                   ▼
         │          ┌──────────────────┐
         │          │ Store Tokens     │
         │          │ (Secure Storage) │
         │          └────────┬─────────┘
         │                   │
         │                   ▼
         │          ┌──────────────────┐
         │          │ Create User      │
         │          │ Profile (Hive)   │
         │          └────────┬─────────┘
         │                   │
         └───────────────────┘
                             │
                             ▼
                   ┌──────────────────┐
                   │  Load User Data  │
                   │  from Hive       │
                   └────────┬─────────┘
                            │
                            ▼
                   ┌──────────────────┐
                   │   Main App       │
                   │   (Home Screen)  │
                   └──────────────────┘
```

## Data Storage Structure

```
Device Storage
│
├── App Directory
│   ├── hive/
│   │   ├── users.hive           [Encrypted]
│   │   │   └── UserProfile
│   │   │       ├── id (Google/Apple)
│   │   │       ├── email
│   │   │       ├── displayName
│   │   │       └── ...
│   │   │
│   │   ├── children.hive        [Encrypted]
│   │   │   └── Child[]
│   │   │       ├── id
│   │   │       ├── name
│   │   │       ├── grade
│   │   │       └── schoolId
│   │   │
│   │   ├── schools.hive         [Encrypted]
│   │   │   └── School[]
│   │   │       ├── id
│   │   │       ├── name
│   │   │       ├── address
│   │   │       └── bellSchedule
│   │   │
│   │   ├── locations.hive       [Encrypted]
│   │   │   └── Location[]
│   │   │       ├── id
│   │   │       ├── name
│   │   │       ├── address
│   │   │       └── coordinates
│   │   │
│   │   ├── schedules.hive       [Encrypted]
│   │   │   └── DaySchedule[]
│   │   │       ├── date
│   │   │       ├── type
│   │   │       └── dismissalTime
│   │   │
│   │   └── travel_cache.hive    [Encrypted]
│   │       └── TravelTimeCache[]
│   │           ├── origin
│   │           ├── destination
│   │           └── travelTime
│   │
│   └── shared_preferences/
│       └── settings.xml / .plist
│           ├── theme_mode
│           ├── notifications_enabled
│           ├── pickup_buffer
│           └── reminder_time
│
└── Secure Storage (Keychain/KeyStore)
    ├── google_access_token
    ├── google_id_token
    ├── apple_user_id
    ├── apple_id_token
    └── hive_encryption_key
```

## CRUD Operations Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    User Action: Add Child                        │
└──────────────────────┬──────────────────────────────────────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │  UI: AddChildScreen  │
            │  User fills form     │
            └──────────┬───────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │  Validation          │
            │  - Name required     │
            │  - Grade valid       │
            └──────────┬───────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │  Provider            │
            │  childProvider       │
            │  .addChild()         │
            └──────────┬───────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │  Repository          │
            │  childRepository     │
            │  .add(child)         │
            └──────────┬───────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │  Generate UUID       │
            │  Set timestamps      │
            └──────────┬───────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │  Hive Box            │
            │  box.put(id, child)  │
            └──────────┬───────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │  Write to Disk       │
            │  [Encrypted]         │
            └──────────┬───────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │  Notify Listeners    │
            │  box.watch()         │
            └──────────┬───────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │  UI Updates          │
            │  List refreshes      │
            └──────────────────────┘

            Total Time: < 50ms
            No network required
```

## Data Synchronization (Future: Optional Cloud Backup)

```
┌──────────────────────────────────────────────────────────────┐
│                    Current: Local Only                        │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                                                          │ │
│  │   ┌──────────┐         ┌──────────┐                    │ │
│  │   │  User    │         │  Device  │                    │ │
│  │   │  Action  │────────▶│  Storage │                    │ │
│  │   └──────────┘         │  (Hive)  │                    │ │
│  │                        └──────────┘                    │ │
│  │                                                          │ │
│  │   No network required                                   │ │
│  │   Data stays on device                                  │ │
│  │                                                          │ │
│  └─────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────┐
│              Future: Optional Cloud Backup                    │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │                                                          │ │
│  │   ┌──────────┐         ┌──────────┐                    │ │
│  │   │  User    │         │  Device  │                    │ │
│  │   │  Action  │────────▶│  Storage │                    │ │
│  │   └──────────┘         │  (Hive)  │                    │ │
│  │                        └─────┬────┘                    │ │
│  │                              │                          │ │
│  │                              │ (Optional)               │ │
│  │                              ▼                          │ │
│  │                        ┌──────────┐                    │ │
│  │                        │  Backup  │                    │ │
│  │                        │  Queue   │                    │ │
│  │                        └─────┬────┘                    │ │
│  │                              │                          │ │
│  │                              │ (WiFi + User Consent)    │ │
│  │                              ▼                          │ │
│  │                        ┌──────────┐                    │ │
│  │                        │  Cloud   │                    │ │
│  │                        │  Backup  │                    │ │
│  │                        │(Firebase)│                    │ │
│  │                        └──────────┘                    │ │
│  │                                                          │ │
│  │   Primary: Local storage (instant)                      │ │
│  │   Backup: Cloud (optional, background)                  │ │
│  │                                                          │ │
│  └─────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

## Security Layers

```
┌──────────────────────────────────────────────────────────────┐
│                      Security Stack                           │
│                                                               │
│  Layer 1: App-Level Access                                   │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  - Face ID / Touch ID / PIN                             │ │
│  │  - Biometric authentication (optional)                  │ │
│  │  - Local authentication required                        │ │
│  └─────────────────────────────────────────────────────────┘ │
│                            │                                  │
│                            ▼                                  │
│  Layer 2: OAuth Authentication                               │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  - Google Sign-In                                       │ │
│  │  - Apple Sign-In                                        │ │
│  │  - Tokens stored in Secure Storage                     │ │
│  └─────────────────────────────────────────────────────────┘ │
│                            │                                  │
│                            ▼                                  │
│  Layer 3: Storage Encryption                                 │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  - Hive AES-256 encryption                              │ │
│  │  - Unique key per device                                │ │
│  │  - Key stored in Secure Storage                         │ │
│  └─────────────────────────────────────────────────────────┘ │
│                            │                                  │
│                            ▼                                  │
│  Layer 4: Platform Security                                  │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  iOS: Keychain + File Protection                        │ │
│  │  - Data Protection Class: CompleteUntilFirstUserAuth    │ │
│  │  - Encrypted when device is locked                      │ │
│  │                                                           │ │
│  │  Android: KeyStore + EncryptedSharedPreferences         │ │
│  │  - Hardware-backed encryption                           │ │
│  │  - Master key in TEE (Trusted Execution Environment)    │ │
│  └─────────────────────────────────────────────────────────┘ │
│                            │                                  │
│                            ▼                                  │
│  Layer 5: Device Security                                    │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │  - Device passcode                                      │ │
│  │  - Full disk encryption                                 │ │
│  │  - Secure Enclave (iOS) / TEE (Android)                │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

## Data Access Patterns

### Pattern 1: Single Item Access (Fast)
```
User opens Today Screen
         │
         ▼
Load current child (10ms)
         │
         ├──▶ Get child by ID from Hive
         │
         ▼
Load school (5ms)
         │
         ├──▶ Get school by ID from Hive
         │
         ▼
Load location (5ms)
         │
         ├──▶ Get current location from Hive
         │
         ▼
Load schedule (5ms)
         │
         ├──▶ Get today's schedule from Hive
         │
         ▼
Calculate leave time (1ms)
         │
         ▼
Render UI (5ms)

Total: ~30ms
```

### Pattern 2: List Access (Moderate)
```
User opens Children Screen
         │
         ▼
Load all children (20ms)
         │
         ├──▶ Query all children from Hive
         │    (Filter, sort in memory)
         │
         ▼
Load schools (15ms)
         │
         ├──▶ Query schools by IDs
         │
         ▼
Render list (10ms)

Total: ~45ms
```

### Pattern 3: Calendar Access (Heavy)
```
User opens Calendar Screen
         │
         ▼
Load month schedules (50ms)
         │
         ├──▶ Query schedules by date range
         │    (30 days of data)
         │
         ▼
Render calendar grid (20ms)

Total: ~70ms
```

## Memory Management

```
┌───────────────────────────────────────────────────────────┐
│                    Memory Usage                            │
│                                                            │
│  App Launch                                               │
│  ├─ Initialize Hive        (~5 MB)                        │
│  ├─ Open Boxes             (~2 MB)                        │
│  ├─ Load User Profile      (~1 KB)                        │
│  └─ Flutter Framework      (~30 MB)                       │
│                                                            │
│  Runtime                                                   │
│  ├─ UI State               (~5 MB)                        │
│  ├─ Cached Data            (~5 MB)                        │
│  │   ├─ Children           (~1 MB)                        │
│  │   ├─ Schools            (~1 MB)                        │
│  │   ├─ Schedules          (~2 MB)                        │
│  │   └─ Images             (~1 MB)                        │
│  └─ System                 (~10 MB)                       │
│                                                            │
│  Total: ~60 MB typical                                    │
│  Peak:  ~100 MB max                                       │
│                                                            │
└───────────────────────────────────────────────────────────┘

Optimization Strategies:
✓ Lazy load boxes
✓ Close unused boxes
✓ Compact on background
✓ Clear old cache
```

## Backup & Restore Flow (Optional Future Feature)

```
┌────────────────────────────────────────────────────────┐
│                    Export Data                          │
│                                                         │
│  User: Settings > Export Data                          │
│         │                                               │
│         ▼                                               │
│  Collect all data from Hive boxes                      │
│         │                                               │
│         ▼                                               │
│  Serialize to JSON                                      │
│         │                                               │
│         ├─ User profile                                │
│         ├─ Children                                     │
│         ├─ Schools                                      │
│         ├─ Locations                                    │
│         └─ Schedules                                    │
│         │                                               │
│         ▼                                               │
│  Compress (ZIP)                                         │
│         │                                               │
│         ▼                                               │
│  Save to Files app / Share                             │
│         │                                               │
│         ├─▶ Local Files                                │
│         ├─▶ iCloud Drive                               │
│         ├─▶ Email                                       │
│         └─▶ AirDrop                                     │
│                                                         │
└────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────┐
│                    Import Data                          │
│                                                         │
│  User: Settings > Import Data                          │
│         │                                               │
│         ▼                                               │
│  Select backup file                                     │
│         │                                               │
│         ▼                                               │
│  Validate JSON structure                               │
│         │                                               │
│         ▼                                               │
│  Show preview of data                                   │
│         │                                               │
│         ▼                                               │
│  Confirm: Overwrite or Merge?                          │
│         │                                               │
│    ┌────┴─────┐                                        │
│    │          │                                         │
│    ▼          ▼                                         │
│ Overwrite   Merge                                       │
│    │          │                                         │
│    └────┬─────┘                                        │
│         │                                               │
│         ▼                                               │
│  Clear existing data (if overwrite)                    │
│         │                                               │
│         ▼                                               │
│  Import to Hive boxes                                   │
│         │                                               │
│         ▼                                               │
│  Restart app                                            │
│         │                                               │
│         ▼                                               │
│  Success message                                        │
│                                                         │
└────────────────────────────────────────────────────────┘
```

## Performance Benchmarks

```
┌─────────────────────────────────────────────────────┐
│            Operation Performance                     │
│                                                      │
│  Read Operations (Single Item)                      │
│  ├─ Get child by ID          <  5ms                │
│  ├─ Get school by ID         <  5ms                │
│  ├─ Get location by ID       <  5ms                │
│  └─ Get schedule by date     < 10ms                │
│                                                      │
│  Read Operations (Collections)                      │
│  ├─ Get all children (10)    < 20ms                │
│  ├─ Get all locations (5)    < 10ms                │
│  └─ Get month schedules (30) < 50ms                │
│                                                      │
│  Write Operations                                    │
│  ├─ Add child                < 10ms                │
│  ├─ Update child             < 10ms                │
│  ├─ Delete child             <  5ms                │
│  └─ Batch insert (100)       < 100ms               │
│                                                      │
│  Complex Operations                                  │
│  ├─ Full data export         < 500ms               │
│  ├─ Full data import         < 1000ms              │
│  └─ Database migration       < 2000ms              │
│                                                      │
│  App Lifecycle                                       │
│  ├─ Cold start               < 1000ms              │
│  ├─ Resume from background   < 100ms               │
│  └─ Hive box open            < 50ms                │
│                                                      │
└─────────────────────────────────────────────────────┘

All operations are synchronous and instant from user perspective.
No loading spinners needed for local data access.
```
