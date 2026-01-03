// Helper class để lấy icon/emoji thời tiết từ weather code.
// Tập trung logic emoji để tránh duplicate code.

class WeatherIconHelper {
  WeatherIconHelper._();

  /// Lấy emoji thời tiết dựa trên weather code và thời gian
  static String getEmoji(int code, {bool? isNight}) {
    isNight ??= _isNightTime();
    if (code == 0) {
      return isNight ? '🌙' : '☀️';
    }
    if (code == 1 || code == 2) {
      return isNight ? '🌙' : '🌤️';
    }
    if (code == 3) return '☁️';
    if (code >= 45 && code <= 48) return '🌫️';
    if (code >= 51 && code <= 55) return '🌧️';
    if (code >= 56 && code <= 57) return '🌨️';
    if (code >= 61 && code <= 65) return '🌧️';
    if (code >= 66 && code <= 67) return '🌨️';
    if (code >= 71 && code <= 77) return '❄️';
    if (code >= 80 && code <= 82) return '🌦️';
    if (code >= 85 && code <= 86) return '🌨️';
    if (code >= 95) return '⛈️';
    return '❓';
  }

  /// Lấy tên icon (cho asset hoặc API)
  static String getIconName(int code, {bool? isNight}) {
    isNight ??= _isNightTime();

    if (code == 0) return isNight ? 'clear_night' : 'clear_day';
    if (code == 1 || code == 2) {
      return isNight ? 'partly_cloudy_night' : 'partly_cloudy_day';
    }
    if (code == 3) return 'cloudy';
    if (code >= 45 && code <= 48) return 'fog';
    if (code >= 51 && code <= 67) return 'rain';
    if (code >= 71 && code <= 77) return 'snow';
    if (code >= 80 && code <= 86) return 'showers';
    if (code >= 95) return 'thunderstorm';
    return 'unknown';
  }

  /// Lấy mô tả thời tiết bằng tiếng Việt
  static String getDescription(int code) {
    if (code == 0) return 'Trời quang';
    if (code == 1) return 'Ít mây';
    if (code == 2) return 'Mây rải rác';
    if (code == 3) return 'Nhiều mây';
    if (code >= 45 && code <= 48) return 'Sương mù';
    if (code >= 51 && code <= 55) return 'Mưa phùn';
    if (code >= 56 && code <= 57) return 'Mưa phùn đóng băng';
    if (code >= 61 && code <= 63) return 'Mưa nhẹ';
    if (code >= 64 && code <= 65) return 'Mưa vừa đến mưa to';
    if (code >= 66 && code <= 67) return 'Mưa đóng băng';
    if (code >= 71 && code <= 75) return 'Tuyết rơi';
    if (code >= 76 && code <= 77) return 'Mưa đá';
    if (code >= 80 && code <= 82) return 'Mưa rào';
    if (code >= 85 && code <= 86) return 'Tuyết rào';
    if (code >= 95 && code <= 96) return 'Giông bão';
    if (code >= 97) return 'Giông bão kèm mưa đá';
    return 'Không xác định';
  }

  /// Kiểm tra mã thời tiết có phải là mưa không
  static bool isRainy(int code) {
    return (code >= 51 && code <= 67) || (code >= 80 && code <= 82);
  }

  /// Kiểm tra mã thời tiết có phải là bão không
  static bool isStormy(int code) {
    return code >= 95;
  }

  /// Kiểm tra có phải ban đêm không (dựa trên giờ hiện tại)
  static bool _isNightTime() {
    final hour = DateTime.now().hour;
    return hour < 6 || hour >= 18;
  }
}
