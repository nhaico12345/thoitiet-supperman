// Phát hiện điều kiện thời tiết nguy hiểm và tạo cảnh báo.
// Cảnh báo mưa, UV cao, gió lớn, chất lượng không khí kém.

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../features/home/domain/entities/weather_alert.dart';
import '../../features/home/data/datasources/alert_local_data_source.dart';
import '../utils/weather_constants.dart';
import 'notification_service.dart';

// Dịch vụ phát hiện điều kiện thời tiết và tạo cảnh báo
class AlertService {
  static final AlertService _instance = AlertService._internal();

  factory AlertService() {
    return _instance;
  }

  AlertService._internal();

  AlertLocalDataSource? _dataSource;
  NotificationService? _notificationService;

  /// Khởi tạo với các dependencies
  void initialize(Box alertBox, NotificationService notificationService) {
    _dataSource = AlertLocalDataSourceImpl(alertBox);
    _notificationService = notificationService;
  }

  /// Kiểm tra dịch vụ đã được khởi tạo chưa
  bool get isInitialized => _dataSource != null && _notificationService != null;

  /// Lấy tất cả cảnh báo
  List<WeatherAlertEntity> getAllAlerts() {
    return _dataSource?.getAllAlerts() ?? [];
  }

  /// Lấy các cảnh báo đang hoạt động
  List<WeatherAlertEntity> getActiveAlerts() {
    return _dataSource?.getActiveAlerts() ?? [];
  }

  /// Lấy số lượng chưa đọc
  int getUnreadCount() {
    return _dataSource?.getUnreadCount() ?? 0;
  }

  /// Đánh dấu cảnh báo đã đọc
  Future<void> markAsRead(String alertId) async {
    await _dataSource?.markAsRead(alertId);
  }

  /// Đánh dấu tất cả đã đọc
  Future<void> markAllAsRead() async {
    await _dataSource?.markAllAsRead();
  }

  /// Xóa cảnh báo
  Future<void> deleteAlert(String alertId) async {
    await _dataSource?.deleteAlert(alertId);
  }

  /// Xóa tất cả cảnh báo
  Future<void> clearAllAlerts() async {
    await _dataSource?.clearAllAlerts();
  }

  /// Phân tích dữ liệu thời tiết và tạo cảnh báo nếu cần
  /// Trả về danh sách các cảnh báo mới tạo
  Future<List<WeatherAlertEntity>> analyzeAndAlert({
    required int weatherCode,
    required double windSpeed,
    required double uvIndex,
    int? aqi,
    String? locationName,
    List<int>? upcomingWeatherCodes,
  }) async {
    if (!isInitialized) return [];

    final newAlerts = <WeatherAlertEntity>[];
    final uuid = const Uuid();
    final now = DateTime.now();

    // Kiểm tra cảnh báo mưa (weatherCode >= 61 có nghĩa là mưa)
    // Đồng thời kiểm tra các mã thời tiết sắp tới cho dự báo 2 giờ
    bool willRain = weatherCode >= 61 && weatherCode <= 99;
    if (!willRain && upcomingWeatherCodes != null) {
      willRain = upcomingWeatherCodes.any((code) => code >= 61 && code <= 99);
    }

    if (willRain &&
        !_dataSource!.hasRecentAlertOfType(
          AlertType.rain,
          const Duration(hours: 4),
        )) {
      final isStorm = weatherCode >= 95;
      final alert = WeatherAlertEntity(
        id: uuid.v4(),
        type: isStorm ? AlertType.storm : AlertType.rain,
        severity: isStorm ? AlertSeverity.high : AlertSeverity.medium,
        title: isStorm ? '⛈️ Cảnh báo giông bão' : '🌧️ Cảnh báo mưa',
        message: isStorm
            ? 'Có giông bão trong khu vực của bạn. Hãy tìm nơi trú ẩn an toàn!'
            : 'Trời sắp mưa hoặc đang mưa. Hãy mang theo ô khi ra ngoài!',
        createdAt: now,
        expiresAt: now.add(const Duration(hours: 6)),
        locationName: locationName,
      );
      await _dataSource!.saveAlert(alert);
      newAlerts.add(alert);
    }

    // Kiểm tra cảnh báo UV cao
    if (uvIndex > WeatherThresholds.uvHigh &&
        !_dataSource!.hasRecentAlertOfType(
          AlertType.uv,
          const Duration(hours: 8),
        )) {
      final severity = uvIndex > WeatherThresholds.uvVeryHigh
          ? AlertSeverity.high
          : AlertSeverity.medium;
      final alert = WeatherAlertEntity(
        id: uuid.v4(),
        type: AlertType.uv,
        severity: severity,
        title: '☀️ Cảnh báo UV cao',
        message:
            'Chỉ số UV hôm nay là ${uvIndex.toStringAsFixed(1)}. Hãy bảo vệ da và đeo kính râm!',
        createdAt: now,
        expiresAt: now.add(const Duration(hours: 12)),
        locationName: locationName,
      );
      await _dataSource!.saveAlert(alert);
      newAlerts.add(alert);
    }

    // Kiểm tra chất lượng không khí kém
    if (aqi != null &&
        aqi > WeatherThresholds.aqiModerate &&
        !_dataSource!.hasRecentAlertOfType(
          AlertType.aqi,
          const Duration(hours: 6),
        )) {
      final severity = aqi > WeatherThresholds.aqiUnhealthy
          ? AlertSeverity.high
          : AlertSeverity.medium;
      final alert = WeatherAlertEntity(
        id: uuid.v4(),
        type: AlertType.aqi,
        severity: severity,
        title: '💨 Cảnh báo chất lượng không khí',
        message:
            'Chỉ số AQI là $aqi (${_getAQIDescription(aqi)}). Hạn chế hoạt động ngoài trời!',
        createdAt: now,
        expiresAt: now.add(const Duration(hours: 8)),
        locationName: locationName,
      );
      await _dataSource!.saveAlert(alert);
      newAlerts.add(alert);
    }

    // Kiểm tra gió lớn
    if (windSpeed > WeatherThresholds.windHigh &&
        !_dataSource!.hasRecentAlertOfType(
          AlertType.wind,
          const Duration(hours: 4),
        )) {
      final severity = windSpeed > WeatherThresholds.windVeryHigh
          ? AlertSeverity.high
          : AlertSeverity.medium;
      final alert = WeatherAlertEntity(
        id: uuid.v4(),
        type: AlertType.wind,
        severity: severity,
        title: '🌬️ Cảnh báo gió lớn',
        message:
            'Gió đang thổi mạnh ${windSpeed.toStringAsFixed(0)} km/h. Cẩn thận khi di chuyển!',
        createdAt: now,
        expiresAt: now.add(const Duration(hours: 4)),
        locationName: locationName,
      );
      await _dataSource!.saveAlert(alert);
      newAlerts.add(alert);
    }

    // Gửi thông báo đẩy cho các cảnh báo mới
    for (final alert in newAlerts) {
      await _notificationService?.showRichNotification(
        title: alert.title,
        body: alert.message,
        payload: alert.id,
      );
    }

    return newAlerts;
  }

  String _getAQIDescription(int aqi) {
    if (aqi <= 50) return 'Tốt';
    if (aqi <= 100) return 'Trung bình';
    if (aqi <= 150) return 'Không tốt cho nhóm nhạy cảm';
    if (aqi <= 200) return 'Không tốt';
    if (aqi <= 300) return 'Rất không tốt';
    return 'Nguy hiểm';
  }
}
