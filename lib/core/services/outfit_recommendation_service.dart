// Service gợi ý trang phục dựa trên thời tiết.
// Lọc đồ phù hợp từ tủ đồ dựa trên nhiệt độ và weather code.

import '../../../features/wardrobe/domain/entities/clothing_item.dart';

class OutfitRecommendationService {
  int getRequiredWarmthLevel(double temperature) {
    if (temperature >= 35) return 1; // Rất nóng → đồ mỏng nhất
    if (temperature >= 30) return 2;
    if (temperature >= 25) return 3;
    if (temperature >= 20) return 5;
    if (temperature >= 15) return 6;
    if (temperature >= 10) return 7;
    if (temperature >= 5) return 8;
    if (temperature >= 0) return 9;
    return 10; // Rất lạnh → đồ dày nhất
  }

  String getWarmthDescription(int level) {
    if (level <= 2) return 'Đồ mỏng, thoáng mát';
    if (level <= 4) return 'Đồ nhẹ, thoải mái';
    if (level <= 6) return 'Đồ dày trung bình';
    if (level <= 8) return 'Đồ ấm';
    return 'Đồ rất ấm, giữ nhiệt';
  }

  /// Kiểm tra có mưa không dựa trên weather code
  bool isRainyWeather(int weatherCode) {
    // Weather code mưa: 51-67 (mưa phùn), 80-82 (mưa rào), 95-99 (giông)
    return (weatherCode >= 51 && weatherCode <= 67) ||
        (weatherCode >= 80 && weatherCode <= 82) ||
        (weatherCode >= 95 && weatherCode <= 99);
  }

  /// Lọc đồ phù hợp với thời tiết
  List<ClothingItem> filterSuitableItems({
    required List<ClothingItem> allItems,
    required double temperature,
    required int weatherCode,
    List<String> favoriteIds = const [],
    String? preferredGender,
  }) {
    final requiredWarmth = getRequiredWarmthLevel(temperature);
    final tolerance = 2;
    final isRainy = isRainyWeather(weatherCode);

    // Bước 1: Lọc theo độ ấm phù hợp
    var filtered = allItems.where((item) {
      final warmthDiff = (item.warmthLevel - requiredWarmth).abs();
      return warmthDiff <= tolerance;
    }).toList();

    // Bước 2: Nếu mưa, ưu tiên áo khoác
    if (isRainy) {
      final jackets = allItems
          .where(
            (item) =>
                item.category.toLowerCase() == 'jacket' ||
                item.category.toLowerCase() == 'coat',
          )
          .toList();

      // Thêm jackets vào đầu danh sách
      for (var jacket in jackets) {
        if (!filtered.contains(jacket)) {
          filtered.insert(0, jacket);
        }
      }
    }

    // Bước 3: Lọc theo giới tính nếu có
    if (preferredGender != null && preferredGender != 'unisex') {
      filtered = filtered
          .where(
            (item) => item.gender == preferredGender || item.gender == 'unisex',
          )
          .toList();
    }

    // Bước 4: Sắp xếp - ưu tiên favorites lên đầu
    filtered.sort((a, b) {
      final aFav = favoriteIds.contains(a.id) ? 0 : 1;
      final bFav = favoriteIds.contains(b.id) ? 0 : 1;
      if (aFav != bFav) return aFav.compareTo(bFav);

      // Nếu cùng favorite status, sắp xếp theo độ phù hợp warmth
      final aDiff = (a.warmthLevel - requiredWarmth).abs();
      final bDiff = (b.warmthLevel - requiredWarmth).abs();
      return aDiff.compareTo(bDiff);
    });

    return filtered;
  }

  /// Tạo gợi ý outfit dạng text
  String generateOutfitAdvice({
    required double temperature,
    required int weatherCode,
    required List<ClothingItem> suggestedItems,
  }) {
    final warmthLevel = getRequiredWarmthLevel(temperature);
    final warmthDesc = getWarmthDescription(warmthLevel);
    final isRainy = isRainyWeather(weatherCode);

    final buffer = StringBuffer();
    buffer.writeln('🌡️ Nhiệt độ: ${temperature.round()}°C');
    buffer.writeln('👕 Gợi ý: $warmthDesc');

    if (isRainy) {
      buffer.writeln('🌧️ Trời có mưa - nên mang áo khoác chống nước!');
    }

    if (suggestedItems.isNotEmpty) {
      buffer.writeln('\n📋 Các món đồ phù hợp từ tủ đồ:');
      for (var i = 0; i < suggestedItems.take(5).length; i++) {
        final item = suggestedItems[i];
        buffer.writeln('  ${i + 1}. ${item.name} (${item.category})');
      }
    } else {
      buffer.writeln('\n⚠️ Chưa có đồ phù hợp trong tủ. Hãy đóng góp thêm!');
    }

    return buffer.toString();
  }

  /// Gợi ý outfit combo (áo + quần)
  Map<String, ClothingItem?> suggestOutfitCombo({
    required List<ClothingItem> allItems,
    required double temperature,
    required int weatherCode,
    List<String> favoriteIds = const [],
  }) {
    final filtered = filterSuitableItems(
      allItems: allItems,
      temperature: temperature,
      weatherCode: weatherCode,
      favoriteIds: favoriteIds,
    );

    ClothingItem? top;
    ClothingItem? bottom;
    ClothingItem? outer;

    // Categories áo
    final topCategories = ['t-shirt', 'hoodie', 'sweater'];
    // Categories quần
    final bottomCategories = ['jeans', 'shorts', 'dress'];
    // Categories áo khoác
    final outerCategories = ['jacket', 'coat'];

    for (var item in filtered) {
      final cat = item.category.toLowerCase();
      if (top == null && topCategories.contains(cat)) {
        top = item;
      } else if (bottom == null && bottomCategories.contains(cat)) {
        bottom = item;
      } else if (outer == null && outerCategories.contains(cat)) {
        outer = item;
      }

      if (top != null && bottom != null && outer != null) break;
    }

    return {'top': top, 'bottom': bottom, 'outer': outer};
  }
}
