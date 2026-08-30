# BellGo - Application Flow

## Screen Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     BOTTOM NAVIGATION                        │
├──────────┬──────────┬──────────┬──────────┬─────────────────┤
│  Today   │ Calendar │ Children │ Settings │                 │
└──────────┴──────────┴──────────┴──────────┴─────────────────┘
     │           │          │          │
     v           v          v          v
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
│ TODAY   │ │CALENDAR │ │CHILDREN │ │SETTINGS │
│ SCREEN  │ │ SCREEN  │ │ SCREEN  │ │ SCREEN  │
└─────────┘ └─────────┘ └─────────┘ └─────────┘
     │                       │
     │                       │
     v                       v
┌─────────────────┐   ┌─────────────┐
│ Leave Time Card │   │ Add Child   │
│ ─────────────── │   │ Form        │
│ • Status        │   │ ───────     │
│ • Leave by time │   │ • Name      │
│ • Drive time    │   │ • Grade     │
│ • Buffer        │   │ • School    │
└─────────────────┘   └─────────────┘
     │
     v
┌─────────────────┐
│ Child Info Card │
│ ─────────────── │
│ • Name          │
│ • School        │
│ • Schedule      │
└─────────────────┘
     │
     v
┌─────────────────┐
│Tomorrow Preview │
│ ─────────────── │
│ • Schedule type │
│ • Dismissal     │
│ • Leave time    │
└─────────────────┘
```

## Data Flow

```
UI Layer (Features)
       │
       │ Riverpod Providers
       │
       v
┌──────────────────────────────────┐
│   Domain Layer                   │
│                                  │
│  ┌────────────┐  ┌────────────┐ │
│  │  Models    │  │  Services  │ │
│  │            │  │            │ │
│  │ • Child    │  │ • Leave    │ │
│  │ • School   │  │   Time     │ │
│  │ • Location │  │   Calc     │ │
│  │ • Schedule │  │ • Travel   │ │
│  └────────────┘  └────────────┘ │
│                                  │
│  ┌──────────────────────────┐   │
│  │  Repository Interfaces   │   │
│  └──────────────────────────┘   │
└──────────────────────────────────┘
       │
       │ Implementation
       │
       v
┌──────────────────────────────────┐
│   Data Layer                     │
│                                  │
│  ┌──────────────────────────┐   │
│  │  Mock Repositories       │   │
│  │  • Child                 │   │
│  │  • School                │   │
│  │  • Location              │   │
│  └──────────────────────────┘   │
│                                  │
│  ┌──────────────────────────┐   │
│  │  Mock Services           │   │
│  │  • Travel Time           │   │
│  │  • School Schedule       │   │
│  │  • Notifications         │   │
│  └──────────────────────────┘   │
│                                  │
│  ┌──────────────────────────┐   │
│  │  Mock Data               │   │
│  │  • Sample child          │   │
│  │  • Sample schools        │   │
│  │  • Sample locations      │   │
│  └──────────────────────────┘   │
└──────────────────────────────────┘
```

## Leave Time Calculation Flow

```
1. User Location
   ↓
2. School Location
   ↓
3. Travel Time Service
   │
   ├─→ Calculate Distance
   │   (Haversine Formula)
   │
   └─→ Estimate Drive Time
       (Distance × 1.2 min/km)
       ↓
4. School Schedule Service
   │
   ├─→ Get Day of Week
   ├─→ Check Special Dates
   └─→ Determine Dismissal Time
       ↓
5. Leave Time Calculator
   │
   ├─→ Dismissal Time: 3:05 PM
   ├─→ Drive Time:     18 min
   ├─→ Buffer:         5 min
   │   ─────────────────────
   └─→ Leave By:       2:42 PM
       ↓
6. Status Determination
   │
   ├─→ Current Time: 2:00 PM
   ├─→ Time Until:   42 min
   │
   ├─→ >10 min → ALL GOOD (Green)
   ├─→ 5-10 min → GET READY (Yellow)
   ├─→ 0-5 min → TIME TO LEAVE (Red)
   └─→ <0 min → LATE (Red)
       ↓
7. Display to User
```

## State Management Flow

```
Widget
  │
  │ ref.watch()
  │
  v
Provider
  │
  │ reads
  │
  v
Repository / Service
  │
  │ fetches
  │
  v
Data Source (Mock)
  │
  │ returns
  │
  v
Domain Model
  │
  │ processed by
  │
  v
Business Logic
  │
  │ returns
  │
  v
Provider
  │
  │ ref.watch() notifies
  │
  v
Widget (rebuilds)
```

## Feature Dependencies

```
Today Screen
  ├─→ Child Repository (get child)
  ├─→ School Repository (get school)
  ├─→ Location Repository (get current location)
  ├─→ Schedule Service (get today/tomorrow schedule)
  ├─→ Travel Time Service (calculate drive time)
  └─→ Leave Time Calculator (calculate leave time)

Calendar Screen
  ├─→ Child Repository (get child)
  ├─→ School Repository (get school)
  └─→ Schedule Service (get month schedules)

Children Screen
  ├─→ Child Repository (CRUD operations)
  └─→ School Repository (search schools)

Locations Screen
  ├─→ Location Repository (get all, get current)
  └─→ Location Repository (set current)

Settings Screen
  └─→ (Currently stateless, will integrate with preferences service)
```

## Testing Architecture

```
Unit Tests
  │
  ├─→ Domain Layer Tests
  │   │
  │   ├─→ LeaveTimeCalculator
  │   │   ├─ Calculation accuracy
  │   │   ├─ Status determination
  │   │   └─ Time calculations
  │   │
  │   └─→ Models (if needed)
  │
  └─→ Data Layer Tests
      │
      ├─→ MockSchoolScheduleService
      │   ├─ Bell schedule generation
      │   ├─ Schedule type logic
      │   └─ Date range handling
      │
      └─→ MockTravelTimeService
          ├─ Distance calculation
          ├─ Time estimation
          └─ Edge cases

Integration Tests (Future)
  ├─→ Provider integration
  ├─→ Navigation flows
  └─→ E2E user journeys

Widget Tests (Future)
  ├─→ Screen rendering
  ├─→ User interactions
  └─→ State updates
```

## File Organization

```
bellgo/
├── lib/
│   ├── app/                    # App-level setup
│   │   ├── app.dart            # MaterialApp
│   │   ├── main_scaffold.dart  # Bottom nav
│   │   ├── providers.dart      # DI container
│   │   ├── router.dart         # Routes
│   │   └── theme.dart          # Design system
│   │
│   ├── core/                   # Shared utilities
│   │   └── constants/
│   │       └── app_constants.dart
│   │
│   ├── domain/                 # Business logic
│   │   ├── models/             # 7 models
│   │   ├── repositories/       # 3 interfaces
│   │   └── services/           # 4 services
│   │
│   ├── data/                   # Implementations
│   │   ├── mock/               # Sample data
│   │   ├── repositories/       # 3 mocks
│   │   └── services/           # 3 mocks
│   │
│   ├── features/               # UI modules
│   │   ├── calendar/           # 2 files
│   │   ├── children/           # 3 files
│   │   ├── locations/          # 2 files
│   │   ├── settings/           # 1 file
│   │   └── today/              # 2 files
│   │
│   └── main.dart               # Entry point
│
├── test/                       # Unit tests
│   ├── data/services/          # 2 test files
│   └── domain/services/        # 1 test file
│
├── docs/
│   ├── IMPLEMENTATION.md       # Architecture guide
│   ├── QUICKSTART.md           # Setup guide
│   ├── PROJECT_SUMMARY.md      # Overview
│   └── APP_FLOW.md             # This file
│
├── analysis_options.yaml       # Linter config
├── pubspec.yaml                # Dependencies
├── README.md                   # Main docs
└── .gitignore                  # Git exclusions
```

## Key User Journeys

### 1. Check Today's Schedule
```
App Launch
  → Today Screen
  → See leave time status
  → See child info
  → See tomorrow preview
```

### 2. View Monthly Calendar
```
Bottom Nav → Calendar
  → View month grid
  → See schedule indicators
  → Tap date
  → View dismissal details
```

### 3. Add a Child
```
Bottom Nav → Children
  → Tap "Add Child"
  → Enter name
  → Select grade
  → Search school
  → Save
  → Return to list
```

### 4. Change Pickup Location
```
Bottom Nav → Settings
  → Tap "Locations"
  → (Opens bottom sheet or new screen)
  → Select location
  → See updated travel time
```

### 5. Adjust Settings
```
Bottom Nav → Settings
  → Change reminder time
  → Change travel buffer
  → View app info
```

## Component Hierarchy

```
App
 └─ MaterialApp.router
     └─ ShellRoute (MainScaffold)
         ├─ Today Screen
         │   ├─ Leave Time Card
         │   ├─ Child Info Card
         │   └─ Tomorrow Card
         │
         ├─ Calendar Screen
         │   ├─ Month Selector
         │   ├─ Week Headers
         │   ├─ Calendar Grid
         │   └─ Selected Date Info
         │
         ├─ Children Screen
         │   ├─ Child List
         │   └─ FAB → Add Child
         │
         └─ Settings Screen
             ├─ Settings Sections
             └─ Bottom Sheet Pickers
```

---

This visual documentation provides a complete overview of the BellGo application's structure, flows, and architecture.
