# KinCare

Enterprise Flutter application for child health and medication management, built with Clean Architecture, GetX, and a local JSON mock backend.

## Architecture

```
lib/
├── app/                    # Application configuration
│   ├── bindings/           # GetX dependency injection bindings
│   ├── constants/          # App-wide strings, dimensions, and Hive key constants
│   ├── routes/             # Named routes and GetPage configuration
│   ├── services/           # Logger service
│   └── theme/              # Material 3 theme (light only), colors, typography
├── core/                   # Shared infrastructure
│   ├── accessibility/      # Semantic helpers, responsive utilities
│   ├── api/                # GraphQL client, local JSON executor, query strings
│   ├── errors/             # AppException hierarchy, Result<T> sealed type
│   ├── network/            # Connectivity check (connectivity_plus)
│   ├── storage/            # Hive abstraction (session state only)
│   └── widgets/            # Reusable widget library
├── data/                   # Data layer
│   ├── datasource/
│   │   ├── local/          # Auth session persistence (Hive)
│   │   └── remote/         # JSON executor datasources (mock "remote")
│   ├── models/             # Data models with JSON serialization
│   └── repositories/       # Repository implementations
├── domain/                 # Business logic layer
│   ├── entities/           # Pure domain entities (no framework dependencies)
│   ├── repositories/       # Repository interfaces
│   └── usecases/           # Single-responsibility use cases
└── presentation/           # UI layer
    ├── controllers/        # GetX controllers (MVVM ViewModels)
    ├── modules/            # Feature screens
    │   ├── auth/           # Login
    │   ├── dashboard/      # Home overview
    │   ├── children/       # Child list, child profile, add child
    │   ├── medication/     # Medication list, add medication, edit medication
    │   ├── profile/        # User profile, edit profile
    │   ├── help/           # Help & FAQ
    │   └── about/          # App version info
    └── widgets/            # Shared presentation widgets (drawer, app bars)
```

## Design Principles

- **SOLID** — Single-responsibility use cases; interface segregation via repository contracts
- **Clean Architecture** — Domain layer has zero dependencies on data or presentation
- **MVVM** — Controllers serve as ViewModels; UI is declarative and reactive via Rx observables
- **Repository Pattern** — All data access goes through repository abstractions
- **Dependency Injection** — GetX bindings per module (lazy `Get.lazyPut`); auth chain is permanent via `InitialBinding` so it survives route disposal

## Mock Backend

There is no network API. `GraphQLJsonExecutor` reads three bundled JSON files at runtime:

| File | Content |
|------|---------|
| `assets/data/children.json` | 20 seed children with health metrics, allergies, and appointment data |
| `assets/data/medications.json` | Seed medication records linked to children by id |
| `assets/data/profile.json` | Logged-in user profile |

`GraphQLQueries` document strings act as routing keys inside the executor — they are **not** sent over a network. Changes made in-app (add / edit / delete) update in-memory state only and reset on app restart.

## Data Flow

```
UI (Screen) → Controller → UseCase → Repository (interface)
                                          ↓
                              RepositoryImpl (data layer)
                              ├── checks connectivity (NetworkInfo)
                              └── calls RemoteDatasource (GraphQLJsonExecutor → JSON files)
```

Session state (`isLoggedIn`, last-login email) is persisted to Hive across restarts. All other data comes from the bundled JSON files on each cold start — there is no data caching layer.

## State Management (GetX)

- Reactive observables (`.obs`) drive all UI state
- `GetView<Controller>` binds a screen to its controller declaratively
- `Obx(() => ...)` gives fine-grained, widget-level rebuilds
- Module-scoped bindings with `Get.lazyPut` (disposed when the route leaves the stack)
- `AuthController` is registered permanently via `InitialBinding` so the navigation drawer's logout button can always reach it

## Modules

| Module | Features |
|--------|----------|
| **Auth** | Mock login, form validation, session persistence, inline error banner |
| **Dashboard** | At-a-glance counts (children / medications / visits), pinned child preview cards, nearest upcoming appointment across all children |
| **Children** | Paginated list (5 per page), child profile with health metrics, allergy banner, active medications, upcoming appointment, growth-tracking card |
| **Medications** | Full list with edit / delete, add medication (optionally pre-scoped to a child), per-child filtered history, active/inactive status badge |
| **Profile** | View and edit the logged-in user's name, email, and phone |
| **Help** | Getting-started steps, accessibility info, support contact |
| **About** | App version, Flutter version, open-source licenses |

## Screen Navigation Map

```
Login
  └─► Dashboard (replaces entire stack)
        ├─► Children List ──► Child Profile ──► Medication History (filtered to child)
        │                                   └─► Add Medication (child pre-selected)
        ├─► Child Profile (direct from dashboard preview cards)
        ├─► Medication List ──► Add Medication
        │                  └─► Edit Medication
        ├─► Add Child
        ├─► Profile ──► Edit Profile
        ├─► Help
        └─► About
```

All screens except Login share a navigation drawer. Help, About, and Profile replace the drawer with a back arrow — these are leaf screens reached from the drawer itself, so the drawer would create a circular navigation loop.

## Unsaved Changes Protection

Add Medication and Edit Medication use `PopScope` (via `UnsavedChangesScope`) to intercept back gestures and the system back button. If the form is dirty — any field changed from its initial value — a **"Discard changes?"** confirmation dialog appears before navigation proceeds. Navigating forward (save) bypasses the dialog.

## Accessibility

Every interactive element implements:

- **Semantics** — labels, hints, and roles on all tappable elements
- **Screen readers** — TalkBack / VoiceOver compatible (`Semantics`, `liveRegion: true`, `headingLevel`)
- **Touch targets** — Minimum 48 × 48 dp on all buttons and icon buttons
- **Focus traversal** — Explicit `NumericFocusOrder` indices on every multi-button group; `FocusTraversalGroup(policy: OrderedTraversalPolicy())` on every form and multi-button row so keyboard/switch-control tab order is deterministic regardless of widget-tree changes
- **Text scaling** — Clamped between 0.8 × – 2.0 ×
- **Responsive layout** — Phone / tablet / desktop, portrait / landscape

## Reusable Widget Library

| Widget | Purpose |
|--------|---------|
| `PrimaryButton` | Branded full-width action button with loading state |
| `SecondaryButton` | Outlined secondary action button |
| `CustomTextField` | Labelled text field with prefix icon, validator, and semantic label |
| `CustomDropdownField<T>` | Labelled dropdown with validation and semantic label |
| `FormScreenScaffold` | Scrollable form layout with `FocusTraversalGroup` and explicit field ordering |
| `MedicationFormFields` | Shared name/child/dosage/frequency/notes form used by Add and Edit Medication |
| `UnsavedChangesScope` | `PopScope` wrapper that shows a discard-changes dialog on dirty back navigation |
| `ConfirmDialog` | Reusable destructive-action confirmation dialog |
| `EmptyView` | Zero-state placeholder with optional action button |
| `ErrorView` | Error state with retry button |
| `LoadingView` | Centered `CircularProgressIndicator` |
| `InitialsAvatar` | Circular avatar generated from the first letters of a name |
| `PillBadge` | Small rounded text chip for status/category labels |
| `IconValueChip` | Icon + label + value chip used in children list cards |
| `SectionLabel` | All-caps section header with optional trailing widget |
| `InfoTile` | Icon + label + value row used in profile and about screens |

## Setup

### Prerequisites

- Flutter 3.x (tested on 3.41.7)
- Dart 3.x

### Install and Run

```bash
flutter pub get
flutter run
```

### Build

```bash
flutter build apk --release    # Android
flutter build ios --release    # iOS
```

### Generate Mocks (for testing)

```bash
dart run build_runner build
```

### Run Tests

```bash
flutter test
```

### Static Analysis

```bash
flutter analyze
```

## Demo Credentials

```
Email:    admin@kincare.com
Password: password
```

## Error Handling

All errors flow through a sealed `Result<T>` type so callers never catch raw exceptions:

```dart
sealed class Result<T> {
  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(AppException exception) = Failure<T>;
}
```

Exception hierarchy: `NetworkException` · `TimeoutException` · `GraphQLException` · `ParsingException` · `AuthException` · `CacheException` · `UnexpectedException`

## Testing

- **Unit tests** — Result wrapper, data models, use cases with mocked repositories
- **Widget tests** — PrimaryButton, SecondaryButton, CustomTextField, EmptyView, ErrorView, ConfirmDialog
- **52 tests total**, all passing

```bash
flutter test        # run all tests
flutter analyze     # static analysis (zero issues)
dart format lib     # formatting
```

## Tech Stack

| Category | Technology |
|----------|-----------|
| Framework | Flutter 3.x / Dart 3.x |
| Design System | Material 3 (light mode) |
| State Management | GetX |
| Mock API | Local JSON files via `GraphQLJsonExecutor` |
| Session Storage | Hive (login state only) |
| Testing | flutter_test, mockito |
| Connectivity | connectivity_plus |

## License

MIT
