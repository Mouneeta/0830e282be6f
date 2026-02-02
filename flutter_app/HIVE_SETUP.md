# Hive Local Storage Setup

This document explains the Hive local storage implementation for device vitals history.

## Overview

Hive is a lightweight and fast NoSQL database for Flutter. We use it to store device vitals data locally for offline access and caching.

## Setup Steps

### 1. Install Dependencies

The following dependencies have been added to `pubspec.yaml`:

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.1

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.7
```

### 2. Run Commands

```bash
# Get dependencies
flutter pub get

# Generate Hive adapter code
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate `device_vitals_hive_model.g.dart` file with the Hive adapter.

### 3. File Structure

```
lib/
├── core/
│   └── storage/
│       └── hive_init.dart                          # Hive initialization
├── data/
│   ├── data_source/
│   │   └── local/
│   │       └── local_storage_service.dart          # Local storage operations
│   └── model/
│       ├── device_vitals_hive_model.dart           # Hive model
│       └── device_vitals_hive_model.g.dart         # Generated adapter
└── main.dart                                        # App entry point with Hive init
```

## Implementation Details

### 1. Hive Model (`device_vitals_hive_model.dart`)

```dart
@HiveType(typeId: 0)
class DeviceVitalsHiveModel extends HiveObject {
  @HiveField(0) String deviceId;
  @HiveField(1) DateTime timestamp;
  @HiveField(2) num thermalValue;
  @HiveField(3) num batteryLevel;
  @HiveField(4) num memoryUsage;
}
```

- `@HiveType(typeId: 0)`: Unique identifier for this model
- `@HiveField(n)`: Field index for serialization
- Extends `HiveObject` for lazy loading support

### 2. Local Storage Service (`local_storage_service.dart`)

Provides methods for:
- `init()`: Initialize the Hive box
- `saveDeviceVitals(List)`: Save multiple vitals (replaces all)
- `addDeviceVital(Model)`: Add a single vital
- `getDeviceVitals()`: Get all stored vitals
- `getDeviceVitalsPaginated()`: Get vitals with pagination
- `getCount()`: Get total count of stored vitals
- `clearAll()`: Clear all data
- `close()`: Close the box

### 3. Initialization (`hive_init.dart`)

```dart
class HiveInit {
  static Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(DeviceVitalsHiveModelAdapter());
  }
}
```

### 4. Main App Integration (`main.dart`)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveInit.initialize();
  await setupDependencies();
  runApp(const MyApp());
}
```

## Usage Examples

### Accessing the Service

```dart
import 'package:get_it/get_it.dart';
import 'package:flutter_app/data/data_source/local/local_storage_service.dart';

final localStorageService = GetIt.instance<LocalStorageService>();
```

### Save Device Vitals

```dart
// Convert entities to Hive models
final hiveModels = deviceEntities.map((entity) => 
  DeviceVitalsHiveModel.fromEntity(entity)
).toList();

// Save to local storage
await localStorageService.saveDeviceVitals(hiveModels);
```

### Add Single Vital

```dart
final hiveModel = DeviceVitalsHiveModel.fromEntity(deviceEntity);
await localStorageService.addDeviceVital(hiveModel);
```

### Retrieve Data

```dart
// Get all vitals
final allVitals = localStorageService.getDeviceVitals();

// Get paginated vitals
final pageVitals = localStorageService.getDeviceVitalsPaginated(
  page: 1,
  limit: 10,
);

// Get count
final count = localStorageService.getCount();
```

### Clear Data

```dart
await localStorageService.clearAll();
```

## Integration with Repository

You can integrate local storage with your repository for offline-first approach:

```dart
class DeviceRepositoryImpl implements DeviceRepository {
  final LocalStorageService _localStorage;
  
  @override
  Future<DeviceResponseEntity> getDeviceVitals({int? page, int? limit}) async {
    try {
      // Try to fetch from API
      final response = await api.request(...);
      
      // Save to local storage for offline access
      final hiveModels = response.data.map((e) => 
        DeviceVitalsHiveModel.fromEntity(e)
      ).toList();
      await _localStorage.saveDeviceVitals(hiveModels);
      
      return response;
    } catch (e) {
      // Fallback to local storage if API fails
      final localData = _localStorage.getDeviceVitals();
      return convertToEntity(localData);
    }
  }
}
```

## Important Notes

1. **Type ID**: Each Hive model must have a unique `typeId`. We use `0` for `DeviceVitalsHiveModel`.

2. **Field IDs**: Field IDs must be unique within a model and should never change once set.

3. **Code Generation**: Always run `build_runner` after modifying Hive models:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Box Names**: We use `'device_vitals'` as the box name. Each box is like a table in SQL.

5. **Initialization**: Hive must be initialized before opening any boxes. This is done in `main()`.

6. **Dependency Injection**: The `LocalStorageService` is registered in GetIt for easy access throughout the app.

## Troubleshooting

### Error: "Box is not initialized"
- Make sure `init()` is called before using the service
- Check that Hive is initialized in `main()`

### Error: "Cannot find generated adapter"
- Run `flutter pub run build_runner build --delete-conflicting-outputs`
- Check that `part 'device_vitals_hive_model.g.dart';` is in the model file

### Error: "Type ID already registered"
- Each model needs a unique `typeId`
- Check for duplicate type IDs across different models

## Performance Tips

1. **Lazy Loading**: Use `HiveObject` for lazy loading of large datasets
2. **Pagination**: Use `getDeviceVitalsPaginated()` for large lists
3. **Batch Operations**: Use `addAll()` instead of multiple `add()` calls
4. **Close Boxes**: Close boxes when not needed to free resources

## Data Persistence

- Hive data persists across app restarts
- Data is stored in the app's documents directory
- Use `clearAll()` to reset data during development/testing
