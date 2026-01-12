# ☕ Very Good Coffee

A Flutter coffee browsing app built with **Very Good Ventures architecture** principles. Swipe through coffee images Tinder-style, favorite your picks, and enjoy!

## Considerations

Since this is a test project and it's not published to any app stores, not using any secrets or using any APIs/Databases to store data, the app runs entirely locally. This means a CI/CD pipeline script to deploy doesn't make a lot of sense which is why i did not include a script for it. I focused mostly on trying to follow the VGV architecture from the docs provided and creating a fun user experience for the requirement, not necessarily the most performant or enterprise-ready solution :smiley:



##  Features

- **Tinder-style swipeable cards** - Swipe left to skip, right to favorite
- **Favorites management** - Save and view your favorite coffee images
- **Pull-to-refresh** - Get fresh coffee images anytime
- **Local persistence** - Favorites saved across app sessions

## Getting Started

### Prerequisites

- Flutter SDK (3.10.7 or higher)
- Dart SDK
- iOS Simulator / Android Emulator / Physical device

### Setup

1. **Clone the repository**

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## Running Tests

### Run all tests
```bash
flutter test
```

### Run tests with coverage
```bash
flutter test --coverage
```

## Architecture

This project tries to follow **[Very Good Ventures Flutter Architecture](https://www.verygood.ventures/blog/very-good-flutter-architecture)** principles with a clean, layered approach, combined with some other elements taken from **[flutter's documentation]**(https://docs.flutter.dev/app-architecture/case-study)

### Architecture Overview

```
┌─────────────────────────────────────────┐
│      Presentation Layer (UI)            │
│  - Widgets (Screens, Cards)             │
│  - BlocBuilder (Reactive UI)            │
└────────────────┬────────────────────────┘
                 │ Events/States
┌────────────────▼────────────────────────┐
│    Business Logic Layer (BLoC)          │
│  - CoffeeBloc                           │
│  - Immutable Events & States            │
│  - Pure business logic                  │
└────────────────┬────────────────────────┘
                 │ Repository Interface
┌────────────────▼────────────────────────┐
│      Domain Layer (Entities)            │
│  - Coffee Entity                        │
│  - Repository Interface (abstract)      │
│  - Business rules                       │
└────────────────┬────────────────────────┘
                 │ Implementation
┌────────────────▼────────────────────────┐
│      Data Layer (Sources)               │
│  - Repository Implementation            │
│  - Remote Data Source (API)             │
│  - Local Data Source (Storage)          │
│  - DTOs (Data Transfer Objects)         │
└─────────────────────────────────────────┘
```

### Four-Layer Architecture

#### **Presentation Layer** (`lib/presentation/`)
- **Responsibility**: Render UI based on state
- **Components**: Screens, widgets, UI logic
- **State Management**: `flutter_bloc` with `BlocBuilder`

#### **Business Logic Layer** (`lib/presentation/coffees/business_logic/`)
- **Responsibility**: Manage application state and business logic
- **Pattern**: BLoC (Business Logic Component)
- **Components**:
  - `CoffeeBloc` - Processes events and emits states
  - `CoffeeEvent` - User actions (LoadBrowseCoffees, ToggleFavorite, etc.)
  - `CoffeeState` - UI states (CoffeeLoading, CoffeeLoaded, CoffeeError)

#### **Domain Layer** (`lib/domain/`)
- **Responsibility**: Define business entities and contracts
- **Components**:
  - `Coffee` entity - Domain representation 
  - `ICoffeeRepository` - Abstract interface defining operations

#### **Data Layer** (`lib/data/`)
- **Responsibility**: Handle data operations (API, local storage)
- **Components**:
  - `CoffeeRepository` - Implements domain interface
  - `CoffeeRemoteDataSource` - API calls (https://coffee.alexflipnote.dev)
  - `CoffeeLocalDataSource` - SharedPreferences for favorites
  - `CoffeeDto` - JSON serialization models
