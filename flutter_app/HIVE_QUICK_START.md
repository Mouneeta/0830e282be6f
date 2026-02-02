# Hive Local Storage - Quick Start

## ✅ Setup Complete!

All Hive files have been created and the adapter has been generated successfully.

## What Was Created

### 1. **Dependencies Added** (`pubspec.yaml`)
- `hive: ^2.2.3` - Core Hive database
- `hive_flutter: ^1.1.0` - Flutter integration
- `path_provider: ^2.1.1` - Path management
- `hive_generator: ^2.0.1` - Code generation (dev)

### 2. **Files Created**

```
lib/
├── core/storage/
│   └── hive_init.dart                              ✅ Hive initialization
├── data/
│   ├── data_source/local/
│   │   └── local_storage_service.dart              ✅ Storage operations
│   └── model/
│       ├── device_vitals_hive_model.dart           ✅ Hive model
│       └── device_vitals_hive_model.g.dart         ✅ Generated adapter
└── main.dart                                        ✅ Updated with Hive init
```

### 3. **Documentation**
- `HIVE_SETUP.md` - Complete setup guide with examples

## How to Use

### Access the Service

```dart
import 'package:get_it/get_it.dart';

final localStorage = GetIt.instance<LocalStorageService>();
```

### Save Data

```dart
// Convert entity to Hive model
final hiveModel = DeviceVitalsHiveModel.fromEntity(deviceEntity);

// Add single item
await localStorage.addDeviceVital(hiveModel);

// Or save multiple items
await localStorage.saveDeviceVitals([hiveModel1, hiveModel2]);
```

### Retrieve Data

```dart
// Get all vitals
final allVitals = localStorage.getDeviceVitals();

// Get with pagination
final pageVitals = localStorage.getDeviceVitalsPaginated(
  page: 1, 
  limit: 10
);

// Get count
final count = localStorage.getCount();
```

### Clear Data

```dart
await localStorage.clearAll();
```

## Integration Example

You can now integrate this with your BLoC or repository:

```dart
// In your repository or BLoC
final localStorage = GetIt.instance<LocalStorageService>();

// After fetching from API, save to local storage
final hiveModels = apiResponse.data.map((entity) => 
  DeviceVitalsHiveModel.fromEntity(entity)
).toList();

await localStorage.saveDeviceVitals(hiveModels);

// Later, retrieve from local storage
final cachedData = localStorage.getDeviceVitals();
```

## Next Steps

1. ✅ Dependencies installed
2. ✅ Adapter generated
3. ✅ Service registered in GetIt
4. 🔲 Integrate with your BLoC/Repository (optional)
5. 🔲 Test the implementation

## Testing

The app is ready to run! Hive will automatically:
- Initialize on app start
- Create the database file
- Store data persistently

Run your app:
```bash
flutter run
```

## Need Help?

See `HIVE_SETUP.md` for detailed documentation including:
- Complete API reference
- Integration patterns
- Troubleshooting guide
- Performance tips
