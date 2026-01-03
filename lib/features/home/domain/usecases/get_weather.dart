// UseCase lấy dữ liệu thời tiết theo tọa độ hoặc vị trí đã chọn.
// Tự động fallback về vị trí mặc định nếu không có vị trí nào khả dụng.

import '../../../../core/resources/data_state.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../../locations/domain/repositories/location_repository.dart';

class GetWeatherUseCase {
  final WeatherRepository _weatherRepository;
  final LocationRepository _locationRepository;

  GetWeatherUseCase(this._weatherRepository, this._locationRepository);

  Future<DataState<WeatherEntity>> call({double? lat, double? long}) async {
    if (lat != null && long != null) {
      return _weatherRepository.getWeather(
        lat,
        long,
        locationName: "Vị trí hiện tại",
      );
    }

    final selectedLocation = _locationRepository.getSelectedLocation();
    if (selectedLocation != null) {
      return _weatherRepository.getWeather(
        selectedLocation.latitude,
        selectedLocation.longitude,
        locationName: selectedLocation.name,
      );
    }

    final currentLocationResult = await _locationRepository
        .getCurrentLocation();
    if (currentLocationResult is DataSuccess &&
        currentLocationResult.data != null) {
      final loc = currentLocationResult.data!;
      return _weatherRepository.getWeather(
        loc.latitude,
        loc.longitude,
        locationName: loc.name,
      );
    }

    return _weatherRepository.getWeather(
      21.0285,
      105.8542,
      locationName: "Cẩm Xuyên",
    );
  }
}
