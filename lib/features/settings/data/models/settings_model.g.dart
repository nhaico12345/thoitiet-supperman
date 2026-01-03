// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsModelAdapter extends TypeAdapter<SettingsModel> {
  @override
  final int typeId = 4;

  @override
  SettingsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsModel(
      themeModeIndex: fields[0] as int,
      tempUnitIndex: fields[1] as int,
      speedUnitIndex: fields[2] as int,
      pressureUnitIndex: fields[3] as int,
      enableNotifications: fields[4] == null ? true : fields[4] as bool,
      enableMorningBrief: fields[5] == null ? true : fields[5] as bool,
      enableEveningForecast: fields[6] == null ? true : fields[6] as bool,
      enableAlerts: fields[7] == null ? true : fields[7] as bool,
      morningTime: fields[8] == null ? '07:00' : fields[8] as String,
      eveningTime: fields[9] == null ? '21:00' : fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.themeModeIndex)
      ..writeByte(1)
      ..write(obj.tempUnitIndex)
      ..writeByte(2)
      ..write(obj.speedUnitIndex)
      ..writeByte(3)
      ..write(obj.pressureUnitIndex)
      ..writeByte(4)
      ..write(obj.enableNotifications)
      ..writeByte(5)
      ..write(obj.enableMorningBrief)
      ..writeByte(6)
      ..write(obj.enableEveningForecast)
      ..writeByte(7)
      ..write(obj.enableAlerts)
      ..writeByte(8)
      ..write(obj.morningTime)
      ..writeByte(9)
      ..write(obj.eveningTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
