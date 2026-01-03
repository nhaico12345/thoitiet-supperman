// Tích hợp lịch thiết bị để phát hiện sự kiện ngoài trời.
// Cảnh báo khi sự kiện ngoài trời có thể bị ảnh hưởng bởi thời tiết xấu.

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

// Từ khóa chỉ hoạt động ngoài trời
const List<String> outdoorKeywords = [
  'picnic',
  'đi chơi',
  'ngoài trời',
  'outdoor',
  'camping',
  'cắm trại',
  'du lịch',
  'travel',
  'hiking',
  'leo núi',
  'biển',
  'beach',
  'công viên',
  'park',
  'bbq',
  'tiệc ngoài trời',
  'chạy bộ',
  'running',
  'đạp xe',
  'cycling',
  'thể thao',
  'sport',
  'golf',
  'tennis',
  'bóng đá',
  'football',
];

// Entity cho sự kiện lịch với ngữ cảnh thời tiết
class CalendarEventInfo {
  final String id;
  final String title;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isOutdoor;

  CalendarEventInfo({
    required this.id,
    required this.title,
    required this.startTime,
    this.endTime,
    required this.isOutdoor,
  });

  /// Kiểm tra sự kiện có trong vòng N giờ tới không
  bool isWithinHours(int hours) {
    final now = DateTime.now();
    final deadline = now.add(Duration(hours: hours));
    return startTime.isAfter(now) && startTime.isBefore(deadline);
  }
}

class CalendarService {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  Future<List<Event>> getEventsForNext24Hours() async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
          return [];
        }
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      if (!calendarsResult.isSuccess || calendarsResult.data == null) {
        return [];
      }

      final now = DateTime.now();
      final tomorrow = now.add(const Duration(hours: 24));
      List<Event> allEvents = [];

      for (var calendar in calendarsResult.data!) {
        if (calendar.isReadOnly == false || true) {
          // Lấy từ tất cả các lịch
          final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
            calendar.id,
            RetrieveEventsParams(startDate: now, endDate: tomorrow),
          );

          if (eventsResult.isSuccess && eventsResult.data != null) {
            allEvents.addAll(eventsResult.data!);
          }
        }
      }

      return allEvents;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching calendar events: $e');
      }
      return [];
    }
  }

  /// Lấy các sự kiện với thông tin phát hiện ngoài trời
  Future<List<CalendarEventInfo>> getEventsWithOutdoorInfo() async {
    final events = await getEventsForNext24Hours();
    return events.map((event) {
      final title = event.title?.toLowerCase() ?? '';
      final description = event.description?.toLowerCase() ?? '';
      final location = event.location?.toLowerCase() ?? '';

      final combinedText = '$title $description $location';
      final isOutdoor = outdoorKeywords.any(
        (keyword) => combinedText.contains(keyword.toLowerCase()),
      );

      return CalendarEventInfo(
        id: event.eventId ?? '',
        title: event.title ?? 'Sự kiện không tên',
        startTime: event.start?.toLocal() ?? DateTime.now(),
        endTime: event.end?.toLocal(),
        isOutdoor: isOutdoor,
      );
    }).toList();
  }

  /// Chỉ lấy các sự kiện ngoài trời
  Future<List<CalendarEventInfo>> getOutdoorEvents() async {
    final allEvents = await getEventsWithOutdoorInfo();
    return allEvents.where((e) => e.isOutdoor).toList();
  }

  /// Kiểm tra có sự kiện ngoài trời nào có thể bị ảnh hưởng bởi thời tiết xấu không
  Future<List<String>> checkOutdoorEventsWithBadWeather({
    required int weatherCode,
    required double uvIndex,
    required double windSpeed,
  }) async {
    final outdoorEvents = await getOutdoorEvents();
    if (outdoorEvents.isEmpty) return [];

    final warnings = <String>[];

    // Kiểm tra điều kiện thời tiết xấu
    bool isRaining = weatherCode >= 51 && weatherCode <= 99;
    bool isHighUV = uvIndex > 7;
    bool isHighWind = windSpeed > 30;

    for (final event in outdoorEvents) {
      if (!event.isWithinHours(24)) continue;

      String? warning;
      if (isRaining) {
        warning =
            '🌧️ Sự kiện "${event.title}" lúc ${_formatTime(event.startTime)} có thể bị ảnh hưởng bởi mưa. Hãy chuẩn bị ô/áo mưa!';
      } else if (isHighUV) {
        warning =
            '☀️ UV cao! Nhớ bôi kem chống nắng cho "${event.title}" lúc ${_formatTime(event.startTime)}.';
      } else if (isHighWind) {
        warning =
            '🌬️ Gió lớn có thể ảnh hưởng đến "${event.title}" lúc ${_formatTime(event.startTime)}.';
      }

      if (warning != null) {
        warnings.add(warning);
      }
    }

    return warnings;
  }

  /// Lên lịch thông báo cho các sự kiện ngoài trời gặp thời tiết xấu
  Future<void> scheduleEventWeatherNotifications({
    required NotificationService notificationService,
    required int weatherCode,
    required double uvIndex,
    required double windSpeed,
  }) async {
    final outdoorEvents = await getOutdoorEvents();

    bool isBadWeather =
        (weatherCode >= 51 && weatherCode <= 99) ||
        uvIndex > 7 ||
        windSpeed > 30;

    if (!isBadWeather) return;

    for (final event in outdoorEvents) {
      // Chỉ lên lịch cho các sự kiện bắt đầu trong 2-4 giờ
      final hoursUntilEvent = event.startTime
          .difference(DateTime.now())
          .inHours;
      if (hoursUntilEvent < 2 || hoursUntilEvent > 4) continue;

      String weatherWarning = '';
      if (weatherCode >= 51 && weatherCode <= 99) {
        weatherWarning = 'có thể bị ảnh hưởng bởi mưa. Hãy chuẩn bị ô/áo mưa!';
      } else if (uvIndex > 7) {
        weatherWarning = 'cần bôi kem chống nắng do UV cao!';
      } else if (windSpeed > 30) {
        weatherWarning = 'có thể bị ảnh hưởng do gió lớn.';
      }

      await notificationService.showRichNotification(
        title: '📅 Cảnh báo sự kiện',
        body:
            'Sự kiện "${event.title}" lúc ${_formatTime(event.startTime)} $weatherWarning',
        payload: event.id,
      );
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
