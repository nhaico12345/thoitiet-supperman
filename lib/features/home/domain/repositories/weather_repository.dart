// Interface repository để lấy dữ liệu thời tiết.
// Định nghĩa phương thức getWeather với tọa độ và tên vị trí.

import '../../../../core/resources/data_state.dart';
import '../../domain/entities/weather.dart';

abstract class WeatherRepository {
  Future<DataState<WeatherEntity>> getWeather(
    double lat,
    double long, {
    String? locationName,
  });
}
