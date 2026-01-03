// Implementation của WardrobeRepository.
// Kết hợp Cloudinary upload và Firestore để quản lý tủ đồ.

import 'dart:io';
import '../../../../core/resources/data_state.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../domain/entities/clothing_item.dart';
import '../../domain/repositories/wardrobe_repository.dart';
import '../datasources/wardrobe_remote_data_source.dart';
import '../models/clothing_item_model.dart';

class WardrobeRepositoryImpl implements WardrobeRepository {
  final WardrobeRemoteDataSource _dataSource;
  final CloudinaryService _cloudinaryService;

  WardrobeRepositoryImpl(this._dataSource, this._cloudinaryService);

  @override
  Future<DataState<List<ClothingItem>>> getWardrobeItems({
    String? category,
  }) async {
    try {
      final items = await _dataSource.getWardrobeItems(category: category);
      return DataSuccess(items);
    } catch (e) {
      return DataFailed(Exception('Lỗi khi lấy danh sách đồ: $e'));
    }
  }

  @override
  Future<DataState<ClothingItem>> addClothingItem(
    ClothingItem item,
    File? imageFile,
  ) async {
    try {
      String imageUrl = item.imageUrl;

      // Upload ảnh lên Cloudinary nếu có file
      if (imageFile != null) {
        final uploadedUrl = await _cloudinaryService.uploadImage(
          imageFile,
          folder: 'wardrobe/${item.category.toLowerCase()}',
        );
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        } else {
          return DataFailed(Exception('Upload ảnh thất bại'));
        }
      }

      // Tạo model với URL mới
      final model = ClothingItemModel(
        id: '',
        name: item.name,
        category: item.category,
        warmthLevel: item.warmthLevel,
        imageUrl: imageUrl,
        material: item.material,
        style: item.style,
        gender: item.gender,
        contributedBy: item.contributedBy,
        createdAt: DateTime.now(),
      );

      final result = await _dataSource.addClothingItem(model);
      return DataSuccess(result);
    } catch (e) {
      return DataFailed(Exception('Lỗi khi thêm đồ: $e'));
    }
  }

  @override
  Future<DataState<List<String>>> getUserFavorites(String userId) async {
    try {
      final favorites = await _dataSource.getUserFavorites(userId);
      return DataSuccess(favorites);
    } catch (e) {
      return DataFailed(Exception('Lỗi khi lấy favorites: $e'));
    }
  }

  @override
  Future<DataState<void>> toggleFavorite(String userId, String itemId) async {
    try {
      await _dataSource.toggleFavorite(userId, itemId);
      return const DataSuccess(null);
    } catch (e) {
      return DataFailed(Exception('Lỗi khi toggle favorite: $e'));
    }
  }
}
