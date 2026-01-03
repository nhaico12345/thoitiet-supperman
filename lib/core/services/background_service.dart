// Gửi thông báo cảnh báo và cập nhật widget khi có thời tiết xấu.

import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'home_widget_service.dart';

const String weatherCheckTask = 'weather_check_task';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == weatherCheckTask) {
      try {
        if (kDebugMode) {
          print("Background task running: $task at ${DateTime.now()}");
        }

        final prefs = await SharedPreferences.getInstance();
        final lastAlertTime = prefs.getInt('last_alert_timestamp') ?? 0;
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        if (currentTime - lastAlertTime < 4 * 60 * 60 * 1000) {
          if (kDebugMode) {
            print("Skipping alert: Cooldown active.");
          }
          return Future.value(true);
        }

        // 2. Lấy Vị trí
        final double? lat = prefs.getDouble('last_known_lat');
        final double? lon = prefs.getDouble('last_known_lon');

        if (lat == null || lon == null) {
          if (kDebugMode) {
            print("No location saved for background check.");
          }
          return Future.value(true);
        }

        // 3. Lấy dữ liệu thời tiết
        final dio = Dio();
        final response = await dio.get(
          'https://api.open-meteo.com/v1/forecast',
          queryParameters: {
            'latitude': lat,
            'longitude': lon,
            'current': 'temperature_2m,weather_code,wind_speed_10m',
            'daily': 'uv_index_max',
            'timezone': 'auto',
          },
        );

        if (response.statusCode == 200) {
          final data = response.data;
          final current = data['current'];
          final daily = data['daily'];

          final double windSpeed = (current['wind_speed_10m'] as num)
              .toDouble();
          final int weatherCode = (current['weather_code'] as num).toInt();
          final double uvMax = (daily['uv_index_max'][0] as num).toDouble();

          // Cập nhật Widget trong nền
          try {
            final homeWidgetService = HomeWidgetService();
            final currentTemp = current['temperature_2m']?.toString() ?? "--";
            final description = HomeWidgetService.getWeatherDescription(
              weatherCode,
            );
            final iconPath = HomeWidgetService.getWeatherIconName(weatherCode);

            await homeWidgetService.updateWidget(
              temp: currentTemp,
              location: "Cập nhật nền", // Có thể lấy từ Prefs nếu đã lưu
              description: description,
              iconPath: iconPath,
              windSpeed: windSpeed,
            );
          } catch (e) {
            if (kDebugMode) print("Widget update failed in background: $e");
          }

          // 4. Kiểm tra điều kiện
          // Mã thời tiết cho Mưa/Bão (WMO): 51-67 (Mưa phùn/Mưa), 80-82 (Mưa rào), 95-99 (Giông bão)
          bool isRaining =
              (weatherCode >= 51 && weatherCode <= 67) ||
              (weatherCode >= 80 && weatherCode <= 82) ||
              (weatherCode >= 95 && weatherCode <= 99);

          bool isHighWind = windSpeed > 30.0;
          bool isHighUV = uvMax > 8.0;

          String? alertTitle;
          String? alertBody;

          if (isRaining) {
            alertTitle = "Cảnh báo mưa";
            alertBody = "Trời đang mưa hoặc sắp có mưa. Hãy mang theo dù!";
          } else if (isHighWind) {
            alertTitle = "Cảnh báo gió lớn";
            alertBody =
                "Gió đang thổi mạnh ($windSpeed km/h). Cẩn thận khi ra ngoài.";
          } else if (isHighUV) {
            alertTitle = "Cảnh báo UV cao";
            alertBody = "Chỉ số UV hôm nay rất cao ($uvMax). Hãy bảo vệ da!";
          }

          // 5. Hiển thị Thông báo & Cập nhật Timestamp
          if (alertTitle != null) {
            final notificationService = NotificationService();
            await notificationService.initialize();

            await notificationService.showInstantNotification(
              title: alertTitle,
              body: alertBody!,
            );

            await prefs.setInt('last_alert_timestamp', currentTime);
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Background task error: $e");
        }
        return Future.value(false);
      }
    }
    return Future.value(true);
  });
}

class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();

  factory BackgroundService() {
    return _instance;
  }

  BackgroundService._internal();

  Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
    if (kDebugMode) {
      print("BackgroundService initialized");
    }
  }

  Future<void> registerPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      "weather_check_periodic",
      weatherCheckTask,
      frequency: const Duration(hours: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
  }

  Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
  }
}
