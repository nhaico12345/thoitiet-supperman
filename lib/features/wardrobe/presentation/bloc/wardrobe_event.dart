part of 'wardrobe_bloc.dart';

abstract class WardrobeEvent extends Equatable {
  const WardrobeEvent();

  @override
  List<Object?> get props => [];
}

/// Tải danh sách đồ từ tủ chung
class LoadWardrobeItems extends WardrobeEvent {
  final String? category;

  const LoadWardrobeItems({this.category});

  @override
  List<Object?> get props => [category];
}

/// Thêm món đồ mới
class AddClothingItemEvent extends WardrobeEvent {
  final ClothingItem item;
  final File? imageFile;

  const AddClothingItemEvent(this.item, this.imageFile);

  @override
  List<Object?> get props => [item, imageFile];
}

/// Toggle yêu thích
class ToggleFavoriteEvent extends WardrobeEvent {
  final String userId;
  final String itemId;

  const ToggleFavoriteEvent(this.userId, this.itemId);

  @override
  List<Object?> get props => [userId, itemId];
}

/// Lọc theo category
class FilterByCategory extends WardrobeEvent {
  final String? category;

  const FilterByCategory(this.category);

  @override
  List<Object?> get props => [category];
}
