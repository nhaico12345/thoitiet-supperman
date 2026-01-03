part of 'weather_bloc.dart';

enum WeatherStatus { initial, loading, success, failure, refreshing, cached }

abstract class WeatherState extends Equatable {
  final WeatherEntity? weather;
  final Exception? error;
  final List<Recommendation> recommendations;
  final bool isAILoading;
  final String? weatherSummary;
  final DateTime? lastAIFetchTime;
  final String? aiErrorMessage;
  final String? ootdAdvice;
  final List<String>? smartWarnings;
  final WeatherStatus status;

  const WeatherState({
    this.weather,
    this.error,
    this.recommendations = const [],
    this.isAILoading = false,
    this.weatherSummary,
    this.lastAIFetchTime,
    this.aiErrorMessage,
    this.ootdAdvice,
    this.smartWarnings,
    this.status = WeatherStatus.initial,
  });

  @override
  List<Object?> get props => [
    weather,
    error,
    recommendations,
    isAILoading,
    weatherSummary,
    lastAIFetchTime,
    aiErrorMessage,
    ootdAdvice,
    smartWarnings,
    status,
  ];
}

class WeatherLoading extends WeatherState {
  const WeatherLoading() : super(status: WeatherStatus.loading);
}

class WeatherLoaded extends WeatherState {
  const WeatherLoaded(
    WeatherEntity weather, {
    super.recommendations = const [],
    super.isAILoading = false,
    super.weatherSummary,
    super.lastAIFetchTime,
    super.aiErrorMessage,
    super.ootdAdvice,
    super.smartWarnings,
    super.status = WeatherStatus.success,
  }) : super(weather: weather);

  WeatherLoaded copyWith({
    WeatherEntity? weather,
    List<Recommendation>? recommendations,
    bool? isAILoading,
    String? weatherSummary,
    DateTime? lastAIFetchTime,
    String? aiErrorMessage,
    String? ootdAdvice,
    List<String>? smartWarnings,
    WeatherStatus? status,
  }) {
    return WeatherLoaded(
      weather ?? this.weather!,
      recommendations: recommendations ?? this.recommendations,
      isAILoading: isAILoading ?? this.isAILoading,
      weatherSummary: weatherSummary ?? this.weatherSummary,
      lastAIFetchTime: lastAIFetchTime ?? this.lastAIFetchTime,
      aiErrorMessage: aiErrorMessage, // Can be null to clear error
      ootdAdvice: ootdAdvice ?? this.ootdAdvice,
      smartWarnings: smartWarnings ?? this.smartWarnings,
      status: status ?? this.status,
    );
  }
}

class WeatherError extends WeatherState {
  const WeatherError(Exception error)
    : super(error: error, status: WeatherStatus.failure);
}
