// Service tạo gợi ý hoạt động dự phòng khi AI không khả dụng.
// Logic dựa trên nhiệt độ, mã thời tiết, AQI, UV để gợi ý trang phục/hoạt động.

import 'package:equatable/equatable.dart';

class Recommendation extends Equatable {
  final String category;
  final String title;
  final String icon;
  final String description;
  final bool isAlert;

  const Recommendation({
    required this.category,
    required this.title,
    required this.icon,
    required this.description,
    this.isAlert = false,
  });

  @override
  List<Object?> get props => [category, title, icon, description, isAlert];
}

class RecommendationService {
  static List<Recommendation> getRecommendations({
    required double? temp,
    required int? weatherCode,
    required int? aqi,
    required double? uvIndex,
    required double? windSpeed,
  }) {
    final List<Recommendation> recommendations = [];

    if (temp == null || weatherCode == null) return [];

    // 1. Clothing Logic
    if (temp < 10) {
      recommendations.add(
        const Recommendation(
          category: 'Trang phục',
          title: 'Áo khoác dày',
          icon: '🧥',
          description: 'Trời rất lạnh. Hãy mặc quần áo ấm.',
        ),
      );
    } else if (temp < 20) {
      recommendations.add(
        const Recommendation(
          category: 'Trang phục',
          title: 'Áo khoác nhẹ',
          icon: '👕',
          description: 'Trời hơi se lạnh. Nên mặc áo khoác nhẹ.',
        ),
      );
    } else if (temp <= 30) {
      recommendations.add(
        const Recommendation(
          category: 'Trang phục',
          title: 'Trang phục thoải mái',
          icon: '👕',
          description: 'Thời tiết dễ chịu. Hãy mặc trang phục thoải mái.',
        ),
      );
    } else {
      recommendations.add(
        const Recommendation(
          category: 'Trang phục',
          title: 'Áo phông & Quần đùi',
          icon: '🩳',
          description: 'Trời nóng. Hãy mặc quần áo thoáng mát.',
        ),
      );
    }

    // Rain Gear
    if (_isRaining(weatherCode)) {
      recommendations.add(
        const Recommendation(
          category: 'Trang phục',
          title: 'Dù / Áo mưa',
          icon: '☔',
          description: 'Có khả năng mưa. Đừng quên mang dù!',
        ),
      );
    }

    // 2. Activity Logic
    if (!_isRaining(weatherCode) &&
        temp >= 15 &&
        temp <= 28 &&
        (aqi ?? 0) < 100) {
      recommendations.add(
        const Recommendation(
          category: 'Hoạt động',
          title: 'Chạy bộ / Đi bộ',
          icon: '🏃',
          description: 'Thời tiết tuyệt vời để chạy bộ ngoài trời.',
        ),
      );
      recommendations.add(
        const Recommendation(
          category: 'Hoạt động',
          title: 'Dã ngoại',
          icon: '🧺',
          description: 'Điều kiện hoàn hảo cho một buổi dã ngoại.',
        ),
      );
    } else if (_isRaining(weatherCode)) {
      recommendations.add(
        const Recommendation(
          category: 'Hoạt động',
          title: 'Hoạt động trong nhà',
          icon: '🏠',
          description: 'Tốt hơn là nên ở trong nhà và đọc sách.',
        ),
      );
    }

    // 3. Alerts
    if ((aqi ?? 0) > 150) {
      recommendations.add(
        const Recommendation(
          category: 'Cảnh báo',
          title: 'Chất lượng không khí kém',
          icon: '😷',
          description:
              'Không khí không tốt cho sức khỏe. Đeo khẩu trang khi ra ngoài.',
          isAlert: true,
        ),
      );
    } else if ((aqi ?? 0) >= 100) {
      recommendations.add(
        const Recommendation(
          category: 'Cảnh báo',
          title: 'Chất lượng không khí trung bình',
          icon: '😷',
          description:
              'Không khí không tốt cho người nhạy cảm. Hạn chế hoạt động ngoài trời.',
          isAlert: true,
        ),
      );
    }

    if ((uvIndex ?? 0) > 8) {
      recommendations.add(
        const Recommendation(
          category: 'Cảnh báo',
          title: 'Chỉ số UV cao',
          icon: '🧴',
          description: 'UV rất cao. Sử dụng kem chống nắng và đội mũ.',
          isAlert: true,
        ),
      );
    }

    if (_isStorm(weatherCode)) {
      recommendations.add(
        const Recommendation(
          category: 'Cảnh báo',
          title: 'Cảnh báo bão',
          icon: '⚡',
          description: 'Phát hiện bão. Hãy ở trong nhà an toàn.',
          isAlert: true,
        ),
      );
    }

    return recommendations;
  }

  static bool _isRaining(int code) {
    const rainCodes = [51, 53, 55, 61, 63, 65, 80, 81, 82, 95, 96, 99];
    return rainCodes.contains(code);
  }

  static bool _isStorm(int code) {
    return [95, 96, 99].contains(code);
  }
}
