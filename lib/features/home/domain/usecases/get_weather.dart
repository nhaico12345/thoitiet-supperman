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

    // Thử lấy vị trí hiện tại, fallback về vị trí mặc định nếu thất bại
    try {
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
    } catch (e) {
      // khi quyền vị trí bị từ chối hoặc GPS không khả dụng
    }

    // Fallback về vị trí mặc định khi không lấy được vị trí hiện tại
    return _weatherRepository.getWeather(
      21.0285,
      105.8542,
      locationName: "Cẩm Xuyên (mặc định)",
    );
  }
}
