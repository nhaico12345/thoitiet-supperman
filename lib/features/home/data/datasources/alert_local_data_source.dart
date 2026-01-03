// Quản lý lịch sử cảnh báo thời tiết trong Hive.
// Lưu, đọc, đánh dấu đã đọc, xóa cảnh báo và tránh gửi trùng lặp.
import 'package:hive/hive.dart';
import '../../../home/domain/entities/weather_alert.dart';

abstract class AlertLocalDataSource {
  List<WeatherAlertEntity> getAllAlerts();
  List<WeatherAlertEntity> getActiveAlerts();
  int getUnreadCount();
  Future<void> saveAlert(WeatherAlertEntity alert);
  Future<void> markAsRead(String alertId);
  Future<void> markAllAsRead();
  Future<void> deleteAlert(String alertId);
  Future<void> clearAllAlerts();
  bool hasRecentAlertOfType(AlertType type, Duration within);
}

class AlertLocalDataSourceImpl implements AlertLocalDataSource {
  final Box _alertBox;

  AlertLocalDataSourceImpl(this._alertBox);

  @override
  List<WeatherAlertEntity> getAllAlerts() {
    final alerts = _alertBox.values.cast<WeatherAlertEntity>().toList();
    alerts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return alerts;
  }

  @override
  List<WeatherAlertEntity> getActiveAlerts() {
    final now = DateTime.now();
    return getAllAlerts()
        .where((alert) => alert.expiresAt.isAfter(now))
        .toList();
  }

  @override
  int getUnreadCount() {
    return _alertBox.values
        .cast<WeatherAlertEntity>()
        .where((alert) => !alert.isRead)
        .length;
  }

  @override
  Future<void> saveAlert(WeatherAlertEntity alert) async {
    await _alertBox.put(alert.id, alert);
  }

  @override
  Future<void> markAsRead(String alertId) async {
    final alert = _alertBox.get(alertId) as WeatherAlertEntity?;
    if (alert != null) {
      await _alertBox.put(alertId, alert.copyWith(isRead: true));
    }
  }

  @override
  Future<void> markAllAsRead() async {
    final alerts = getAllAlerts();
    for (final alert in alerts) {
      if (!alert.isRead) {
        await _alertBox.put(alert.id, alert.copyWith(isRead: true));
      }
    }
  }

  @override
  Future<void> deleteAlert(String alertId) async {
    await _alertBox.delete(alertId);
  }

  @override
  Future<void> clearAllAlerts() async {
    await _alertBox.clear();
  }

  @override
  bool hasRecentAlertOfType(AlertType type, Duration within) {
    final now = DateTime.now();
    final alerts = _alertBox.values.cast<WeatherAlertEntity>();

    return alerts.any(
      (alert) => alert.type == type && now.difference(alert.createdAt) < within,
    );
  }
}
