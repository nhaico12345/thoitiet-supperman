// Model Hive lưu trữ cài đặt người dùng.
// Chuyển đổi enum thành index để serialize với Hive.

import 'package:hive/hive.dart';
import '../../domain/entities/settings.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 4)
class SettingsModel extends SettingsEntity {
  @HiveField(0)
  final int themeModeIndex;
  @HiveField(1)
  final int tempUnitIndex;
  @HiveField(2)
  final int speedUnitIndex;
  @HiveField(3)
  final int pressureUnitIndex;
  @override
  @HiveField(4, defaultValue: true)
  final bool enableNotifications;
  @override
  @HiveField(5, defaultValue: true)
  final bool enableMorningBrief;
  @override
  @HiveField(6, defaultValue: true)
  final bool enableEveningForecast;
  @override
  @HiveField(7, defaultValue: true)
  final bool enableAlerts;
  @override
  @HiveField(8, defaultValue: "07:00")
  final String morningTime;
  @override
  @HiveField(9, defaultValue: "21:00")
  final String eveningTime;

  SettingsModel({
    required this.themeModeIndex,
    required this.tempUnitIndex,
    required this.speedUnitIndex,
    required this.pressureUnitIndex,
    required this.enableNotifications,
    required this.enableMorningBrief,
    required this.enableEveningForecast,
    required this.enableAlerts,
    required this.morningTime,
    required this.eveningTime,
  }) : super(
         themeMode: AppThemeMode.values[themeModeIndex],
         tempUnit: TempUnit.values[tempUnitIndex],
         speedUnit: SpeedUnit.values[speedUnitIndex],
         pressureUnit: PressureUnit.values[pressureUnitIndex],
         enableNotifications: enableNotifications,
         enableMorningBrief: enableMorningBrief,
         enableEveningForecast: enableEveningForecast,
         enableAlerts: enableAlerts,
         morningTime: morningTime,
         eveningTime: eveningTime,
       );

  factory SettingsModel.fromEntity(SettingsEntity entity) {
    return SettingsModel(
      themeModeIndex: entity.themeMode.index,
      tempUnitIndex: entity.tempUnit.index,
      speedUnitIndex: entity.speedUnit.index,
      pressureUnitIndex: entity.pressureUnit.index,
      enableNotifications: entity.enableNotifications,
      enableMorningBrief: entity.enableMorningBrief,
      enableEveningForecast: entity.enableEveningForecast,
      enableAlerts: entity.enableAlerts,
      morningTime: entity.morningTime,
      eveningTime: entity.eveningTime,
    );
  }
}
