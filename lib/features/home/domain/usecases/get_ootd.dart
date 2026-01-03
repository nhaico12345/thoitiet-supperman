// UseCase lấy gợi ý trang phục (OOTD - Outfit of the Day) từ AI.
// Gợi ý set đồ phù hợp với thời tiết hiện tại.

import '../../../../core/resources/data_state.dart';
import '../entities/weather.dart';
import '../repositories/gemini_repository.dart';

class GetOOTDUseCase {
  final GeminiRepository _geminiRepository;

  GetOOTDUseCase(this._geminiRepository);

  Future<DataState<String>> call(WeatherEntity weather) async {
    final weatherData =
        '''
      Temperature: ${weather.temperature}°C
      Condition Code: ${weather.weatherCode}
      Wind Speed: ${weather.windSpeed} km/h
      UV Index: ${weather.uvIndex}
      Humidity: ${weather.humidity}%
      AQI: ${weather.aqi}
    ''';

    return await _geminiRepository.getOOTD(weatherData);
  }
}
