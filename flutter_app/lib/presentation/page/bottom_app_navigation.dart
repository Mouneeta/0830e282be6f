import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/device_vitals_bloc.dart';
import '../../main.dart';
import 'dashboard_page.dart';
import 'history_page.dart';

class BottomAppNavigation extends StatefulWidget {
  const BottomAppNavigation({super.key});

  @override
  State<BottomAppNavigation> createState() => _BottomAppNavigationState();
}

class _BottomAppNavigationState extends State<BottomAppNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeviceVitalsBloc(
        fetchDeviceStatusUseCase: getIt(),
        postDeviceVitalsUseCase: getIt(),
        fetchAnalyticsUseCase: getIt(),
      ),
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            DashboardPage(),
            HistoryPage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}
