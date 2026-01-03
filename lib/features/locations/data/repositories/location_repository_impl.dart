// Tích hợp Geolocator để lấy vị trí GPS và Geocoding để lấy tên địa điểm.

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/resources/data_state.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/location_repository.dart';
import '../../data/models/location_model.dart';
import '../datasources/location_local_data_source.dart';
import '../datasources/location_remote_data_source.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;
  final LocationLocalDataSource localDataSource;

  LocationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<DataState<List<LocationEntity>>> searchLocation(String query) async {
    try {
      final result = await remoteDataSource.searchLocation(query);
      return DataSuccess(result);
    } catch (e) {
      return DataFailed(Exception(e.toString()));
    }
  }

  @override
  List<LocationEntity> getSavedLocations() {
    return localDataSource.getSavedLocations();
  }

  @override
  Future<void> saveLocation(LocationEntity location) async {
    await localDataSource.saveLocation(LocationModel.fromEntity(location));
  }

  @override
  Future<void> removeLocation(LocationEntity location) async {
    await localDataSource.removeLocation(LocationModel.fromEntity(location));
  }

  @override
  LocationEntity? getSelectedLocation() {
    return localDataSource.getSelectedLocation();
  }

  @override
  Future<void> selectLocation(LocationEntity location) async {
    await localDataSource.saveSelectedLocation(
      LocationModel.fromEntity(location),
    );
  }

  @override
  Future<DataState<LocationEntity>> getCurrentLocation() async {
    try {
      // Get Permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return DataFailed(Exception("Location permission denied"));
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return DataFailed(Exception("Location permission denied forever"));
      }

      Position? position = await Geolocator.getLastKnownPosition();

      position ??= await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );

      String locationName = "Vị trí hiện tại";
      String country = "";

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          locationName = place.locality?.isNotEmpty == true
              ? place.locality!
              : (place.subAdministrativeArea?.isNotEmpty == true
                    ? place.subAdministrativeArea!
                    : (place.administrativeArea ?? "Vị trí hiện tại"));

          country = place.country ?? "";
        }
      } catch (e) {}

      return DataSuccess(
        LocationEntity(
          name: locationName,
          country: country,
          latitude: position.latitude,
          longitude: position.longitude,
          isCurrentLocation: true,
        ),
      );
    } catch (e) {
      return DataFailed(Exception(e.toString()));
    }
  }
}
