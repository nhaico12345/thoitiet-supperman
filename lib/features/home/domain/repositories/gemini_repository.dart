// Interface repository cho các tính năng AI.
// Định nghĩa phương thức: getRecommendations, getWeatherSummary, chat, OOTD.

import '../../../../core/resources/data_state.dart';

abstract class GeminiRepository {
  Future<DataState<String>> getRecommendations(String weatherData);
  Future<DataState<String>> getWeatherSummary(String weatherData);
  Future<DataState<String>> chatWithWeatherContext(
    String message,
    String weatherContext,
  );
  Future<DataState<String>> getOOTD(String weatherData);
}
