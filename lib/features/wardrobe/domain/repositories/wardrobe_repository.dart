// Interface cho Wardrobe Repository.
// Định nghĩa các phương thức để lấy và thêm món đồ vào tủ.

import 'dart:io';
import '../../../../core/resources/data_state.dart';
import '../entities/clothing_item.dart';

abstract class WardrobeRepository {
  /// Lấy danh sách đồ từ tủ chung
  /// [category] - Lọc theo loại (optional)
  Future<DataState<List<ClothingItem>>> getWardrobeItems({String? category});

  /// Thêm món đồ mới vào tủ chung
  /// [item] - Thông tin món đồ
  /// [imageFile] - File ảnh (nếu có, sẽ upload lên Cloudinary)
  Future<DataState<ClothingItem>> addClothingItem(
    ClothingItem item,
    File? imageFile,
  );

  /// Lấy danh sách favorites của user
  Future<DataState<List<String>>> getUserFavorites(String userId);

  /// Toggle yêu thích một món đồ
  Future<DataState<void>> toggleFavorite(String userId, String itemId);
}
