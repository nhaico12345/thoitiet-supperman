// Cập nhật widget thời tiết trên màn hình chính (Android/iOS).
// Hỗ trợ 3 kích thước widget: nhỏ, vừa, lớn với dữ liệu dự báo khác nhau.

import 'package:home_widget/home_widget.dart';
import 'package:flutter/foundation.dart';
import '../router/app_router.dart';

// Các loại widget cho màn hình chính
enum WidgetType { small, medium, large }

class HomeWidgetService {
  static const String appGroupId = 'group.com.example.sieuthoitiet';
  static const String smallWidgetName = 'WeatherWidgetSmallProvider';
  static const String mediumWidgetName = 'WeatherWidgetMediumProvider';
  static const String largeWidgetName = 'WeatherWidgetLargeProvider';
  static const String androidWidgetName = 'WeatherWidgetProvider';

  Future<void> initialize() async {
    HomeWidget.widgetClicked.listen((Uri? uri) {
      _handleWidgetClick(uri);
    });
  }

  void _handleWidgetClick(Uri? uri) {
    if (uri == null) return;

    if (kDebugMode) {
      print("Widget clicked with URI: $uri");
    }
    try {
      appRouter.go('/');
    } catch (e) {
      if (kDebugMode) print("Navigation error: $e");
    }
  }

  /// Cập nhật tất cả các loại widget với dữ liệu chia sẻ
  Future<void> updateAllWidgets({
    required String temp,
    required String location,
    required String description,
    required String iconPath,
    required double windSpeed,
    String? highTemp,
    String? lowTemp,
    List<HourlyForecastData>? hourlyForecast,
    List<DailyForecastData>? dailyForecast,
  }) async {
    try {
      // Lưu dữ liệu chia sẻ được sử dụng bởi tất cả widget
      await HomeWidget.saveWidgetData<String>('temp', temp);
      await HomeWidget.saveWidgetData<String>('location', location);
      await HomeWidget.saveWidgetData<String>('description', description);
      await HomeWidget.saveWidgetData<String>(
        'wind_speed',
        "${windSpeed.toStringAsFixed(0)} km/h",
      );
      await HomeWidget.saveWidgetData<String>('icon_name', iconPath);
      await HomeWidget.saveWidgetData<String>(
        'updated',
        "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
      );

      // Nhiệt độ Cao/Thấp cho widget vừa và lớn
      if (highTemp != null && lowTemp != null) {
        await HomeWidget.saveWidgetData<String>(
          'high_low',
          "H:$highTemp L:$lowTemp",
        );
        await HomeWidget.saveWidgetData<String>('high_temp', highTemp);
        await HomeWidget.saveWidgetData<String>('low_temp', lowTemp);
      }

      // Dự báo 3 giờ cho widget vừa
      if (hourlyForecast != null && hourlyForecast.isNotEmpty) {
        for (int i = 0; i < 3 && i < hourlyForecast.length; i++) {
          final hour = hourlyForecast[i];
          await HomeWidget.saveWidgetData<String>(
            'hour${i + 1}_time',
            hour.time,
          );
          await HomeWidget.saveWidgetData<String>(
            'hour${i + 1}_temp',
            '${hour.temp}°',
          );
        }
      }

      // Dự báo 5 ngày cho widget lớn
      if (dailyForecast != null && dailyForecast.isNotEmpty) {
        final dayNames = [
          'Hôm nay',
          'Ngày mai',
          'T3',
          'T4',
          'T5',
          'T6',
          'T7',
          'CN',
        ];
        for (int i = 0; i < 5 && i < dailyForecast.length; i++) {
          final day = dailyForecast[i];
          final dayName = i < 2 ? dayNames[i] : _getDayName(day.date);
          await HomeWidget.saveWidgetData<String>('day${i + 1}_name', dayName);
          await HomeWidget.saveWidgetData<String>(
            'day${i + 1}_desc',
            getWeatherDescription(day.weatherCode),
          );
          await HomeWidget.saveWidgetData<String>(
            'day${i + 1}_temp',
            '${day.maxTemp}°/${day.minTemp}°',
          );
        }
      }

      // Cập nhật tất cả loại widget
      await _updateWidget(androidWidgetName, 'WeatherWidget'); // Cũ
      await _updateWidget(smallWidgetName, 'WeatherWidgetSmall');
      await _updateWidget(mediumWidgetName, 'WeatherWidgetMedium');
      await _updateWidget(largeWidgetName, 'WeatherWidgetLarge');

      if (kDebugMode) {
        print("All widgets updated: $temp, $location");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error updating widgets: $e");
      }
    }
  }

  /// Phương thức cũ để tương thích ngược
  Future<void> updateWidget({
    required String temp,
    required String location,
    required String description,
    required String iconPath,
    required double windSpeed,
  }) async {
    await updateAllWidgets(
      temp: temp,
      location: location,
      description: description,
      iconPath: iconPath,
      windSpeed: windSpeed,
    );
  }

  Future<void> _updateWidget(String androidName, String iOSName) async {
    try {
      await HomeWidget.updateWidget(
        name: androidName,
        iOSName: iOSName,
        qualifiedAndroidName: 'com.example.sieuthoitiet.$androidName',
      );
    } catch (e) {
      // Widget có thể không ở màn hình chính, bỏ qua
      if (kDebugMode) {
        print("Widget $androidName not found or failed to update: $e");
      }
    }
  }

  String _getDayName(DateTime date) {
    final weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return weekdays[date.weekday % 7];
  }

  static String getWeatherDescription(int code) {
    if (code == 0) return "Trời quang";
    if (code == 1 || code == 2 || code == 3) return "Có mây";
    if (code >= 45 && code <= 48) return "Sương mù";
    if (code >= 51 && code <= 67) return "Mưa phùn";
    if (code >= 80 && code <= 82) return "Mưa rào";
    if (code >= 95) return "Giông bão";
    return "Không xác định";
  }

  static String getWeatherIconName(int code) {
    if (code == 0) return "ic_sunny";
    if (code == 1 || code == 2 || code == 3) return "ic_cloudy";
    if (code >= 51) return "ic_rainy";
    return "ic_cloudy";
  }
}

// Dữ liệu dự báo theo giờ cho widget
class HourlyForecastData {
  final String time;
  final int temp;

  HourlyForecastData({required this.time, required this.temp});
}

// Dữ liệu dự báo theo ngày cho widget
class DailyForecastData {
  final DateTime date;
  final int maxTemp;
  final int minTemp;
  final int weatherCode;

  DailyForecastData({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
  });
}
