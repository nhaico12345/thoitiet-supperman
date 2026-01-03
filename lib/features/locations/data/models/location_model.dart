// Model Hive lưu trữ vị trí địa lý.
// Parse JSON từ API Geocoding và serialize để lưu vào Hive.

import 'package:hive/hive.dart';
import '../../domain/entities/location.dart';

part 'location_model.g.dart';

@HiveType(typeId: 3)
class LocationModel extends LocationEntity {
  @HiveField(0)
  @override
  final String name;
  @HiveField(1)
  @override
  final double latitude;
  @HiveField(2)
  @override
  final double longitude;
  @HiveField(3)
  @override
  final String? country;
  @HiveField(4)
  @override
  final bool isCurrentLocation;

  const LocationModel({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.isCurrentLocation = false,
  }) : super(
         name: name,
         latitude: latitude,
         longitude: longitude,
         country: country,
         isCurrentLocation: isCurrentLocation,
       );

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'],
      isCurrentLocation: false,
    );
  }

  factory LocationModel.fromEntity(LocationEntity entity) {
    return LocationModel(
      name: entity.name,
      latitude: entity.latitude,
      longitude: entity.longitude,
      country: entity.country,
      isCurrentLocation: entity.isCurrentLocation,
    );
  }
}
