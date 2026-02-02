import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
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
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    fetchDeviceStatus();

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
    setState(() {
      _isRefreshing = true;
    });

    final status = await DeviceVitalChannel().getDeviceStatus();
    if (!mounted) return;

    setState(() {
      deviceStatus = status;
      _isRefreshing = false;
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
                  onPressed: _isRefreshing ? null : () => fetchDeviceStatus(),
                  icon: _isRefreshing
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
                      : const Icon(Icons.refresh),
                  label: Text(
                    _isRefreshing ? 'Refreshing...' : 'Refresh Status',
                    style: const TextStyle(fontSize: 14),
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
          value: '${deviceData["thermal_value"] ?? 'N/A'}',
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
          title == 'Thermal' ?
          Text(
            value == '0' ? 'None (0)' : value == '1' ? 'Low (1)' : value == '2' ? 'Moderate (2)' : value == '3' ? 'Severe (3)' : 'High ($value)',
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ) :
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          )
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
                analytics.avgThermalValue.toStringAsFixed(1),
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
          const SizedBox(height: 10),

          // Chart Title
          const Text(
            'Min, Average & Max Values',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Bar Chart using fl_chart
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.grey[800]!,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String label;
                      String unit;
                      num actualValue;

                      switch (groupIndex) {
                        case 0: // Thermal
                          unit = '';
                          if (rodIndex == 0) {
                            label = 'Average';
                            actualValue = analytics.avgThermalValue;
                          } else {
                            label = 'Maximum';
                            actualValue = analytics.maxThermalValue;
                          }
                          break;
                        case 1: // Battery
                          unit = '%';
                          if (rodIndex == 0) {
                            label = 'Minimum';
                            actualValue = analytics.minBatteryLevel.toDouble();
                          } else {
                            label = 'Average';
                            actualValue = analytics.avgBatteryLevel.toDouble();
                          }
                          break;
                        case 2: // Memory
                          unit = ' MB';
                          if (rodIndex == 0) {
                            label = 'Average';
                            actualValue = analytics.avgMemoryUsage.toDouble();
                          } else {
                            label = 'Maximum';
                            actualValue = analytics.maxMemoryUsage.toDouble();
                          }
                          break;
                        default:
                          label = '';
                          unit = '';
                          actualValue = 0;
                      }
                      return BarTooltipItem(
                        '$label\n${actualValue.toStringAsFixed(1)}$unit',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        );
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Thermal)', style: style, textAlign: TextAlign.center);
                          case 1:
                            return const Text('Battery\n(%)', style: style, textAlign: TextAlign.center);
                          case 2:
                            return const Text('Memory\n(MB)', style: style, textAlign: TextAlign.center);
                          default:
                            return const Text('');
                        }
                      },
                      reservedSize: 40,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: [
                  // Thermal (Avg vs Max)
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: analytics.avgThermalValue.toDouble(),
                        color: Colors.orange.withValues(alpha: 0.6),
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                      BarChartRodData(
                        toY: analytics.maxThermalValue.toDouble(),
                        color: Colors.orange,
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                  // Battery (Min vs Avg)
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: analytics.minBatteryLevel.toDouble(),
                        color: Colors.green.withValues(alpha: 0.6),
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                      BarChartRodData(
                        toY: analytics.avgBatteryLevel.toDouble(),
                        color: Colors.green,
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                  // Memory (Avg vs Max) - normalized to 100 scale
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: _normalizeMemory(
                          analytics.avgMemoryUsage.toDouble(),
                          analytics.maxMemoryUsage.toDouble(),
                        ),
                        color: Colors.blue.withValues(alpha: 0.6),
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                      BarChartRodData(
                        toY: _normalizeMemory(
                          analytics.maxMemoryUsage.toDouble(),
                          analytics.maxMemoryUsage.toDouble(),
                        ),
                        color: Colors.blue,
                        width: 16,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend with better explanation
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem('Thermal: Avg & Max', Colors.orange),
              _buildLegendItem('Battery: Min & Avg', Colors.green),
              _buildLegendItem('Memory: Avg & Max', Colors.blue),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Tap on bars to see exact values',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _normalizeMemory(double value, double maxValue) {
    if (maxValue == 0) return 0;
    return (value / maxValue * 100).clamp(0, 100);
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
}
