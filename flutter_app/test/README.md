# Unit Tests

This directory contains unit tests for the Flutter app, focusing on Repository/Service layer logic and data models.

## Test Structure

```
test/
├── data/
│   ├── model/
│   │   ├── device_response_test.dart      # Tests for DeviceResponse and DeviceData models
│   │   └── analytics_response_test.dart   # Tests for AnalyticsResponse model
│   └── repositories/
│       └── device_repository_impl_test.dart  # Tests for DeviceRepositoryImpl
└── README.md
```

## Setup

1. Install dependencies:
```bash
flutter pub get
```

2. Generate mock classes for repository tests:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate `device_repository_impl_test.mocks.dart` file with mock implementations of `ApiService` and `ServiceLocator`.

## Running Tests

### Run all tests:
```bash
flutter test
```

### Run specific test file:
```bash
flutter test test/data/model/device_response_test.dart
flutter test test/data/model/analytics_response_test.dart
flutter test test/data/repositories/device_repository_impl_test.dart
```

### Run tests with coverage:
```bash
flutter test --coverage
```

### Run tests in watch mode (re-run on file changes):
```bash
flutter test --watch
```

## Test Coverage

### Model Tests (`device_response_test.dart`)
- ✅ Parsing valid JSON data
- ✅ Handling missing fields with default values
- ✅ Handling null fields
- ✅ Converting models to JSON
- ✅ Timestamp parsing and formatting
- ✅ Type conversions (numeric device_id to string)

### Model Tests (`analytics_response_test.dart`)
- ✅ Parsing nested JSON structure (rolling_average, min, max)
- ✅ Handling missing nested objects with defaults
- ✅ Handling missing nested fields with defaults
- ✅ Handling null nested objects
- ✅ Type conversions (integer to double)
- ✅ Completely empty JSON handling

### Repository Tests (`device_repository_impl_test.dart`)
- ✅ `getDeviceVitals()` - successful API call
- ✅ `getDeviceVitals()` - with pagination parameters
- ✅ `getDeviceVitals()` - without query parameters
- ✅ `getDeviceVitals()` - error handling
- ✅ `postDeviceVitals()` - successful post
- ✅ `postDeviceVitals()` - request body formatting
- ✅ `postDeviceVitals()` - timestamp generation
- ✅ `postDeviceVitals()` - error handling
- ✅ `getDeviceVitalsAnalytics()` - successful API call
- ✅ `getDeviceVitalsAnalytics()` - nested JSON parsing
- ✅ `getDeviceVitalsAnalytics()` - error handling
- ✅ `getDeviceVitalsAnalytics()` - zero values handling

## Testing Approach

### Model Tests
Model tests verify that:
1. JSON parsing works correctly with valid data
2. Default values are applied when fields are missing
3. Type conversions happen correctly
4. Models can be serialized back to JSON

### Repository Tests
Repository tests use **mocking** to:
1. Isolate the repository logic from external dependencies (API service)
2. Test different scenarios (success, failure, edge cases)
3. Verify correct API calls are made with proper parameters
4. Verify data transformation from models to entities

We use **Mockito** to create mock implementations of:
- `ApiService` - to simulate API responses without making real network calls
- `ServiceLocator` - to provide the mocked API service

## Key Testing Concepts

### Mocking
Mocking allows us to:
- Test code in isolation without external dependencies
- Simulate different scenarios (success, errors, edge cases)
- Verify that methods are called with correct parameters
- Control the behavior of dependencies

### Arrange-Act-Assert Pattern
All tests follow the AAA pattern:
1. **Arrange**: Set up test data and mock behaviors
2. **Act**: Execute the code being tested
3. **Assert**: Verify the results match expectations

## Troubleshooting

### Mock generation fails
If `build_runner` fails to generate mocks:
1. Clean the project: `flutter clean`
2. Get dependencies: `flutter pub get`
3. Try again: `flutter pub run build_runner build --delete-conflicting-outputs`

### Tests fail with "Get.find<ServiceLocator>()" error
This means the GetX dependency injection isn't set up correctly in the test. Make sure:
1. `Get.testMode = true` is called in `setUp()`
2. Mock ServiceLocator is registered with `Get.put<ServiceLocator>(mockServiceLocator)`
3. `Get.reset()` is called in `tearDown()`

### Import errors
Make sure all imports use the correct package name (`flutter_app`). If your package name is different, update the imports accordingly.
