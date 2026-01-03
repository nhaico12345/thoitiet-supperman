// Mô tả: BLoC xử lý state cho màn hình Tủ Đồ.
// Quản lý tải danh sách đồ và thêm đồ mới.

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/resources/data_state.dart';
import '../../domain/entities/clothing_item.dart';
import '../../domain/repositories/wardrobe_repository.dart';

part 'wardrobe_event.dart';
part 'wardrobe_state.dart';

class WardrobeBloc extends Bloc<WardrobeEvent, WardrobeState> {
  final WardrobeRepository _repository;

  WardrobeBloc(this._repository) : super(const WardrobeState()) {
    on<LoadWardrobeItems>(_onLoadItems);
    on<AddClothingItemEvent>(_onAddItem);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<FilterByCategory>(_onFilterByCategory);
  }

  Future<void> _onLoadItems(
    LoadWardrobeItems event,
    Emitter<WardrobeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await _repository.getWardrobeItems(category: event.category);

    if (result is DataSuccess) {
      emit(state.copyWith(items: result.data ?? [], isLoading: false));
    } else {
      emit(
        state.copyWith(
          error: result.error?.toString() ?? 'Lỗi không xác định',
          isLoading: false,
        ),
      );
    }
  }

  Future<void> _onAddItem(
    AddClothingItemEvent event,
    Emitter<WardrobeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await _repository.addClothingItem(
      event.item,
      event.imageFile,
    );

    if (result is DataSuccess) {
      // Reload danh sách sau khi thêm thành công
      add(LoadWardrobeItems(category: state.selectedCategory));
    } else {
      emit(
        state.copyWith(
          error: result.error?.toString() ?? 'Lỗi khi thêm đồ',
          isLoading: false,
        ),
      );
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<WardrobeState> emit,
  ) async {
    await _repository.toggleFavorite(event.userId, event.itemId);
    // Cập nhật UI local
    final updatedFavorites = List<String>.from(state.favoriteIds);
    if (updatedFavorites.contains(event.itemId)) {
      updatedFavorites.remove(event.itemId);
    } else {
      updatedFavorites.add(event.itemId);
    }
    emit(state.copyWith(favoriteIds: updatedFavorites));
  }

  void _onFilterByCategory(
    FilterByCategory event,
    Emitter<WardrobeState> emit,
  ) {
    emit(state.copyWith(selectedCategory: event.category));
    add(LoadWardrobeItems(category: event.category));
  }
}
