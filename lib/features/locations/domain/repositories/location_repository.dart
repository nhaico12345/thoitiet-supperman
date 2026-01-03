//Tìm kiếm, lưu, xóa, chọn vị trí và lấy vị trí GPS.

import '../../../../core/resources/data_state.dart';
import '../entities/location.dart';

abstract class LocationRepository {
  Future<DataState<List<LocationEntity>>> searchLocation(String query);
  List<LocationEntity> getSavedLocations();
  Future<void> saveLocation(LocationEntity location);
  Future<void> removeLocation(LocationEntity location);
  LocationEntity? getSelectedLocation();
  Future<void> selectLocation(LocationEntity location);
  Future<DataState<LocationEntity>> getCurrentLocation();
}
