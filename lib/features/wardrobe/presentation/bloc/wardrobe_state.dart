part of 'wardrobe_bloc.dart';

class WardrobeState extends Equatable {
  final List<ClothingItem> items;
  final List<String> favoriteIds;
  final bool isLoading;
  final String? error;
  final String? selectedCategory;

  const WardrobeState({
    this.items = const [],
    this.favoriteIds = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory,
  });

  WardrobeState copyWith({
    List<ClothingItem>? items,
    List<String>? favoriteIds,
    bool? isLoading,
    String? error,
    String? selectedCategory,
  }) {
    return WardrobeState(
      items: items ?? this.items,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  @override
  List<Object?> get props => [
    items,
    favoriteIds,
    isLoading,
    error,
    selectedCategory,
  ];
}
