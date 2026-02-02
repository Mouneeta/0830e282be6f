# 🩺 Backend API – Device Vitals

A lightweight REST API built with Node.js, Express, and SQLite3 for storing, retrieving, and analyzing device vitals data.

---

## 🚀 Technologies Used

- **Node.js** - JavaScript runtime
- **Express.js** - Web framework
- **SQLite3** - File-based database
- **Jest** - Testing framework

---

## 📁 Project Structure

```
backend/
├── db.js            # SQLite database connection and setup
├── index.js         # Express server entry point
├── logic.js         # Business logic and database operations
├── logic.test.js    # Unit tests
├── package.json     # Dependencies and scripts
└── vitals.db        # SQLite database file
```

---

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** (version 16 or higher) - [Download here](https://nodejs.org/)
- **npm** (comes with Node.js)

> **Note:** SQLite does not require separate installation. The project uses the `sqlite3` npm package with a local database file.

---

## ⚙️ Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   ```

2. Navigate to the backend directory:
   ```bash
   cd backend
   ```

3. Install dependencies:
   ```bash
   npm install
   ```

---

## 🏃 Running the Server

Start the server with:

```bash
npm start
```

The server will run on **http://localhost:3000** (or the port defined in `index.js`).

---

## 🔌 API Endpoints

| Method | Endpoint                  | Description                          |
|--------|---------------------------|--------------------------------------|
| GET    | `/api/vitals`             | Retrieve vitals data (paginated)     |
| GET    | `/api/vitals/analytics`   | Fetch analytics from stored records  |
| POST   | `/api/vitals`             | Insert a new vitals record           |

---

## 🧪 Testing

Run the test suite with:

```bash
npm test
```

Tests are implemented in `logic.test.js` to validate business logic.

---

## 📝 Notes

This backend is designed to be **simple**, **easy to set up**, and suitable for small-scale applications. SQLite allows running the project without any external database configuration.

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

---

# 📱 Flutter App – Device Vitals Monitor

A cross-platform mobile application built with Flutter for monitoring and visualizing device vitals data with offline-first architecture.

---

## 🚀 Technologies Used

- **Flutter 3.8.0** - UI framework
- **Dart SDK** ^3.10.0-290.4.beta
- **BLoC Pattern** - State management (flutter_bloc)
- **Hive** - Local NoSQL database for offline storage
- **Dio** - HTTP client for API requests
- **GetIt** - Dependency injection
- **FL Chart** - Data visualization
- **Mockito** - Testing framework

---

## 📁 Project Structure

```
flutter_app/
├── lib/
│   ├── core/
│   │   ├── platform/          # Platform channels (native integration)
│   │   ├── resources/         # API service, DI, error handling
│   │   ├── storage/           # Hive database setup
│   │   └── utils/             # Utilities (logging, etc.)
│   ├── data/
│   │   ├── data_source/       # Local & remote data sources
│   │   ├── model/             # Data models (JSON serialization)
│   │   └── repositories/      # Repository implementations
│   ├── domain/
│   │   ├── entities/          # Business entities
│   │   ├── repository/        # Repository interfaces
│   │   └── usecases/          # Business logic use cases
│   ├── presentation/
│   │   ├── bloc/              # BLoC state management
│   │   ├── page/              # UI screens
│   │   └── widgets/           # Reusable widgets
│   └── main.dart              # App entry point
├── test/                      # Unit tests
├── android/                   # Android platform code
├── ios/                       # iOS platform code
└── pubspec.yaml              # Dependencies
```

---

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter 3.8.0** - [Installation guide](https://docs.flutter.dev/get-started/install)
- **Dart SDK** (comes with Flutter)
- **Android Studio** or **Xcode** (for mobile development)
- **VS Code** or **Android Studio** (recommended IDEs)

Verify your installation:
```bash
flutter doctor
```

---

## ⚙️ Installation

1. Navigate to the Flutter app directory:
   ```bash
   cd flutter_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Generate required code (Hive adapters, mocks):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. (Optional) Generate app icons:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

---

## 🏃 Running the App

### Run on connected device/emulator:
```bash
flutter run
```

### Run on specific device:
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

### Run in release mode:
```bash
flutter run --release
```

---

## 🗄️ Hive Local Storage Setup

The app uses **Hive** for offline-first data persistence. Hive is a lightweight, fast NoSQL database.

### What is Hive?

Hive stores device vitals locally, enabling:
- ✅ Offline access to historical data
- ✅ Fast data retrieval without network calls
- ✅ Automatic caching of API responses
- ✅ Seamless offline/online transitions

### Setup Steps

1. **Dependencies are already added** in `pubspec.yaml`:
   ```yaml
   dependencies:
     hive: 2.2.3
     hive_flutter: 1.1.0
     path_provider: 2.1.1
   
   dev_dependencies:
     hive_generator: 2.0.1
     build_runner: 2.4.7
   ```

2. **Generate Hive adapters**:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
   
   This generates `device_vitals_hive_model.g.dart` with the Hive adapter.

3. **Hive is auto-initialized** in `main.dart`:
   ```dart
   await HiveInit.initialize();
   ```

### Hive File Structure

```
lib/core/storage/
├── device_vitals_hive_model.dart       # Hive data model
├── device_vitals_hive_model.g.dart     # Generated adapter
└── hive_init.dart                      # Initialization logic

lib/data/data_source/local/
└── local_storage_service.dart          # Storage operations
```

### Using Hive in the App

The app automatically:
- Saves API responses to Hive for offline access
- Falls back to cached data when offline
- Persists posted vitals locally

**Example: Offline-First Pattern**
```dart
try {
  // Fetch from API
  final response = await apiService.getDeviceVitals();
  
  // Cache in Hive
  await localStorage.saveDeviceVitals(response);
  
  return response;
} catch (e) {
  // Fallback to cached data when offline
  return localStorage.getDeviceVitals();
}
```

### Hive Documentation

For detailed Hive setup and usage, see:
- 📄 `HIVE_SETUP.md` - Complete setup guide
- 📄 `HIVE_QUICK_START.md` - Quick reference
- 📄 `OFFLINE_FIRST_IMPLEMENTATION.md` - Offline architecture

---

## 🧪 Testing

The app includes comprehensive unit tests for models, repositories, and business logic.

### Test Structure

```
test/
├── data/
│   ├── model/
│   │   ├── device_response_test.dart      # Model JSON parsing tests
│   │   └── analytics_response_test.dart   # Analytics model tests
│   └── repositories/
│       └── device_repository_impl_test.dart  # Repository logic tests
└── README.md                               # Testing documentation
```

### Running Tests

**Run all tests:**
```bash
flutter test
```

**Run specific test file:**
```bash
flutter test test/data/model/device_response_test.dart
```

**Run with coverage:**
```bash
flutter test --coverage
```

**Watch mode (auto-rerun on changes):**
```bash
flutter test --watch
```

### Test Coverage

✅ **Model Tests**
- JSON parsing and serialization
- Default value handling
- Type conversions
- Null safety

✅ **Repository Tests**
- API request/response handling
- Error handling and retries
- Data transformation (model → entity)
- Pagination logic

✅ **Mocking**
- Uses Mockito for isolated testing
- Mocks API service and dependencies
- Tests without real network calls

### Generate Test Mocks

If you modify repository tests, regenerate mocks:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Testing Documentation

For detailed testing guide, see:
- 📄 `test/README.md` - Complete testing documentation

---

## 🏗️ Architecture

The app follows **Clean Architecture** principles with clear separation of concerns:

### Layers

1. **Presentation Layer** (`lib/presentation/`)
   - BLoC for state management
   - UI screens and widgets
   - User interaction handling

2. **Domain Layer** (`lib/domain/`)
   - Business entities
   - Use cases (business logic)
   - Repository interfaces

3. **Data Layer** (`lib/data/`)
   - Repository implementations
   - Data sources (remote API, local Hive)
   - Data models and transformations

4. **Core Layer** (`lib/core/`)
   - Shared utilities
   - Dependency injection setup
   - Platform-specific code

### Key Patterns

- **BLoC Pattern**: Reactive state management
- **Repository Pattern**: Abstract data sources
- **Dependency Injection**: GetIt for loose coupling
- **Offline-First**: Hive for local caching

---

## 🔌 API Integration

The app connects to the backend API for device vitals data.

### API Configuration

**IMPORTANT:** Update the base URL in `lib/core/resources/service_locator.dart`:

```dart
ApiService apiService() {
  /// Add your local IP address here
  _apiService ??= DioService(baseUrl: 'http://172.20.10.4:3000');
  return _apiService!;
}
```

**Replace `172.20.10.4` with your local machine's IP address.**

To find your local IP:
- **macOS/Linux**: Run `ifconfig | grep "inet "` in terminal
- **Windows**: Run `ipconfig` in command prompt
- **Or use**: `localhost` if testing on emulator/simulator on the same machine

### Endpoints Used

| Method | Endpoint                  | Description                    |
|--------|---------------------------|--------------------------------|
| GET    | `/api/vitals`             | Fetch device vitals (paginated)|
| GET    | `/api/vitals/analytics`   | Fetch analytics data           |
| POST   | `/api/vitals`             | Post new device vitals         |

---

## 📱 Features

- ✅ Real-time device vitals monitoring
- ✅ Historical data visualization with charts
- ✅ Offline-first architecture with Hive
- ✅ Automatic data caching
- ✅ Pagination for large datasets
- ✅ Analytics dashboard
- ✅ Cross-platform (iOS, Android, Web, Desktop)

---

## 🛠️ Development Commands

### Clean build artifacts:
```bash
flutter clean
```

### Analyze code quality:
```bash
flutter analyze
```

### Format code:
```bash
flutter format lib/
```

### Build APK (Android):
```bash
flutter build apk --release
```

### Build iOS:
```bash
flutter build ios --release
```

### Build for Web:
```bash
flutter build web
```

---

## 🐛 Troubleshooting

### Issue: "Hive box not initialized"
**Solution**: Ensure `HiveInit.initialize()` is called in `main()` before `runApp()`.

### Issue: "Cannot find generated adapter"
**Solution**: Run code generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: "Get.find() error in tests"
**Solution**: Ensure `Get.testMode = true` and `Get.reset()` are in test setup/teardown.

### Issue: "API connection failed"
**Solution**: 
1. Check backend server is running
2. Verify API URL in `dio_service.dart`
3. Check network permissions in `AndroidManifest.xml` / `Info.plist`

---

## 📚 Additional Documentation

- 📄 `HIVE_SETUP.md` - Complete Hive setup guide
- 📄 `HIVE_QUICK_START.md` - Quick Hive reference
- 📄 `OFFLINE_FIRST_IMPLEMENTATION.md` - Offline architecture details
- 📄 `test/README.md` - Testing documentation

---

## 🎯 Next Steps

1. ✅ Install Flutter and dependencies
2. ✅ Run `flutter pub get`
3. ✅ Generate code with `build_runner`
4. ✅ Configure API base URL
5. ✅ Run the app with `flutter run`
6. ✅ Run tests with `flutter test`

---

