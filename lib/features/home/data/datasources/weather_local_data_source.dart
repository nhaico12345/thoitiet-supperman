// Cache dữ liệu thời tiết vào Hive để hiển thị khi offline.

import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/weather_model.dart';

abstract class WeatherLocalDataSource {
  Future<WeatherModel?> getLastWeather();
  Future<void> cacheWeather(WeatherModel weather);
}

class WeatherLocalDataSourceImpl implements WeatherLocalDataSource {
  final Box box;

  WeatherLocalDataSourceImpl(this.box);

  @override
  Future<WeatherModel?> getLastWeather() async {
    return box.get('cached_weather');
  }

  @override
  Future<void> cacheWeather(WeatherModel weather) async {
    await box.put('cached_weather', weather);
  }
}
