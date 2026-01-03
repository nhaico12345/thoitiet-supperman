// Entity chính chứa dữ liệu thời tiết (14 thuộc tính).
// Bao gồm nhiệt độ, gió, UV, AQI, dự báo theo giờ và theo ngày.

import 'package:equatable/equatable.dart';

class WeatherEntity extends Equatable {
  final double? temperature;
  final double? windSpeed;
  final int? weatherCode;
  final String? lastUpdated;

  // Các chỉ số môi trường
  final double? uvIndex;
  final int? humidity;
  final double? feelsLike;
  final double? pressure;
  final String? sunrise;
  final String? sunset;

  // Tên vị trí
  final String? locationName;

  // Chỉ số chất lượng không khí
  final int? aqi;

  // Dự báo
  final List<HourlyForecast>? hourlyForecasts;
  final List<DailyForecast>? dailyForecasts;

  const WeatherEntity({
    this.temperature,
    this.windSpeed,
    this.weatherCode,
    this.lastUpdated,
    this.uvIndex,
    this.humidity,
    this.feelsLike,
    this.pressure,
    this.sunrise,
    this.sunset,
    this.locationName,
    this.aqi,
    this.hourlyForecasts,
    this.dailyForecasts,
  });

  @override
  List<Object?> get props => [
    temperature,
    windSpeed,
    weatherCode,
    lastUpdated,
    uvIndex,
    humidity,
    feelsLike,
    pressure,
    sunrise,
    sunset,
    locationName,
    aqi,
    hourlyForecasts,
    dailyForecasts,
  ];
}

class HourlyForecast extends Equatable {
  final String time;
  final double temperature;
  final int precipitationProbability;
  final int weatherCode;
  final double windSpeed;

  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.precipitationProbability,
    required this.weatherCode,
    required this.windSpeed,
  });

  @override
  List<Object?> get props => [
    time,
    temperature,
    precipitationProbability,
    weatherCode,
    windSpeed,
  ];
}

class DailyForecast extends Equatable {
  final String date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;
  final double uvMax;

  const DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
    required this.uvMax,
  });

  @override
  List<Object?> get props => [date, maxTemp, minTemp, weatherCode, uvMax];
}
