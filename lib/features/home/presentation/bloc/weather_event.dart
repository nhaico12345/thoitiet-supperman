part of 'weather_bloc.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => [];
}

class GetWeather extends WeatherEvent {
  final bool forceRefresh;
  const GetWeather({this.forceRefresh = false});

  @override
  List<Object> get props => [forceRefresh];
}

class GetAIAdvice extends WeatherEvent {
  const GetAIAdvice();
}
