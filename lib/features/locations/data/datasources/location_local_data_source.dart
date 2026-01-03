// Lưu trữ danh sách vị trí yêu thích và vị trí đã chọn vào Hive.
// Hỗ trợ thêm, xóa, lấy danh sách và lưu vị trí đang xem.

import 'package:hive/hive.dart';
import '../../data/models/location_model.dart';

abstract class LocationLocalDataSource {
  List<LocationModel> getSavedLocations();
  Future<void> saveLocation(LocationModel location);
  Future<void> removeLocation(LocationModel location);

  LocationModel? getSelectedLocation();
  Future<void> saveSelectedLocation(LocationModel location);
}

class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  final Box box;

  LocationLocalDataSourceImpl(this.box);

  @override
  List<LocationModel> getSavedLocations() {
    final saved = box.get('saved_locations', defaultValue: []) as List;
    return saved.cast<LocationModel>();
  }

  @override
  Future<void> saveLocation(LocationModel location) async {
    final saved = getSavedLocations();
    if (!saved.any(
      (l) => l.name == location.name && l.country == location.country,
    )) {
      saved.add(location);
      await box.put('saved_locations', saved);
    }
  }

  @override
  Future<void> removeLocation(LocationModel location) async {
    final saved = getSavedLocations();
    saved.removeWhere(
      (l) => l.name == location.name && l.country == location.country,
    );
    await box.put('saved_locations', saved);
  }

  @override
  LocationModel? getSelectedLocation() {
    return box.get('selected_location');
  }

  @override
  Future<void> saveSelectedLocation(LocationModel location) async {
    await box.put('selected_location', location);
  }
}
