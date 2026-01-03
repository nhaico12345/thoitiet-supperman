// Định dạng dữ liệu thời tiết thành văn bản đẹp để chia sẻ.
// Bao gồm nhiệt độ, điều kiện, gió, độ ẩm và gợi ý trang phục OOTD.

import '../../../features/home/domain/entities/weather.dart';

String formatWeatherShareText(WeatherEntity weather) {
  final description = _getWeatherDescription(weather.weatherCode ?? 0);

  return '''
🌤️ Thời tiết tại ${weather.locationName ?? 'Vị trí hiện tại'}
🌡️ ${weather.temperature?.toStringAsFixed(0) ?? '--'}°C - $description
💨 Gió: ${weather.windSpeed?.toStringAsFixed(0) ?? '--'} km/h
💧 Độ ẩm: ${weather.humidity ?? '--'}%
📱 Xem thêm tại WeatherStyle Pro
'''
      .trim();
}

String formatWeatherShareTextWithOOTD(
  WeatherEntity weather,
  String? ootdAdvice,
) {
  final base = formatWeatherShareText(weather);
  if (ootdAdvice != null && ootdAdvice.isNotEmpty) {
    return '$base\n\n👕 Gợi ý: $ootdAdvice';
  }
  return base;
}

String _getWeatherDescription(int code) {
  if (code >= 95) return 'Giông bão';
  if (code >= 80) return 'Mưa rào';
  if (code >= 61) return 'Mưa';
  if (code >= 51) return 'Mưa phùn';
  if (code >= 45) return 'Sương mù';
  if (code >= 3) return 'Nhiều mây';
  if (code >= 1) return 'Có mây';
  return 'Trời quang';
}
