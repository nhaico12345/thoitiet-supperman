// Implementation của WeatherRepository theo Clean Architecture.
// Kết hợp remote (API) + local (cache) + AQI, fallback cache khi offline.

import 'package:dio/dio.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/resources/data_state.dart';
import '../../../../core/error/failures.dart';
import '../datasources/weather_local_data_source.dart';
import '../datasources/weather_remote_data_source.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../data/models/weather_model.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;
  final WeatherLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  WeatherRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<DataState<WeatherEntity>> getWeather(
    double lat,
    double long, {
    String? locationName,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final results = await Future.wait([
          remoteDataSource.getCurrentWeather(lat, long),
          remoteDataSource.getAirQuality(lat, long),
        ]);

        final weatherModel = results[0] as WeatherModel;
        final aqi = results[1] as int?;

        final fullWeatherModel = WeatherModel(
          temperature: weatherModel.temperature,
          windSpeed: weatherModel.windSpeed,
          weatherCode: weatherModel.weatherCode,
          lastUpdated: DateTime.now().toIso8601String(),
          uvIndex: weatherModel.uvIndex,
          humidity: weatherModel.humidity,
          feelsLike: weatherModel.feelsLike,
          pressure: weatherModel.pressure,
          sunrise: weatherModel.sunrise,
          sunset: weatherModel.sunset,
          aqi: aqi,
          locationName: locationName,
          hourlyForecasts: weatherModel.hourlyForecasts,
          dailyForecasts: weatherModel.dailyForecasts,
        );

        await localDataSource.cacheWeather(fullWeatherModel);
        return DataSuccess(fullWeatherModel);
      } on DioException catch (e) {
        return await _checkCacheOrError(
          ServerFailure(e.message ?? "Server Error"),
        );
      } catch (e) {
        return await _checkCacheOrError(ServerFailure(e.toString()));
      }
    } else {
      return await _checkCacheOrError(
        const NetworkFailure("No Internet Connection"),
      );
    }
  }

  Future<DataState<WeatherEntity>> _checkCacheOrError(
    Failure originalError,
  ) async {
    try {
      final cachedWeather = await localDataSource.getLastWeather();
      if (cachedWeather != null) {
        return DataSuccess(cachedWeather);
      }
    } catch (e) {
      return DataFailed(CacheFailure(e.toString()));
    }
    return DataFailed(originalError);
  }
}
