import 'package:equatable/equatable.dart';
import '../../domain/entities/analytics_entity.dart';
import '../../domain/entities/device_response_entity.dart';

abstract class DeviceVitalsState extends Equatable {
  const DeviceVitalsState();

  @override
  List<Object> get props => [];
}

class DeviceVitalsInitial extends DeviceVitalsState {
  const DeviceVitalsInitial();
}

class DeviceVitalsLoading extends DeviceVitalsState {
  const DeviceVitalsLoading();
}

class DeviceVitalsLoaded extends DeviceVitalsState {
  final DeviceResponseEntity deviceResponse;
  final bool hasMore;
  final AnalyticsEntity? analytics;
  final bool isLoadingAnalytics;

  const DeviceVitalsLoaded(
    this.deviceResponse, {
    this.hasMore = true,
    this.analytics,
    this.isLoadingAnalytics = false,
  });

  @override
  List<Object> get props => [deviceResponse, hasMore, analytics ?? '', isLoadingAnalytics];
  
  DeviceVitalsLoaded copyWith({
    DeviceResponseEntity? deviceResponse,
    bool? hasMore,
    AnalyticsEntity? analytics,
    bool? isLoadingAnalytics,
  }) {
    return DeviceVitalsLoaded(
      deviceResponse ?? this.deviceResponse,
      hasMore: hasMore ?? this.hasMore,
      analytics: analytics ?? this.analytics,
      isLoadingAnalytics: isLoadingAnalytics ?? this.isLoadingAnalytics,
    );
  }
}

class DeviceVitalsLoadingMore extends DeviceVitalsState {
  final DeviceResponseEntity currentData;
  
  const DeviceVitalsLoadingMore(this.currentData);
  
  @override
  List<Object> get props => [currentData];
}

class DeviceVitalsError extends DeviceVitalsState {
  final String message;

  const DeviceVitalsError(this.message);

  @override
  List<Object> get props => [message];
}

class DeviceVitalsPosting extends DeviceVitalsState {
  const DeviceVitalsPosting();
}

class DeviceVitalsPosted extends DeviceVitalsState {
  final String message;

  const DeviceVitalsPosted(this.message);

  @override
  List<Object> get props => [message];
}

class DeviceVitalsPostError extends DeviceVitalsState {
  final String message;

  const DeviceVitalsPostError(this.message);

  @override
  List<Object> get props => [message];
}

class AnalyticsLoading extends DeviceVitalsState {
  const AnalyticsLoading();
}

class AnalyticsLoaded extends DeviceVitalsState {
  final AnalyticsEntity analytics;

  const AnalyticsLoaded(this.analytics);

  @override
  List<Object> get props => [analytics];
}

class AnalyticsError extends DeviceVitalsState {
  final String message;

  const AnalyticsError(this.message);

  @override
  List<Object> get props => [message];
}
