// Implementation của GeminiRepository cho các tính năng AI.
// Gọi remote data source và wrap kết quả thành DataState.

import '../../../../core/resources/data_state.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/gemini_repository.dart';
import '../datasources/gemini_remote_data_source.dart';

class GeminiRepositoryImpl implements GeminiRepository {
  final GeminiRemoteDataSource _remoteDataSource;

  GeminiRepositoryImpl(this._remoteDataSource);

  @override
  Future<DataState<String>> getRecommendations(String weatherData) async {
    try {
      final result = await _remoteDataSource.getRecommendations(weatherData);
      if (result == null) {
        return const DataFailed(ServerFailure("AI returned null response"));
      }
      return DataSuccess(result);
    } catch (e) {
      return DataFailed(ServerFailure(e.toString()));
    }
  }

  @override
  Future<DataState<String>> getWeatherSummary(String weatherData) async {
    try {
      final result = await _remoteDataSource.getWeatherSummary(weatherData);
      if (result == null) {
        return const DataFailed(ServerFailure("AI returned null response"));
      }
      return DataSuccess(result);
    } catch (e) {
      return DataFailed(ServerFailure(e.toString()));
    }
  }

  @override
  Future<DataState<String>> chatWithWeatherContext(
    String message,
    String weatherContext,
  ) async {
    try {
      final result = await _remoteDataSource.chatWithWeatherContext(
        message,
        weatherContext,
      );
      if (result == null) {
        return const DataFailed(ServerFailure("AI returned null response"));
      }
      return DataSuccess(result);
    } catch (e) {
      return DataFailed(ServerFailure(e.toString()));
    }
  }

  @override
  Future<DataState<String>> getOOTD(String weatherData) async {
    try {
      final result = await _remoteDataSource.getOOTDAdvice(weatherData);
      if (result == null) {
        return const DataFailed(ServerFailure("AI returned null response"));
      }
      return DataSuccess(result);
    } catch (e) {
      return DataFailed(ServerFailure(e.toString()));
    }
  }
}
