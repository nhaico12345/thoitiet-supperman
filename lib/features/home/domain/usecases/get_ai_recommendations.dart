// UseCase lấy gợi ý hoạt động từ AI dựa trên thời tiết hiện tại.

import 'dart:convert';
import '../../../../core/resources/data_state.dart';
import '../entities/weather.dart';
import '../repositories/gemini_repository.dart';
import '../services/recommendation_service.dart';

class GetAIRecommendationsUseCase {
  final GeminiRepository _geminiRepository;

  GetAIRecommendationsUseCase(this._geminiRepository);

  Future<DataState<List<Recommendation>>> call(WeatherEntity weather) async {
    try {
      final weatherData =
          '''
        Temperature: ${weather.temperature}°C
        Condition Code: ${weather.weatherCode}
        Wind Speed: ${weather.windSpeed} km/h
        UV Index: ${weather.uvIndex}
        Humidity: ${weather.humidity}%
        AQI: ${weather.aqi}
      ''';

      final result = await _geminiRepository.getRecommendations(weatherData);

      if (result is DataFailed) {
        return DataFailed(result.error!);
      }

      final jsonString = result.data;

      if (jsonString == null) {
        return DataFailed(Exception("AI response data is null"));
      }

      String cleanJson = jsonString.trim();
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.replaceAll('```json', '').replaceAll('```', '');
      } else if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson.replaceAll('```', '');
      }
      cleanJson = cleanJson.trim();

      final List<dynamic> jsonList = jsonDecode(cleanJson);

      final recommendations = jsonList
          .map(
            (item) => Recommendation(
              category: item['category'] ?? 'Chung',
              title: item['title'] ?? '',
              icon: item['icon'] ?? '💡',
              description: item['description'] ?? '',
              isAlert: item['isAlert'] ?? false,
            ),
          )
          .toList();

      return DataSuccess(recommendations);
    } catch (e) {
      try {
        final fallbackRecommendations =
            RecommendationService.getRecommendations(
              temp: weather.temperature,
              weatherCode: weather.weatherCode,
              aqi: weather.aqi,
              uvIndex: weather.uvIndex,
              windSpeed: weather.windSpeed,
            );
        return DataSuccess(fallbackRecommendations);
      } catch (fallbackError) {
        return DataFailed(
          Exception("Failed to parse AI response and Fallback failed: $e"),
        );
      }
    }
  }
}
