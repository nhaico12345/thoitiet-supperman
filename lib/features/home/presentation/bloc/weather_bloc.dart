// Mô tả: BLoC quản lý state màn hình chính thời tiết.
//Xử lý tải thời tiết, gợi ý AI, cập nhật widget và cảnh báo.
//OPTIMIZED: Cache-First strategy - hiển thị cache ngay, fetch mới sau.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/weather.dart';
import '../../domain/usecases/get_weather.dart';
import '../../../../core/resources/data_state.dart';
import '../../../locations/domain/repositories/location_repository.dart';
import '../../domain/usecases/get_ai_recommendations.dart';
import '../../domain/usecases/get_weather_summary.dart';
import '../../domain/services/recommendation_service.dart';
import '../../domain/usecases/get_ootd.dart';
import '../../../../core/services/home_widget_service.dart';
import '../../../../core/services/calendar_service.dart';
import '../../../../core/services/alert_service.dart';
import '../../data/datasources/weather_local_data_source.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final GetWeatherUseCase _getWeatherUseCase;
  final GetAIRecommendationsUseCase _getAIRecommendationsUseCase;
  final GetWeatherSummaryUseCase _getWeatherSummaryUseCase;
  final GetOOTDUseCase? _getOOTDUseCase;
  final HomeWidgetService? _homeWidgetService;
  final CalendarService? _calendarService;
  // ignore: unused_field
  final LocationRepository? _locationRepository;
  final WeatherLocalDataSource? _localDataSource; // OPTIMIZED: Cache-First

  // Debounce: Thời gian fetch cuối cùng
  DateTime? _lastWeatherFetchTime;
  static const Duration _minRefreshInterval = Duration(seconds: 10);

  WeatherBloc(
    this._getWeatherUseCase,
    this._getAIRecommendationsUseCase,
    this._getWeatherSummaryUseCase, {
    GetOOTDUseCase? getOOTDUseCase,
    HomeWidgetService? homeWidgetService,
    CalendarService? calendarService,
    LocationRepository? locationRepository,
    WeatherLocalDataSource? localDataSource,
  }) : _getOOTDUseCase = getOOTDUseCase,
       _homeWidgetService = homeWidgetService,
       _calendarService = calendarService,
       _locationRepository = locationRepository,
       _localDataSource = localDataSource,
       super(const WeatherLoading()) {
    on<GetWeather>(_onGetWeather);
    on<GetAIAdvice>(_onGetAIAdvice);
  }

  Future<void> _onGetWeather(
    GetWeather event,
    Emitter<WeatherState> emit,
  ) async {
    // Debounce: Ngăn refresh quá nhanh (tối thiểu 10 giây)
    // Bỏ qua debounce nếu forceRefresh=true hoặc đang ở trạng thái error
    if (!event.forceRefresh &&
        state is! WeatherError &&
        _lastWeatherFetchTime != null &&
        state.weather != null) {
      final timeSinceLastFetch = DateTime.now().difference(
        _lastWeatherFetchTime!,
      );
      if (timeSinceLastFetch < _minRefreshInterval) {
        // Bỏ qua refresh nếu quá nhanh
        return;
      }
    }

    // OPTIMIZED: Cache-First - Hiển thị cache ngay lập tức
    if (state.weather == null && _localDataSource != null) {
      try {
        final cachedWeather = await _localDataSource.getLastWeather();
        if (cachedWeather != null) {
          emit(WeatherLoaded(cachedWeather, status: WeatherStatus.cached));
          // Gọi AI ngay với cache data (user thấy UI nhanh)
          add(const GetAIAdvice());
        } else {
          emit(const WeatherLoading());
        }
      } catch (e) {
        emit(const WeatherLoading());
      }
    } else if (state.weather != null) {
      // Đang có data, hiển thị refreshing
      if (state is WeatherLoaded) {
        emit(
          (state as WeatherLoaded).copyWith(status: WeatherStatus.refreshing),
        );
      }
    } else {
      emit(const WeatherLoading());
    }

    // Fetch data mới từ API
    final result = await _getWeatherUseCase();
    _lastWeatherFetchTime = DateTime.now();

    if (result is DataSuccess && result.data != null) {
      emit(WeatherLoaded(result.data!, status: WeatherStatus.success));
      // Gọi AI với data mới (có 30-min cache logic trong _onGetAIAdvice)
      add(const GetAIAdvice());

      // Cập nhật Widget màn hình chính
      if (_homeWidgetService != null) {
        final weatherCode = result.data!.weatherCode ?? 0;
        _homeWidgetService.updateWidget(
          temp: result.data!.temperature?.toString() ?? "--",
          location: result.data!.locationName ?? "Vị trí hiện tại",
          description: HomeWidgetService.getWeatherDescription(weatherCode),
          iconPath: HomeWidgetService.getWeatherIconName(weatherCode),
          windSpeed: result.data!.windSpeed ?? 0.0,
        );
      }

      // Kiểm tra cảnh báo thời tiết
      final alertService = AlertService();
      if (alertService.isInitialized) {
        // Lấy mã thời tiết sắp tới từ dự báo theo giờ (2 giờ tới)
        List<int>? upcomingCodes;
        if (result.data!.hourlyForecasts != null &&
            result.data!.hourlyForecasts!.length >= 2) {
          upcomingCodes = result.data!.hourlyForecasts!
              .take(2)
              .map((h) => h.weatherCode)
              .toList();
        }

        await alertService.analyzeAndAlert(
          weatherCode: result.data!.weatherCode ?? 0,
          windSpeed: result.data!.windSpeed ?? 0,
          uvIndex: result.data!.uvIndex ?? 0,
          aqi: result.data!.aqi,
          locationName: result.data!.locationName,
          upcomingWeatherCodes: upcomingCodes,
        );
      }
    } else if (result is DataFailed) {
      emit(WeatherError(result.error!));
    }
  }

  Future<void> _onGetAIAdvice(
    GetAIAdvice event,
    Emitter<WeatherState> emit,
  ) async {
    if (state is! WeatherLoaded) return;

    final currentState = state as WeatherLoaded;

    // Logic Cache: Kiểm tra nếu ta lấy dữ liệu AI gần đây (< 30 phút)
    if (currentState.lastAIFetchTime != null) {
      final difference = DateTime.now().difference(
        currentState.lastAIFetchTime!,
      );
      if (difference.inMinutes < 30) {
        // Dữ liệu đủ mới, không gọi API
        return;
      }
    }

    // Đặt trạng thái AI Loading
    emit(
      currentState.copyWith(
        isAILoading: true,
        aiErrorMessage: null, // Xóa lỗi trước đó
      ),
    );

    // Gọi tất cả dịch vụ AI song song (Gợi ý, Tóm tắt, OOTD)
    final results = await Future.wait([
      _getAIRecommendationsUseCase(currentState.weather!),
      _getWeatherSummaryUseCase(currentState.weather!),
      if (_getOOTDUseCase != null)
        _getOOTDUseCase(currentState.weather!)
      else
        Future.value(DataFailed<String>(Exception("No OOTD Service"))),
    ]);

    final recommendationsResult = results[0] as DataState<List<Recommendation>>;
    final summaryResult = results[1] as DataState<String>;
    final ootdResult = results[2] as DataState<String>;

    List<Recommendation> finalRecommendations = [];
    String? finalSummary;
    String? finalOotd;
    List<String> smartWarnings = [];
    bool hasAIError = false;

    // Xử lý Gợi ý
    if (recommendationsResult is DataSuccess &&
        recommendationsResult.data != null &&
        recommendationsResult.data!.isNotEmpty) {
      finalRecommendations = recommendationsResult.data!;
    } else {
      // Dự phòng bằng logic cục bộ
      hasAIError = true;
      finalRecommendations = RecommendationService.getRecommendations(
        temp: currentState.weather!.temperature,
        weatherCode: currentState.weather!.weatherCode,
        aqi: currentState.weather!.aqi,
        uvIndex: currentState.weather!.uvIndex,
        windSpeed: currentState.weather!.windSpeed,
      );
    }

    // Xử lý Tóm tắt
    if (summaryResult is DataSuccess && summaryResult.data != null) {
      finalSummary = summaryResult.data;
    } else if (summaryResult is DataFailed) {
      hasAIError = true;
    }

    // Xử lý OOTD
    if (ootdResult is DataSuccess && ootdResult.data != null) {
      finalOotd = ootdResult.data;
    }

    // Xử lý Cảnh báo thông minh (Lịch) - Nâng cao với phát hiện sự kiện ngoài trời
    if (_calendarService != null) {
      final calendarWarnings = await _calendarService
          .checkOutdoorEventsWithBadWeather(
            weatherCode: currentState.weather!.weatherCode ?? 0,
            uvIndex: currentState.weather!.uvIndex ?? 0,
            windSpeed: currentState.weather!.windSpeed ?? 0,
          );
      smartWarnings.addAll(calendarWarnings);
    }

    emit(
      currentState.copyWith(
        recommendations: finalRecommendations,
        weatherSummary: finalSummary,
        ootdAdvice: finalOotd,
        smartWarnings: smartWarnings,
        isAILoading: false,
        lastAIFetchTime: DateTime.now(),
        aiErrorMessage: hasAIError
            ? "Đang sử dụng gợi ý thông minh cục bộ"
            : null,
      ),
    );
  }
}
