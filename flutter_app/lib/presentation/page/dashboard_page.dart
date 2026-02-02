import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/platform/device_vitals_channel.dart';
import '../../domain/entities/analytics_entity.dart';
import '../bloc/device_vitals_bloc.dart';
import '../bloc/device_vitals_event.dart';
import '../bloc/device_vitals_state.dart';
import '../widgets/cutsom_app_bar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic> deviceStatus = {};
  StreamSubscription? _blocSubscription;

  @override
  void initState() {
    super.initState();
    fetchDeviceStatus();

    // Fetch analytics for performance overview
    /* Future.microtask(() {
      context.read<DeviceVitalsBloc>().add(const FetchAnalytics());
    });*/

    // Option 1: manual Bloc listener
    final bloc = context.read<DeviceVitalsBloc>();
    _blocSubscription = bloc.stream.listen((state) {
      // if (!mounted) return;

      if (state is DeviceVitalsPosting && mounted) {
        // show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      } else {
        // close loading dialog if open
        if(mounted){
          if (Navigator.canPop(context)) Navigator.of(context).pop();
        }
      }

      if (state is DeviceVitalsPosted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device status posted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (state is DeviceVitalsPostError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post status: ${state.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _blocSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchDeviceStatus() async {
    final status = await DeviceVitalChannel().getDeviceStatus();
    if (!mounted) return;

    setState(() {
      deviceStatus = status;
      log("Device Status: $deviceStatus");
    });
  }

  void _postDeviceStatus() {
    if (deviceStatus.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No device data available to post'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    context.read<DeviceVitalsBloc>().add(
      PostDeviceVitals(
        deviceId: deviceStatus['device_id']?.toString() ?? 'UNKNOWN',
        thermalValue: deviceStatus['thermal_value'] ?? 0,
        batteryLevel: deviceStatus['battery_level'] ?? 0,
        memoryUsage: deviceStatus['memory_usage'] ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(title: 'Device Vitals', actions: []),
      body: RefreshIndicator(
        onRefresh: fetchDeviceStatus,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Device ID
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.devices, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "Device ID: ${deviceStatus["device_id"] ?? 'N/A'}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Metric Cards
            _buildMetricsGrid(deviceStatus),
            const SizedBox(height: 24),

            // Post Status Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BlocBuilder<DeviceVitalsBloc, DeviceVitalsState>(
                  builder: (context, state) {
                    final isLoading = state is DeviceVitalsPosting;

                    return ElevatedButton(
                      onPressed: isLoading ? null : _postDeviceStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        elevation: 2,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.cloud_upload),
                                SizedBox(width: 8),
                                Text(
                                  'Post Status',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                    );
                  },
                ),

                ElevatedButton.icon(
                  onPressed: ()=> fetchDeviceStatus(),
                  icon: const Icon(Icons.refresh),
                  label: const Text(
                    'Refresh Status',
                    style: TextStyle(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Performance Overview Chart with Analytics
            BlocBuilder<DeviceVitalsBloc, DeviceVitalsState>(
              builder: (context, state) {
                if (state is DeviceVitalsLoaded && state.analytics != null) {
                  return _buildChartSection(context, state.analytics!);
                } else if (state is AnalyticsLoaded) {
                  return _buildChartSection(context, state.analytics);
                } else if (state is AnalyticsLoading) {
                  return _buildChartSectionLoading(context);
                } else {
                  return _buildChartSectionPlaceholder(context);
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(Map<String, dynamic> deviceData) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.2,
      children: [
        _buildMetricCard(
          title: 'Battery',
          value: '${deviceData["battery_level"] ?? 'N/A'}%',
          color: Colors.green,
          icon: Icon(
            Icons.battery_unknown_rounded,
            color: Colors.green,
            size: 25,
          ),
        ),
        _buildMetricCard(
          title: 'Thermal',
          value: '${deviceData["thermal_value"] ?? 'N/A'}°C',
          color: Colors.orange,
          icon: Icon(Icons.thermostat, color: Colors.orange, size: 25),
        ),
        _buildMetricCard(
          title: 'Memory',
          value: '${deviceData["memory_usage"] ?? 'N/A'}',
          color: Colors.blue,
          icon: Icon(Icons.memory, color: Colors.blue, size: 25),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color color,
    required Icon icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              icon,
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(BuildContext context, AnalyticsEntity analytics) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Performance Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Analytics Metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAnalyticsMetric(
                'Avg Thermal',
                '${analytics.avgThermalValue.toStringAsFixed(1)}°C',
                Colors.orange,
                Icons.thermostat,
              ),
              _buildAnalyticsMetric(
                'Avg Battery',
                '${analytics.avgBatteryLevel.toStringAsFixed(1)}%',
                Colors.green,
                Icons.battery_charging_full,
              ),
              _buildAnalyticsMetric(
                'Avg Memory',
                '${(analytics.avgMemoryUsage).toStringAsFixed(0)} MB',
                Colors.blue,
                Icons.memory,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

          // Min/Max Comparison Chart
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildComparisonBar(
                  'Thermal',
                  analytics.avgThermalValue.toDouble(),
                  analytics.maxThermalValue.toDouble(),
                  100.0,
                  Colors.orange,
                ),
                _buildComparisonBar(
                  'Battery',
                  analytics.minBatteryLevel.toDouble(),
                  analytics.avgBatteryLevel.toDouble(),
                  100.0,
                  Colors.green,
                ),
                _buildComparisonBar(
                  'Memory',
                  analytics.avgMemoryUsage.toDouble(),
                  analytics.maxMemoryUsage.toDouble(),
                  analytics.maxMemoryUsage > 0
                      ? analytics.maxMemoryUsage.toDouble()
                      : 100.0,
                  Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSectionLoading(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildChartSectionPlaceholder(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'No analytics data available',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAnalyticsMetric(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildComparisonBar(
    String label,
    double value1,
    double value2,
    double maxValue,
    Color color,
  ) {
    final height1 = (value1 / maxValue * 120).clamp(10.0, 120.0);
    final height2 = (value2 / maxValue * 120).clamp(10.0, 120.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              children: [
                Text(
                  value1.toStringAsFixed(0),
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 20,
                  height: height1,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            Column(
              children: [
                Text(
                  value2.toStringAsFixed(0),
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 20,
                  height: height2,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }
}
