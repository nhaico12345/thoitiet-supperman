import 'package:flutter_test/flutter_test.dart';
import 'package:sieuthoitiet/features/home/domain/services/recommendation_service.dart';

void main() {
  group('RecommendationService Tests', () {
    test('Should recommend warm clothes when temp < 10', () {
      final recs = RecommendationService.getRecommendations(
        temp: 5,
        weatherCode: 0,
        aqi: 50,
        uvIndex: 2,
        windSpeed: 5,
      );

      expect(recs.any((r) => r.title == 'Áo khoác dày'), true);
    });

    test('Should recommend light jacket when temp is between 10 and 20', () {
      final recs = RecommendationService.getRecommendations(
        temp: 15,
        weatherCode: 0,
        aqi: 50,
        uvIndex: 2,
        windSpeed: 5,
      );

      expect(recs.any((r) => r.title == 'Áo khoác nhẹ'), true);
    });

    test('Should recommend comfortable clothes when temp is between 20 and 30', () {
      final recs = RecommendationService.getRecommendations(
        temp: 25,
        weatherCode: 0,
        aqi: 50,
        uvIndex: 2,
        windSpeed: 5,
      );

      expect(recs.any((r) => r.title == 'Trang phục thoải mái'), true);
    });

    test('Should recommend rain gear when raining', () {
      // Weather code 61 is slight rain
      final recs = RecommendationService.getRecommendations(
        temp: 25,
        weatherCode: 61,
        aqi: 50,
        uvIndex: 2,
        windSpeed: 5,
      );

      expect(recs.any((r) => r.title == 'Dù / Áo mưa'), true);
    });

    test('Should recommend indoor activities when raining', () {
      final recs = RecommendationService.getRecommendations(
        temp: 25,
        weatherCode: 61,
        aqi: 50,
        uvIndex: 2,
        windSpeed: 5,
      );

      expect(recs.any((r) => r.category == 'Hoạt động' && r.title == 'Hoạt động trong nhà'), true);
    });
  });
}
