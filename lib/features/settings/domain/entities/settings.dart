// Bao gồm: theme, đơn vị đo, thông báo sáng/tối, cảnh báo nguy hiểm.

import 'package:equatable/equatable.dart';

enum AppThemeMode { light, dark, system }

enum TempUnit { celsius, fahrenheit }

enum SpeedUnit { kmh, mph }

enum PressureUnit { hpa, inhg }

class SettingsEntity extends Equatable {
  final AppThemeMode themeMode;
  final TempUnit tempUnit;
  final SpeedUnit speedUnit;
  final PressureUnit pressureUnit;
  final bool enableNotifications;
  final bool enableMorningBrief;
  final bool enableEveningForecast;
  final bool enableAlerts;
  final String morningTime;
  final String eveningTime;

  const SettingsEntity({
    this.themeMode = AppThemeMode.system,
    this.tempUnit = TempUnit.celsius,
    this.speedUnit = SpeedUnit.kmh,
    this.pressureUnit = PressureUnit.hpa,
    this.enableNotifications = true,
    this.enableMorningBrief = true,
    this.enableEveningForecast = true,
    this.enableAlerts = true,
    this.morningTime = "07:00",
    this.eveningTime = "21:00",
  });

  SettingsEntity copyWith({
    AppThemeMode? themeMode,
    TempUnit? tempUnit,
    SpeedUnit? speedUnit,
    PressureUnit? pressureUnit,
    bool? enableNotifications,
    bool? enableMorningBrief,
    bool? enableEveningForecast,
    bool? enableAlerts,
    String? morningTime,
    String? eveningTime,
  }) {
    return SettingsEntity(
      themeMode: themeMode ?? this.themeMode,
      tempUnit: tempUnit ?? this.tempUnit,
      speedUnit: speedUnit ?? this.speedUnit,
      pressureUnit: pressureUnit ?? this.pressureUnit,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableMorningBrief: enableMorningBrief ?? this.enableMorningBrief,
      enableEveningForecast:
          enableEveningForecast ?? this.enableEveningForecast,
      enableAlerts: enableAlerts ?? this.enableAlerts,
      morningTime: morningTime ?? this.morningTime,
      eveningTime: eveningTime ?? this.eveningTime,
    );
  }

  @override
  List<Object?> get props => [
    themeMode,
    tempUnit,
    speedUnit,
    pressureUnit,
    enableNotifications,
    enableMorningBrief,
    enableEveningForecast,
    enableAlerts,
    morningTime,
    eveningTime,
  ];
}
