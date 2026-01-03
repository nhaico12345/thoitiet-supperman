// UseCase gửi tin nhắn đến AI với ngữ cảnh thời tiết hiện tại.
// AI sẽ trả lời dựa trên dữ liệu thời tiết thực tế của người dùng.

import '../../../../core/resources/data_state.dart';
import '../../../../features/home/domain/entities/weather.dart';
import '../../../../features/home/domain/repositories/gemini_repository.dart';

class SendChatUseCase {
  final GeminiRepository _geminiRepository;

  SendChatUseCase(this._geminiRepository);

  Future<DataState<String>> call(String message, WeatherEntity? weather) async {
    String weatherContext = "Dữ liệu thời tiết không có sẵn.";
    if (weather != null) {
      weatherContext =
          '''
Temp: ${weather.temperature}°C, 
Condition Code: ${weather.weatherCode}, 
Wind: ${weather.windSpeed} km/h, 
UV: ${weather.uvIndex}, 
Humidity: ${weather.humidity}%, 
AQI: ${weather.aqi}.
User đang ở ${weather.locationName ?? 'Vị trí không xác định'}.
''';
    }

    return await _geminiRepository.chatWithWeatherContext(
      message,
      weatherContext,
    );
  }
}
