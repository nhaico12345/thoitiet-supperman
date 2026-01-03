// Gọi API Open-Meteo để lấy dữ liệu thời tiết và chất lượng không khí.
// Trả về dự báo hiện tại, theo giờ và theo ngày (10 ngày).

import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/models/weather_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getCurrentWeather(double lat, double long);
  Future<int?> getAirQuality(double lat, double long);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final DioClient dioClient;

  WeatherRemoteDataSourceImpl(this.dioClient);

  @override
  Future<WeatherModel> getCurrentWeather(double lat, double long) async {
    final response = await dioClient.dio.get(
      '/forecast',
      queryParameters: {
        'latitude': lat,
        'longitude': long,
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,rain,showers,snowfall,weathercode,cloud_cover,pressure_msl,surface_pressure,wind_speed_10m,wind_direction_10m,wind_gusts_10m',
        'hourly':
            'temperature_2m,relative_humidity_2m,precipitation_probability,weathercode,wind_speed_10m',
        'daily':
            'weathercode,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max',
        'timezone': 'auto',
        'forecast_days': 10,
      },
    );

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(response.data);
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }

  @override
  Future<int?> getAirQuality(double lat, double long) async {
    try {
      final response = await dioClient.dio.get(
        'https://air-quality-api.open-meteo.com/v1/air-quality',
        queryParameters: {
          'latitude': lat,
          'longitude': long,
          'current': 'us_aqi',
        },
      );

      if (response.statusCode == 200) {
        final current = response.data['current'];
        return current['us_aqi'] as int?;
      }
    } catch (e) {}
    return null;
  }
}
