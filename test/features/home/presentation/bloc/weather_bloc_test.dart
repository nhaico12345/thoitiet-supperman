import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sieuthoitiet/core/resources/data_state.dart';
import 'package:sieuthoitiet/features/home/domain/entities/weather.dart';
import 'package:sieuthoitiet/features/home/domain/usecases/get_ai_recommendations.dart';
import 'package:sieuthoitiet/features/home/domain/usecases/get_weather.dart';
import 'package:sieuthoitiet/features/home/domain/usecases/get_weather_summary.dart';
import 'package:sieuthoitiet/features/home/presentation/bloc/weather_bloc.dart';

class MockGetWeatherUseCase extends Mock implements GetWeatherUseCase {}
class MockGetAIRecommendationsUseCase extends Mock implements GetAIRecommendationsUseCase {}
class MockGetWeatherSummaryUseCase extends Mock implements GetWeatherSummaryUseCase {}
class FakeWeatherEntity extends Fake implements WeatherEntity {}

void main() {
  late WeatherBloc weatherBloc;
  late MockGetWeatherUseCase mockGetWeatherUseCase;
  late MockGetAIRecommendationsUseCase mockGetAIRecommendationsUseCase;
  late MockGetWeatherSummaryUseCase mockGetWeatherSummaryUseCase;

  setUpAll(() {
    registerFallbackValue(FakeWeatherEntity());
  });

  setUp(() {
    mockGetWeatherUseCase = MockGetWeatherUseCase();
    mockGetAIRecommendationsUseCase = MockGetAIRecommendationsUseCase();
    mockGetWeatherSummaryUseCase = MockGetWeatherSummaryUseCase();
    weatherBloc = WeatherBloc(
      mockGetWeatherUseCase,
      mockGetAIRecommendationsUseCase,
      mockGetWeatherSummaryUseCase,
    );
  });

  const testWeather = WeatherEntity(
    temperature: 25,
    weatherCode: 0,
    windSpeed: 10,
  );

  group('WeatherBloc Tests', () {
    test('Initial state should be WeatherLoading', () {
      expect(weatherBloc.state, const WeatherLoading());
    });

    blocTest<WeatherBloc, WeatherState>(
      'emits [WeatherLoading, WeatherLoaded] when GetWeather is successful',
      build: () {
        when(() => mockGetWeatherUseCase()).thenAnswer(
          (_) async => const DataSuccess(testWeather),
        );
        // Stub AI calls to avoid errors during side-effects
        when(() => mockGetAIRecommendationsUseCase(any())).thenAnswer(
          (_) async => const DataSuccess([]),
        );
        when(() => mockGetWeatherSummaryUseCase(any())).thenAnswer(
          (_) async => const DataSuccess("Summary"),
        );
        return weatherBloc;
      },
      act: (bloc) => bloc.add(const GetWeather()),
      expect: () => [
        const WeatherLoading(),
        const WeatherLoaded(testWeather),
        isA<WeatherLoaded>(), // Loading AI
        isA<WeatherLoaded>(), // AI Done
      ],
    );

    blocTest<WeatherBloc, WeatherState>(
      'emits [WeatherLoading, WeatherError] when GetWeather fails',
      build: () {
        when(() => mockGetWeatherUseCase()).thenAnswer(
          (_) async => DataFailed(Exception('Server Error')),
        );
        return weatherBloc;
      },
      act: (bloc) => bloc.add(const GetWeather()),
      expect: () => [
        const WeatherLoading(),
        isA<WeatherError>(),
      ],
    );
  });
}
