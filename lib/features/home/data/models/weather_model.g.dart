// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeatherModelAdapter extends TypeAdapter<WeatherModel> {
  @override
  final int typeId = 0;

  @override
  WeatherModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeatherModel(
      temperature: fields[0] as double?,
      windSpeed: fields[1] as double?,
      weatherCode: fields[2] as int?,
      lastUpdated: fields[3] as String?,
      uvIndex: fields[4] as double?,
      humidity: fields[5] as int?,
      feelsLike: fields[6] as double?,
      pressure: fields[7] as double?,
      sunrise: fields[8] as String?,
      sunset: fields[9] as String?,
      aqi: fields[10] as int?,
      locationName: fields[13] as String?,
      hourlyForecasts: (fields[11] as List?)?.cast<HourlyForecastModel>(),
      dailyForecasts: (fields[12] as List?)?.cast<DailyForecastModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, WeatherModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.temperature)
      ..writeByte(1)
      ..write(obj.windSpeed)
      ..writeByte(2)
      ..write(obj.weatherCode)
      ..writeByte(3)
      ..write(obj.lastUpdated)
      ..writeByte(4)
      ..write(obj.uvIndex)
      ..writeByte(5)
      ..write(obj.humidity)
      ..writeByte(6)
      ..write(obj.feelsLike)
      ..writeByte(7)
      ..write(obj.pressure)
      ..writeByte(8)
      ..write(obj.sunrise)
      ..writeByte(9)
      ..write(obj.sunset)
      ..writeByte(10)
      ..write(obj.aqi)
      ..writeByte(13)
      ..write(obj.locationName)
      ..writeByte(11)
      ..write(obj.hourlyForecasts)
      ..writeByte(12)
      ..write(obj.dailyForecasts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HourlyForecastModelAdapter extends TypeAdapter<HourlyForecastModel> {
  @override
  final int typeId = 1;

  @override
  HourlyForecastModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HourlyForecastModel(
      time: fields[0] as String,
      temperature: fields[1] as double,
      precipitationProbability: fields[2] as int,
      weatherCode: fields[3] as int,
      windSpeed: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, HourlyForecastModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.time)
      ..writeByte(1)
      ..write(obj.temperature)
      ..writeByte(2)
      ..write(obj.precipitationProbability)
      ..writeByte(3)
      ..write(obj.weatherCode)
      ..writeByte(4)
      ..write(obj.windSpeed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HourlyForecastModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DailyForecastModelAdapter extends TypeAdapter<DailyForecastModel> {
  @override
  final int typeId = 2;

  @override
  DailyForecastModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyForecastModel(
      date: fields[0] as String,
      maxTemp: fields[1] as double,
      minTemp: fields[2] as double,
      weatherCode: fields[3] as int,
      uvMax: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, DailyForecastModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.maxTemp)
      ..writeByte(2)
      ..write(obj.minTemp)
      ..writeByte(3)
      ..write(obj.weatherCode)
      ..writeByte(4)
      ..write(obj.uvMax);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyForecastModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
