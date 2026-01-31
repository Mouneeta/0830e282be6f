import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_app/config/routes/route_names.dart';
import 'package:go_router/go_router.dart';

import '../../main.dart';
import '../../presentation/page/splash_screen.dart';

class AppRouter {
  AppRouter(GlobalKey<NavigatorState> mNavigatorKey) {
    appRouter = _getAppRouter(mNavigatorKey);
  }

  /// Use this for testing to change the initial
  /// location and quickly access some page
  @visibleForTesting
  String setInitialLocation(String location) => initialLocation = location;

  late GoRouter appRouter;
  static String initialLocation = RoutePaths.splash;
  static List<String> backStack = [];

  GoRouter _getAppRouter(GlobalKey<NavigatorState> mNavigatorKey) => GoRouter(
    initialLocation: initialLocation,
    navigatorKey: mNavigatorKey,
    debugLogDiagnostics: true,
    onException: (context, state, router) {},
    observers: [MyNavigatorObserver(), getIt<RouteObserver<PageRoute>>()],
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      /*GoRoute(
        path: RoutePaths.dashboard,
        name: RouteNames.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),*/
     /* GoRoute(
        path: RoutePaths.history,
        name: RouteNames.history,
        builder: (context, state) => const HistoryScreen(),
      ),*/
    ],
  );
}

class MyNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppRouter.backStack.add(route.settings.name ?? '');
    log('did push route ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppRouter.backStack.removeLast();
    log('did pop route ${route.settings.name}');
  }
}
