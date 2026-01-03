// File chứa các hằng số thời tiết được sử dụng trong toàn bộ ứng dụng.
// Tập trung các magic numbers để dễ bảo trì và thay đổi.

// Ngưỡng cảnh báo thời tiết
class WeatherThresholds {
  WeatherThresholds._();

  // === UV Index ===
  /// UV cao (cần cảnh báo)
  static const double uvHigh = 7.0;

  /// UV rất cao (nguy hiểm)
  static const double uvVeryHigh = 10.0;

  // === Wind Speed (km/h) ===
  /// Gió lớn (cần cảnh báo)
  static const double windHigh = 30.0;

  /// Gió rất lớn (nguy hiểm)
  static const double windVeryHigh = 50.0;

  // === Air Quality Index ===
  /// AQI không tốt cho nhóm nhạy cảm
  static const int aqiModerate = 100;

  /// AQI không tốt cho mọi người
  static const int aqiUnhealthy = 150;

  /// AQI rất không tốt
  static const int aqiVeryUnhealthy = 200;

  // === Temperature (°C) ===
  /// Nhiệt độ lạnh
  static const double tempCold = 10.0;

  /// Nhiệt độ mát
  static const double tempCool = 20.0;

  /// Nhiệt độ ấm
  static const double tempWarm = 30.0;

  /// Nhiệt độ nóng
  static const double tempHot = 35.0;

  // === Weather Codes ===
  /// Mã thời tiết mưa (bắt đầu từ)
  static const int rainCodeStart = 61;

  /// Mã thời tiết mưa (kết thúc tại)
  static const int rainCodeEnd = 99;

  /// Mã thời tiết giông bão (bắt đầu từ)
  static const int stormCodeStart = 95;
}

// Thời gian cache và refresh
class CacheSettings {
  CacheSettings._();

  /// Thời gian tối thiểu giữa các lần refresh (giây)
  static const int minRefreshIntervalSeconds = 10;

  /// Thời gian cache AI hợp lệ (phút)
  static const int aiCacheMinutes = 30;

  /// Thời gian hiển thị dữ liệu cũ (phút)
  static const int staleDateMinutes = 30;

  /// Thời gian không lặp lại cảnh báo (giờ)
  static const int alertCooldownHours = 4;
}

class BeaufortScale {
  BeaufortScale._();

  /// Lấy cấp độ gió từ tốc độ (km/h)
  static int getLevel(double speedKmh) {
    if (speedKmh < 1) return 0; // Lặng gió
    if (speedKmh < 6) return 1; // Gió nhẹ
    if (speedKmh < 12) return 2; // Gió nhẹ
    if (speedKmh < 20) return 3; // Gió vừa
    if (speedKmh < 29) return 4; // Gió mạnh vừa
    if (speedKmh < 39) return 5; // Gió khá mạnh
    if (speedKmh < 50) return 6; // Gió mạnh
    if (speedKmh < 62) return 7; // Gió rất mạnh
    if (speedKmh < 75) return 8; // Bão
    if (speedKmh < 89) return 9; // Bão mạnh
    if (speedKmh < 103) return 10; // Bão rất mạnh
    if (speedKmh < 118) return 11; // Bão dữ dội
    return 12; // Siêu bão
  }

  static String getDescription(int level) {
    switch (level) {
      case 0:
        return 'Lặng gió';
      case 1:
        return 'Gió nhẹ';
      case 2:
        return 'Gió nhẹ';
      case 3:
        return 'Gió vừa';
      case 4:
        return 'Gió mạnh vừa';
      case 5:
        return 'Gió khá mạnh';
      case 6:
        return 'Gió mạnh';
      case 7:
        return 'Gió rất mạnh';
      case 8:
        return 'Bão';
      case 9:
        return 'Bão mạnh';
      case 10:
        return 'Bão rất mạnh';
      case 11:
        return 'Bão dữ dội';
      case 12:
        return 'Siêu bão';
      default:
        return 'Không xác định';
    }
  }
}
