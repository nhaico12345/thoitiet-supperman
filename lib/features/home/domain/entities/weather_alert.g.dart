// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_alert.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeatherAlertEntityAdapter extends TypeAdapter<WeatherAlertEntity> {
  @override
  final int typeId = 10;

  @override
  WeatherAlertEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeatherAlertEntity(
      id: fields[0] as String,
      type: fields[1] as AlertType,
      severity: fields[2] as AlertSeverity,
      message: fields[3] as String,
      title: fields[4] as String,
      createdAt: fields[5] as DateTime,
      expiresAt: fields[6] as DateTime,
      isRead: fields[7] as bool,
      locationName: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WeatherAlertEntity obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.severity)
      ..writeByte(3)
      ..write(obj.message)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.expiresAt)
      ..writeByte(7)
      ..write(obj.isRead)
      ..writeByte(8)
      ..write(obj.locationName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherAlertEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AlertTypeAdapter extends TypeAdapter<AlertType> {
  @override
  final int typeId = 11;

  @override
  AlertType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AlertType.rain;
      case 1:
        return AlertType.storm;
      case 2:
        return AlertType.uv;
      case 3:
        return AlertType.aqi;
      case 4:
        return AlertType.wind;
      default:
        return AlertType.rain;
    }
  }

  @override
  void write(BinaryWriter writer, AlertType obj) {
    switch (obj) {
      case AlertType.rain:
        writer.writeByte(0);
        break;
      case AlertType.storm:
        writer.writeByte(1);
        break;
      case AlertType.uv:
        writer.writeByte(2);
        break;
      case AlertType.aqi:
        writer.writeByte(3);
        break;
      case AlertType.wind:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AlertSeverityAdapter extends TypeAdapter<AlertSeverity> {
  @override
  final int typeId = 12;

  @override
  AlertSeverity read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AlertSeverity.low;
      case 1:
        return AlertSeverity.medium;
      case 2:
        return AlertSeverity.high;
      default:
        return AlertSeverity.low;
    }
  }

  @override
  void write(BinaryWriter writer, AlertSeverity obj) {
    switch (obj) {
      case AlertSeverity.low:
        writer.writeByte(0);
        break;
      case AlertSeverity.medium:
        writer.writeByte(1);
        break;
      case AlertSeverity.high:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AlertSeverityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
