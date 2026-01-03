//Điểm khởi đầu của ứng dụng thời tiết.
//Khởi tạo Hive (lưu trữ local), Dependency Injection, các services
//(thông báo, nền, widget, cảnh báo) và chạy ứng dụng.
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'core/di/injection_container.dart';
import 'core/services/notification_service.dart';
import 'core/services/background_service.dart';
import 'core/services/home_widget_service.dart';
import 'core/services/alert_service.dart';
import 'features/home/domain/entities/weather_alert.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/home/data/models/weather_model.dart';
import 'features/locations/data/models/location_model.dart';
import 'features/settings/data/models/settings_model.dart';
import 'features/settings/domain/entities/settings.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';

void main() async {
  // Bắt tất cả lỗi không xử lý
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Future.wait([
        dotenv.load(fileName: ".env"),
        Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      ]);

      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        if (kDebugMode) {
          print('FlutterError: ${details.exception}');
          print('Stack trace: ${details.stack}');
        }
      };

      await Hive.initFlutter();

      Hive.registerAdapter(WeatherModelAdapter());
      Hive.registerAdapter(HourlyForecastModelAdapter());
      Hive.registerAdapter(DailyForecastModelAdapter());
      Hive.registerAdapter(LocationModelAdapter());
      Hive.registerAdapter(SettingsModelAdapter());
      Hive.registerAdapter(WeatherAlertEntityAdapter());
      Hive.registerAdapter(AlertTypeAdapter());
      Hive.registerAdapter(AlertSeverityAdapter());

      final boxes = await Future.wait([
        Hive.openBox('settings'),
        Hive.openBox('saved_locations'),
        Hive.openBox('weather_alerts'),
      ]);
      final alertBox = boxes[2];

      await initializeDependencies();

      AlertService().initialize(alertBox, getIt<NotificationService>());

      runApp(const MyApp());

      _initServicesInBackground();
    },
    (error, stack) {
      if (kDebugMode) {
        print('Uncaught error: $error');
        print('Stack trace: $stack');
      }
    },
  );
}

void _initServicesInBackground() {
  Future.microtask(() async {
    try {
      await getIt<NotificationService>().initialize();
      await getIt<BackgroundService>().initialize();
      await getIt<HomeWidgetService>().initialize();
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi khởi tạo dịch vụ nền: $e');
      }
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsBloc>(
      create: (context) => getIt<SettingsBloc>(),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: 'THỜI TIẾT PROMAX',
            theme: AppTheme.lightTheme,
            darkTheme: ThemeData.dark(useMaterial3: true),
            themeMode: _getThemeMode(state.settings.themeMode),
            routerConfig: appRouter,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  ThemeMode _getThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}
