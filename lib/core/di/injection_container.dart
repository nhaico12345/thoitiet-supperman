// Cấu hình Dependency Injection sử dụng GetIt.
//Đăng ký tất cả Services, DataSources, Repositories, UseCases và Blocs.

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_info.dart';
import '../../core/services/ai_service.dart';
import '../../core/services/background_service.dart';
import '../../core/services/calendar_service.dart';
import '../../core/services/cloudinary_service.dart';
import '../../core/services/device_service.dart';
import '../../core/services/home_widget_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/outfit_recommendation_service.dart';
import '../../features/chat/domain/usecases/send_chat.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../features/home/data/datasources/gemini_remote_data_source.dart';
import '../../features/home/data/datasources/weather_local_data_source.dart';
import '../../features/home/data/datasources/weather_remote_data_source.dart';
import '../../features/home/data/repositories/gemini_repository_impl.dart';
import '../../features/home/data/repositories/weather_repository_impl.dart';
import '../../features/home/domain/repositories/gemini_repository.dart';
import '../../features/home/domain/repositories/weather_repository.dart';
import '../../features/home/domain/usecases/get_ai_recommendations.dart';
import '../../features/home/domain/usecases/get_ootd.dart';
import '../../features/home/domain/usecases/get_weather.dart';
import '../../features/home/domain/usecases/get_weather_summary.dart';
import '../../features/home/presentation/bloc/weather_bloc.dart';
import '../../features/locations/data/datasources/location_local_data_source.dart';
import '../../features/locations/data/datasources/location_remote_data_source.dart';
import '../../features/locations/data/repositories/location_repository_impl.dart';
import '../../features/locations/domain/repositories/location_repository.dart';
import '../../features/locations/presentation/bloc/location_bloc.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/wardrobe/data/datasources/wardrobe_remote_data_source.dart';
import '../../features/wardrobe/data/repositories/wardrobe_repository_impl.dart';
import '../../features/wardrobe/domain/repositories/wardrobe_repository.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // Thư viện bên ngoài
  getIt.registerLazySingleton<DioClient>(() => DioClient());
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());

  // Đọc API key từ biến môi trường
  final groqApiKey = dotenv.env['GROQ_API_KEY'] ?? '';
  getIt.registerLazySingleton<GeminiService>(
    () => GeminiService(apiKey: groqApiKey),
  );
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  getIt.registerLazySingleton<BackgroundService>(() => BackgroundService());
  getIt.registerLazySingleton<HomeWidgetService>(() => HomeWidgetService());
  getIt.registerLazySingleton<CalendarService>(() => CalendarService());
  getIt.registerLazySingleton<DeviceService>(() => DeviceService());

  // Cloudinary Service (Wardrobe Feature)
  getIt.registerLazySingleton<CloudinaryService>(() => CloudinaryService());

  // Outfit Recommendation Service
  getIt.registerLazySingleton<OutfitRecommendationService>(
    () => OutfitRecommendationService(),
  );

  // Hộp dữ liệu Hive
  final weatherBox = await Hive.openBox('weather_box');
  getIt.registerLazySingleton<Box>(() => weatherBox);

  // Lõi ứng dụng
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()));

  // Nguồn dữ liệu - AI
  getIt.registerLazySingleton<GeminiRemoteDataSource>(
    () => GeminiRemoteDataSourceImpl(getIt()),
  );

  // Nguồn dữ liệu - Thời tiết
  getIt.registerLazySingleton<WeatherRemoteDataSource>(
    () => WeatherRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<WeatherLocalDataSource>(
    () => WeatherLocalDataSourceImpl(getIt()),
  );

  // Nguồn dữ liệu - Vị trí
  getIt.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<LocationLocalDataSource>(
    () => LocationLocalDataSourceImpl(getIt()),
  );

  // Kho dữ liệu - AI
  getIt.registerLazySingleton<GeminiRepository>(
    () => GeminiRepositoryImpl(getIt()),
  );

  // Kho dữ liệu - Thời tiết
  getIt.registerLazySingleton<WeatherRepository>(
    () => WeatherRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Kho dữ liệu - Vị trí
  getIt.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );

  // Kho dữ liệu - Cài đặt
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(getIt()),
  );

  // === WARDROBE FEATURE ===
  // Nguồn dữ liệu - Tủ đồ
  getIt.registerLazySingleton<WardrobeRemoteDataSource>(
    () => WardrobeRemoteDataSourceImpl(FirebaseFirestore.instance),
  );

  // Kho dữ liệu - Tủ đồ
  getIt.registerLazySingleton<WardrobeRepository>(
    () => WardrobeRepositoryImpl(
      getIt<WardrobeRemoteDataSource>(),
      getIt<CloudinaryService>(),
    ),
  );

  // Các UseCase
  getIt.registerLazySingleton<GetWeatherUseCase>(
    () => GetWeatherUseCase(getIt(), getIt()),
  );
  getIt.registerLazySingleton<GetAIRecommendationsUseCase>(
    () => GetAIRecommendationsUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetWeatherSummaryUseCase>(
    () => GetWeatherSummaryUseCase(getIt()),
  );
  getIt.registerLazySingleton<GetOOTDUseCase>(() => GetOOTDUseCase(getIt()));
  getIt.registerLazySingleton<SendChatUseCase>(() => SendChatUseCase(getIt()));

  // Các Bloc

  getIt.registerFactory<SettingsBloc>(() => SettingsBloc(getIt(), getIt()));
  getIt.registerFactory<LocationBloc>(() => LocationBloc(getIt()));
  // Đổi WeatherBloc sang LazySingleton để chia sẻ state giữa các màn hình
  getIt.registerLazySingleton<WeatherBloc>(
    () => WeatherBloc(
      getIt(),
      getIt(),
      getIt(),
      getOOTDUseCase: getIt<GetOOTDUseCase>(),
      homeWidgetService: getIt<HomeWidgetService>(),
      calendarService: getIt<CalendarService>(),
      locationRepository: getIt<LocationRepository>(),
      localDataSource: getIt<WeatherLocalDataSource>(),
    ),
  );
  getIt.registerFactory<ChatBloc>(
    () => ChatBloc(getIt(), weatherBloc: getIt<WeatherBloc>()),
  );
}
