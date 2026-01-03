// Entity cảnh báo thời tiết nguy hiểm (mưa, UV, gió, AQI).

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'weather_alert.g.dart';

@HiveType(typeId: 11)
enum AlertType {
  @HiveField(0)
  rain,
  @HiveField(1)
  storm,
  @HiveField(2)
  uv,
  @HiveField(3)
  aqi,
  @HiveField(4)
  wind,
}

@HiveType(typeId: 12)
enum AlertSeverity {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}

@HiveType(typeId: 10)
class WeatherAlertEntity extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final AlertType type;

  @HiveField(2)
  final AlertSeverity severity;

  @HiveField(3)
  final String message;

  @HiveField(4)
  final String title;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime expiresAt;

  @HiveField(7)
  final bool isRead;

  @HiveField(8)
  final String? locationName;

  const WeatherAlertEntity({
    required this.id,
    required this.type,
    required this.severity,
    required this.message,
    required this.title,
    required this.createdAt,
    required this.expiresAt,
    this.isRead = false,
    this.locationName,
  });

  String get icon {
    switch (type) {
      case AlertType.rain:
        return '🌧️';
      case AlertType.storm:
        return '⛈️';
      case AlertType.uv:
        return '☀️';
      case AlertType.aqi:
        return '💨';
      case AlertType.wind:
        return '🌬️';
    }
  }

  bool get isActive => DateTime.now().isBefore(expiresAt);

  WeatherAlertEntity copyWith({
    String? id,
    AlertType? type,
    AlertSeverity? severity,
    String? message,
    String? title,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isRead,
    String? locationName,
  }) {
    return WeatherAlertEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      message: message ?? this.message,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isRead: isRead ?? this.isRead,
      locationName: locationName ?? this.locationName,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    severity,
    message,
    title,
    createdAt,
    expiresAt,
    isRead,
    locationName,
  ];
}
