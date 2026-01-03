// Bao gồm: tên, tọa độ (lat/long), quốc gia và cờ vị trí hiện tại.

import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final bool isCurrentLocation;

  const LocationEntity({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.isCurrentLocation = false,
  });

  @override
  List<Object?> get props => [
    name,
    latitude,
    longitude,
    country,
    isCurrentLocation,
  ];
}
