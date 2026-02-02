import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_app/domain/entities/analytics_entity.dart';
import 'package:flutter_app/domain/entities/device_data_entity.dart';
import 'package:flutter_app/presentation/bloc/device_vitals_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/device_vitals_bloc.dart';
import '../bloc/device_vitals_event.dart';
import '../widgets/cutsom_app_bar.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final ScrollController _scrollController = ScrollController();
  final int _itemsPerPage = 5;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _isAnalyticsExpanded = true;


  @override
  void initState() {
    super.initState();
    
    log('History Page - initState called');
    
    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
    
    // Fetch device vitals only - analytics will be auto-fetched by BLoC
    Future.microtask(() {
      log('History Page - Fetching device vitals');

      if(mounted){
        context.read<DeviceVitalsBloc>().add(FetchDeviceVitals(page: 1, limit: _itemsPerPage));
      }
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreData();
    }
  }

  void _loadMoreData() {
    final currentState = context.read<DeviceVitalsBloc>().state;
    if (currentState is DeviceVitalsLoaded && currentState.hasMore && !_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
        _currentPage++;
      });

      log('Loading page $_currentPage');
      context.read<DeviceVitalsBloc>().add(
        LoadMoreDeviceVitals(page: _currentPage, limit: _itemsPerPage),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'History' , actions: [],),
      backgroundColor: Colors.grey[50],
      body: BlocBuilder<DeviceVitalsBloc, DeviceVitalsState>(
        builder: (context, state) {
          log('History Page - Current State: ${state.runtimeType}');

          if (state is DeviceVitalsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is DeviceVitalsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DeviceVitalsBloc>().add(FetchDeviceVitals(page: 1, limit: _itemsPerPage));
                      context.read<DeviceVitalsBloc>().add(const FetchAnalytics());
                    },
                    child: const Text('Retry', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                  ),
                ],
              ),
            );
          }

          if (state is DeviceVitalsLoaded || state is DeviceVitalsLoadingMore) {
            final deviceData = state is DeviceVitalsLoaded
                ? state.deviceResponse.data
                : (state as DeviceVitalsLoadingMore).currentData.data;

            final hasMore = state is DeviceVitalsLoaded ? state.hasMore : true;

            if (state is DeviceVitalsLoaded) {
              _isLoadingMore = false;
            }

            if (deviceData.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No history data available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Post some device status to see history',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _currentPage = 1;
                });
                context.read<DeviceVitalsBloc>().add(const RefreshDeviceVitals());
                context.read<DeviceVitalsBloc>().add(const FetchAnalytics());
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: deviceData.length + 2 + (state is DeviceVitalsLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // Analytics card at index 0
                  if (index == 0) {
                    return BlocBuilder<DeviceVitalsBloc, DeviceVitalsState>(
                      builder: (context, analyticsState) {
                        return _buildExpandableAnalyticsCard(analyticsState);
                      },
                    );
                  }

                  // Data count indicator at index 1
                  if (index == 1) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Showing ${deviceData.length} records',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (hasMore)
                            Text(
                              'Scroll for more',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    );
                  }

                  // Loading indicator at the bottom
                  if (index == deviceData.length + 2) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  // History cards
                  return _buildHistoryCard(deviceData[index - 2], index - 2);
                },
              ),
            );
          }

          // Handle AnalyticsLoaded state - show empty state with analytics
          if (state is AnalyticsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _currentPage = 1;
                });
                context.read<DeviceVitalsBloc>().add(FetchDeviceVitals(page: 1, limit: _itemsPerPage));
                context.read<DeviceVitalsBloc>().add(const FetchAnalytics());
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildExpandableAnalyticsCard(state),
                  const SizedBox(height: 16),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No history data available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Post some device status to see history',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return  Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Server is down or unreachable',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<DeviceVitalsBloc>().add(FetchDeviceVitals(page: 1, limit: _itemsPerPage));
                    context.read<DeviceVitalsBloc>().add(const FetchAnalytics());
                  },
                  child: const Text('Load cached data', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                ),
              ],
            ),
          );
        }
      ),
    );
  }


  Widget _buildHistoryCard(DeviceDataEntity data, int index) {
    // Determine if it's a warning based on thermal value
    final isWarning = data.thermalValue > 45 || data.batteryLevel < 20;

    // Calculate time ago
    final now = DateTime.now();
    final difference = now.difference(data.timestamp);
    String timeAgo;
    if (difference.inMinutes < 60) {
      timeAgo = '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      timeAgo = '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      timeAgo = '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      child: InkWell(
        onTap: () => _showDetailDialog(context, data),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isWarning
                          ? Colors.orange.withValues(alpha:0.1)
                          : Colors.green.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isWarning ? Icons.warning_amber : Icons.check_circle,
                      color: isWarning ? Colors.orange : Colors.green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isWarning
                              ? 'Warning Detected'
                              : 'System Normal',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Device ID: ${data.deviceId}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetricChip(
                    icon: Icons.thermostat,
                    label: '${data.thermalValue}',
                    color: data.thermalValue > 45 ? Colors.red : Colors.orange,
                  ),
                  _buildMetricChip(
                    icon: Icons.battery_charging_full,
                    label: '${data.batteryLevel}%',
                    color: data.batteryLevel < 20 ? Colors.red : Colors.green,
                  ),
                  _buildMetricChip(
                    icon: Icons.memory,
                    label: '${(data.memoryUsage / 1024).toStringAsFixed(1)} GB',
                    color: Colors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeAgo,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


  void _showDetailDialog(BuildContext context, DeviceDataEntity data) {
    final isWarning = data.thermalValue > 45 || data.batteryLevel < 20;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Device Vitals Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Device ID', data.deviceId),
              _buildDetailRow('Timestamp', data.timestamp.toString().substring(0, 19)),
              const Divider(),
              _buildDetailRow('Thermal Value', '${data.thermalValue}'),
              _buildDetailRow('Battery Level', '${data.batteryLevel}%'),
              _buildDetailRow('Memory Usage', '${(data.memoryUsage / 1024).toStringAsFixed(2)} GB'),
              const Divider(),
              _buildDetailRow('Status', isWarning ? 'Warning' : 'Normal'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableAnalyticsCard(DeviceVitalsState state) {
    // Extract analytics from DeviceVitalsLoaded state if available
    AnalyticsEntity? analytics;
    bool isLoadingAnalytics = false;
    
    if (state is DeviceVitalsLoaded) {
      analytics = state.analytics;
      isLoadingAnalytics = state.isLoadingAnalytics;
    } else if (state is AnalyticsLoaded) {
      analytics = state.analytics;
    }
    
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isAnalyticsExpanded = !_isAnalyticsExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.analytics,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Analytics (Last 10 Records)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    _isAnalyticsExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          if (_isAnalyticsExpanded) ...[
            const Divider(height: 1),
            if (isLoadingAnalytics || state is AnalyticsLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (analytics != null)
              _buildAnalyticsContent(analytics)
            else if (state is AnalyticsError)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Pull to refresh analytics',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent(AnalyticsEntity analytics) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsItem(
                  'Avg Thermal',
                  analytics.avgThermalValue.toStringAsFixed(1),
                  Icons.thermostat,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAnalyticsItem(
                  'Avg Battery',
                  '${analytics.avgBatteryLevel.toStringAsFixed(1)}%',
                  Icons.battery_charging_full,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsItem(
                  'Avg Memory',
                  '${(analytics.avgMemoryUsage / 1024).toStringAsFixed(1)} GB',
                  Icons.memory,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAnalyticsItem(
                  'Max Thermal',
                  analytics.maxThermalValue.toStringAsFixed(1),
                  Icons.trending_up,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsItem(
                  'Min Battery',
                  '${analytics.minBatteryLevel.toStringAsFixed(1)}%',
                  Icons.battery_alert,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAnalyticsItem(
                  'Max Memory',
                  '${(analytics.maxMemoryUsage / 1024).toStringAsFixed(1)} GB',
                  Icons.storage,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildAnalyticsItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }}

