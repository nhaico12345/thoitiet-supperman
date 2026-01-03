// UseCase lấy tóm tắt thời tiết ngắn gọn từ AI.
// AI đóng vai biên tập viên thời tiết, viết tóm tắt dưới 50 từ.

import '../../../../core/resources/data_state.dart';
import '../entities/weather.dart';
import '../repositories/gemini_repository.dart';

class GetWeatherSummaryUseCase {
  final GeminiRepository _geminiRepository;

  GetWeatherSummaryUseCase(this._geminiRepository);

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

    return await _geminiRepository.getWeatherSummary(weatherData);
  }
}
