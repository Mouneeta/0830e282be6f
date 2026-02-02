import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/analytics_entity.dart';
import '../../domain/entities/device_response_entity.dart';
import '../../domain/usecases/fetch_analytics_usecase.dart';
import '../../domain/usecases/fetch_device_status_usecase.dart';
import '../../domain/usecases/post_device_vitals_usecase.dart';
import 'device_vitals_event.dart';
import 'device_vitals_state.dart';

class DeviceVitalsBloc extends Bloc<DeviceVitalsEvent, DeviceVitalsState> {
  final FetchDeviceStatusUseCase fetchDeviceStatusUseCase;
  final PostDeviceVitalsUseCase postDeviceVitalsUseCase;
  final FetchAnalyticsUseCase fetchAnalyticsUseCase;
  List<dynamic> _allData = [];


  DeviceVitalsBloc({
    required this.fetchDeviceStatusUseCase,
    required this.postDeviceVitalsUseCase,
    required this.fetchAnalyticsUseCase,
  }) : super(const DeviceVitalsInitial()) {
    on<FetchDeviceVitals>(_onFetchDeviceVitals);
    on<RefreshDeviceVitals>(_onRefreshDeviceVitals);
    on<LoadMoreDeviceVitals>(_onLoadMoreDeviceVitals);
    on<PostDeviceVitals>(_onPostDeviceVitals);
    on<FetchAnalytics>(_onFetchAnalytics);
  }

  Future<void> _onFetchDeviceVitals(
    FetchDeviceVitals event,
    Emitter<DeviceVitalsState> emit,
  ) async {
    log('BLoC - FetchDeviceVitals event received: page=${event.page}, limit=${event.limit}');
    
    // Preserve current analytics if available from any state
    AnalyticsEntity? currentAnalytics;
    if (state is DeviceVitalsLoaded) {
      currentAnalytics = (state as DeviceVitalsLoaded).analytics;
    } else if (state is AnalyticsLoaded) {
      currentAnalytics = (state as AnalyticsLoaded).analytics;
    }
    
    emit(const DeviceVitalsLoading());
    try {
      final deviceResponse = await fetchDeviceStatusUseCase.execute(
        page: event.page ?? 1,
        limit: event.limit ?? 5,
      );
      log('BLoC - Device vitals fetched successfully: ${deviceResponse.data.length} items');
      _allData = deviceResponse.data;
      
      // Include analytics if we had them
      emit(DeviceVitalsLoaded(
        deviceResponse, 
        hasMore: deviceResponse.data.length >= (event.limit ?? 5),
        analytics: currentAnalytics,
      ));
      
      // Auto-fetch analytics after device vitals load if we don't have them yet
      if (currentAnalytics == null) {
        log('BLoC - Auto-fetching analytics after device vitals loaded');
        add(const FetchAnalytics());
      }
    } catch (e) {
      log('BLoC - Error fetching device vitals: $e');
      emit(DeviceVitalsError(e.toString()));
    }
  }

  Future<void> _onRefreshDeviceVitals(
    RefreshDeviceVitals event,
    Emitter<DeviceVitalsState> emit,
  ) async {
    // Preserve current analytics if available
    AnalyticsEntity? currentAnalytics;
    if (state is DeviceVitalsLoaded) {
      currentAnalytics = (state as DeviceVitalsLoaded).analytics;
    }
    
    try {
      _allData = [];
      final deviceResponse = await fetchDeviceStatusUseCase.execute(page: 1, limit: 5);
      _allData = deviceResponse.data;
      
      // Restore analytics if we had them
      emit(DeviceVitalsLoaded(
        deviceResponse, 
        hasMore: deviceResponse.data.length >= 5,
        analytics: currentAnalytics,
      ));
    } catch (e) {
      emit(DeviceVitalsError(e.toString()));
    }
  }

  Future<void> _onLoadMoreDeviceVitals(
    LoadMoreDeviceVitals event,
    Emitter<DeviceVitalsState> emit,
  ) async {
    if (state is DeviceVitalsLoaded) {
      final currentState = state as DeviceVitalsLoaded;
      emit(DeviceVitalsLoadingMore(currentState.deviceResponse));
      
      try {
        final newData = await fetchDeviceStatusUseCase.execute(
          page: event.page,
          limit: event.limit,
        );
        
        _allData.addAll(newData.data);
        
        final combinedResponse = DeviceResponseEntity(
          count: _allData.length,
          data: List.from(_allData),
        );
        
        // Preserve analytics
        emit(DeviceVitalsLoaded(
          combinedResponse,
          hasMore: newData.data.length >= event.limit,
          analytics: currentState.analytics,
        ));
      } catch (e) {
        emit(DeviceVitalsError(e.toString()));
      }
    }
  }

  Future<void> _onPostDeviceVitals(
    PostDeviceVitals event,
    Emitter<DeviceVitalsState> emit,
  ) async {
    // Preserve current analytics if available
    AnalyticsEntity? currentAnalytics;
    if (state is DeviceVitalsLoaded) {
      currentAnalytics = (state as DeviceVitalsLoaded).analytics;
    }
    
    emit(const DeviceVitalsPosting());
    try {
      await postDeviceVitalsUseCase.execute(
        deviceId: event.deviceId,
        thermalValue: event.thermalValue,
        batteryLevel: event.batteryLevel,
        memoryUsage: event.memoryUsage,
      );
      emit(const DeviceVitalsPosted('Status posted successfully!'));
      
      // Refresh data after posting
      final deviceResponse = await fetchDeviceStatusUseCase.execute(page: 1, limit: 5);
      _allData = deviceResponse.data;
      
      // Restore analytics if we had them
      emit(DeviceVitalsLoaded(
        deviceResponse, 
        hasMore: deviceResponse.data.length >= 5,
        analytics: currentAnalytics,
      ));
      
      // Fetch fresh analytics
      add(const FetchAnalytics());
    } catch (e) {
      emit(DeviceVitalsPostError(e.toString()));
    }
  }

  Future<void> _onFetchAnalytics(
    FetchAnalytics event,
    Emitter<DeviceVitalsState> emit,
  ) async {
    log('BLoC - FetchAnalytics event received');
    // If we already have device vitals loaded, update the state with loading analytics
    if (state is DeviceVitalsLoaded) {
      final currentState = state as DeviceVitalsLoaded;
      log('BLoC - Updating existing DeviceVitalsLoaded state with analytics');
      emit(currentState.copyWith(isLoadingAnalytics: true));
      
      try {
        final analytics = await fetchAnalyticsUseCase.execute();
        log('BLoC - Analytics fetched successfully');
        emit(currentState.copyWith(
          analytics: analytics,
          isLoadingAnalytics: false,
        ));
      } catch (e) {
        log('BLoC - Error fetching analytics: $e');
        emit(currentState.copyWith(isLoadingAnalytics: false));
        // Optionally emit error state or just keep current state
      }
    } else {
      log('BLoC - No DeviceVitalsLoaded state, emitting standalone analytics states');
      // If no device vitals loaded yet, just emit analytics states
      emit(const AnalyticsLoading());
      try {
        final analytics = await fetchAnalyticsUseCase.execute();
        log('BLoC - Analytics fetched successfully (standalone)');
        emit(AnalyticsLoaded(analytics));
      } catch (e) {
        log('BLoC - Error fetching analytics (standalone): $e');
        emit(AnalyticsError(e.toString()));
        emit(DeviceVitalsError(e.toString()));
      }
    }
  }
}