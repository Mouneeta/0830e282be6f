import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:get/get.dart';
import 'config/routes/app_router.dart';
import 'core/resources/service_locator.dart';
import 'data/repositories/device_repository_impl.dart';
import 'domain/repository/device_repository.dart';
import 'domain/usecases/fetch_analytics_usecase.dart';
import 'domain/usecases/fetch_device_status_usecase.dart';
import 'domain/usecases/post_device_vitals_usecase.dart';
import 'presentation/page/splash_screen.dart';

final GetIt getIt = GetIt.instance;
final GlobalKey<NavigatorState> mNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  // Initialize GetX ServiceLocator
  Get.put(ServiceLocator());
  
  // Setup GetIt dependency injection
  setupDependencies();
  
  runApp(const MyApp());
}

void setupDependencies() {
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class VitalMonitor extends StatelessWidget {
  VitalMonitor({
    super.key,
  });
  final AppRouter router = AppRouter(mNavigatorKey);

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
    // Size of the device the designer uses in their designs on Figma
    designSize: const Size(428, 926),
    builder: (_, _) {
      return MaterialApp.router(
        onGenerateTitle: (_) => 'Vital Monitor',
        debugShowCheckedModeBanner: false,
        routerDelegate: router.appRouter.routerDelegate,
        routeInformationParser: router.appRouter.routeInformationParser,
        routeInformationProvider: router.appRouter.routeInformationProvider,
        builder: (context, child) {
          final MediaQueryData data = MediaQuery.of(context);

          return MediaQuery(
            data: data.copyWith(textScaler: const TextScaler.linear(1.0)),
            child: Material(
              child: child
            ),
          );
        },
      );
    },
  );
}

