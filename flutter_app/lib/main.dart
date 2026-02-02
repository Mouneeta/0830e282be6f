import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:get/get.dart';
import 'core/resources/service_locator.dart';
import 'core/storage/hive_init.dart';
import 'data/data_source/local/local_storage_service.dart';
import 'data/repositories/device_repository_impl.dart';
import 'domain/repository/device_repository.dart';
import 'domain/usecases/fetch_analytics_usecase.dart';
import 'domain/usecases/fetch_device_status_usecase.dart';
import 'domain/usecases/post_device_vitals_usecase.dart';
import 'presentation/page/splash_screen.dart';

final GetIt getIt = GetIt.instance;
final GlobalKey<NavigatorState> mNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await HiveInit.initialize();
  
  // Initialize GetX ServiceLocator
  Get.put(ServiceLocator());
  
  // Setup GetIt dependency injection
  await setupDependencies();
  
  runApp(const MyApp());
}

Future<void> setupDependencies() async {
  // Register Local Storage Service
  final localStorageService = LocalStorageService();
  await localStorageService.init();
  getIt.registerSingleton<LocalStorageService>(localStorageService);
  
  // Register Repository
  getIt.registerLazySingleton<DeviceRepository>(
    () => DeviceRepositoryImpl(),
  );
  
  // Register Use Cases
  getIt.registerLazySingleton<FetchDeviceStatusUseCase>(
    () => FetchDeviceStatusUseCase(getIt<DeviceRepository>()),
  );
  
  getIt.registerLazySingleton<PostDeviceVitalsUseCase>(
    () => PostDeviceVitalsUseCase(getIt<DeviceRepository>()),
  );
  
  getIt.registerLazySingleton<FetchAnalyticsUseCase>(
    () => FetchAnalyticsUseCase(getIt<DeviceRepository>()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Device Vitals',
      home: const SplashScreen(),
    );
  }
}


