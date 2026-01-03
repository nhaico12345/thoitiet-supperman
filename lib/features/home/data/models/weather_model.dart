// Model dữ liệu thời tiết để lưu Hive và parse JSON từ API.
// Chuyển đổi response API thành WeatherEntity với đầy đủ dự báo giờ/ngày.

import 'package:hive/hive.dart';
import '../../domain/entities/weather.dart';

part 'weather_model.g.dart';

@HiveType(typeId: 0)
class WeatherModel extends WeatherEntity {
  @HiveField(0)
  @override
  final double? temperature;
  @HiveField(1)
  @override
  final double? windSpeed;
  @HiveField(2)
  @override
  final int? weatherCode;
  @HiveField(3)
  @override
  final String? lastUpdated;

  @HiveField(4)
  @override
  final double? uvIndex;
  @HiveField(5)
  @override
  final int? humidity;
  @HiveField(6)
  @override
  final double? feelsLike;
  @HiveField(7)
  @override
  final double? pressure;
  @HiveField(8)
  @override
  final String? sunrise;
  @HiveField(9)
  @override
  final String? sunset;
  @HiveField(10)
  @override
  final int? aqi;

  @HiveField(13)
  @override
  final String? locationName;

  @HiveField(11)
  @override
  final List<HourlyForecastModel>? hourlyForecasts;
  @HiveField(12)
  @override
  final List<DailyForecastModel>? dailyForecasts;

  const WeatherModel({
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
    this.aqi,
    this.locationName,
    this.hourlyForecasts,
    this.dailyForecasts,
  }) : super(
         temperature: temperature,
         windSpeed: windSpeed,
         weatherCode: weatherCode,
         lastUpdated: lastUpdated,
         uvIndex: uvIndex,
         humidity: humidity,
         feelsLike: feelsLike,
         pressure: pressure,
         sunrise: sunrise,
         sunset: sunset,
         aqi: aqi,
         locationName: locationName,
         hourlyForecasts: hourlyForecasts,
         dailyForecasts: dailyForecasts,
       );

  factory WeatherModel.fromJson(
    Map<String, dynamic> json, {
    int? aqi,
    String? locationName,
  }) {
    final current = json['current'] ?? {};
    final hourly = json['hourly'] ?? {};
    final daily = json['daily'] ?? {};

    List<HourlyForecastModel> hourlyList = [];
    if (hourly['time'] != null) {
      final times = hourly['time'] as List;
      final now = DateTime.now();

      // Tìm index của giờ hiện tại hoặc giờ gần nhất trong tương lai
      int startIndex = 0;
      for (int i = 0; i < times.length; i++) {
        final timeStr = times[i] as String;
        final time = DateTime.tryParse(timeStr);
        if (time != null &&
            (time.isAfter(now) ||
                time.hour == now.hour && time.day == now.day)) {
          startIndex = i;
          break;
        }
      }

      // Lấy 24 giờ tiếp theo từ giờ hiện tại
      for (
        int i = startIndex;
        i < times.length && hourlyList.length < 24;
        i++
      ) {
        hourlyList.add(
          HourlyForecastModel(
            time: hourly['time'][i],
            temperature: (hourly['temperature_2m'][i] as num).toDouble(),
            precipitationProbability:
                hourly['precipitation_probability'][i] as int,
            weatherCode: hourly['weathercode'][i] as int,
            windSpeed:
                (hourly['wind_speed_10m']?[i] as num?)?.toDouble() ?? 0.0,
          ),
        );
      }
    }

    List<DailyForecastModel> dailyList = [];
    if (daily['time'] != null) {
      for (int i = 0; i < (daily['time'] as List).length; i++) {
        dailyList.add(
          DailyForecastModel(
            date: daily['time'][i],
            maxTemp: (daily['temperature_2m_max'][i] as num).toDouble(),
            minTemp: (daily['temperature_2m_min'][i] as num).toDouble(),
            weatherCode: daily['weathercode'][i] as int,
            uvMax: (daily['uv_index_max'][i] as num).toDouble(),
          ),
        );
      }
    }

    String? sunriseStr;
    String? sunsetStr;
    if (daily['sunrise'] != null && (daily['sunrise'] as List).isNotEmpty) {
      sunriseStr = daily['sunrise'][0];
    }
    if (daily['sunset'] != null && (daily['sunset'] as List).isNotEmpty) {
      sunsetStr = daily['sunset'][0];
    }

    return WeatherModel(
      temperature: (current['temperature_2m'] as num?)?.toDouble(),
      windSpeed: (current['wind_speed_10m'] as num?)?.toDouble(),
      weatherCode: current['weathercode'] as int?,
      lastUpdated: DateTime.now().toIso8601String(),
      uvIndex:
          (daily['uv_index_max'] != null &&
              (daily['uv_index_max'] as List).isNotEmpty)
          ? (daily['uv_index_max'][0] as num).toDouble()
          : null, // Approximation using max UV of day
      humidity: current['relative_humidity_2m'] as int?,
      feelsLike: (current['apparent_temperature'] as num?)?.toDouble(),
      pressure: (current['surface_pressure'] as num?)?.toDouble(),
      sunrise: sunriseStr,
      sunset: sunsetStr,
      aqi: aqi,
      locationName: locationName,
      hourlyForecasts: hourlyList,
      dailyForecasts: dailyList,
    );
  }
}

@HiveType(typeId: 1)
class HourlyForecastModel extends HourlyForecast {
  @HiveField(0)
  @override
  final String time;
  @HiveField(1)
  @override
  final double temperature;
  @HiveField(2)
  @override
  final int precipitationProbability;
  @HiveField(3)
  @override
  final int weatherCode;
  @HiveField(4)
  @override
  final double windSpeed;

  const HourlyForecastModel({
    required this.time,
    required this.temperature,
    required this.precipitationProbability,
    required this.weatherCode,
    required this.windSpeed,
  }) : super(
         time: time,
         temperature: temperature,
         precipitationProbability: precipitationProbability,
         weatherCode: weatherCode,
         windSpeed: windSpeed,
       );
}

@HiveType(typeId: 2)
class DailyForecastModel extends DailyForecast {
  @HiveField(0)
  @override
  final String date;
  @HiveField(1)
  @override
  final double maxTemp;
  @HiveField(2)
  @override
  final double minTemp;
  @HiveField(3)
  @override
  final int weatherCode;
  @HiveField(4)
  @override
  final double uvMax;

  const DailyForecastModel({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
    required this.uvMax,
  }) : super(
         date: date,
         maxTemp: maxTemp,
         minTemp: minTemp,
         weatherCode: weatherCode,
         uvMax: uvMax,
       );
}
