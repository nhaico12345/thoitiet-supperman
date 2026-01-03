// File: home_tablet_layout.dart
// Mô tả: Layout màn hình chính cho tablet với 2 cột.
// Cột trái: thời tiết hiện tại + gợi ý. Cột phải: dự báo + chi tiết.

import 'package:flutter/material.dart';
import '../../../domain/entities/weather.dart';
import '../../../../settings/domain/entities/settings.dart';
import '../../widgets/current_weather_card.dart';
import '../../widgets/last_updated_banner.dart';
import '../../widgets/recommendation_widget.dart';
import '../../widgets/aqi_widget.dart';
import '../../widgets/hourly_forecast_widget.dart';
import '../../widgets/environmental_grid_widget.dart';
import '../../widgets/daily_forecast_widget.dart';
import '../../widgets/weather_summary_card.dart';
import '../../../domain/services/recommendation_service.dart';

class HomeTabletLayout extends StatelessWidget {
  final WeatherEntity weather;
  final SettingsEntity settings;
  final List<Recommendation> recommendations;
  final bool isAILoading;
  final String? weatherSummary;

  const HomeTabletLayout({
    super.key,
    required this.weather,
    required this.settings,
    this.recommendations = const [],
    this.isAILoading = false,
    this.weatherSummary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80, left: 16, right: 16, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Current Info
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  LastUpdatedBanner(lastUpdated: weather.lastUpdated),
                  CurrentWeatherCard(weather: weather, settings: settings),
                  if (weatherSummary != null || isAILoading) ...[
                    WeatherSummaryCard(
                      summary: weatherSummary ?? '',
                      isLoading: isAILoading,
                    ),
                  ],
                  const SizedBox(height: 20),
                  RecommendationWidget(
                    recommendations: recommendations,
                    isLoading: isAILoading,
                  ),
                  const SizedBox(height: 20),
                  Card(
                    color: Colors.white.withValues(alpha: 0.9),
                    child: AqiWidget(aqi: weather.aqi),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Right Column: Details
          Expanded(
            flex: 6,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (weather.hourlyForecasts != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: HourlyForecastWidget(
                        forecasts: weather.hourlyForecasts!,
                      ),
                    ),
                  const SizedBox(height: 20),
                  EnvironmentalGridWidget(weather: weather),
                  const SizedBox(height: 20),
                  if (weather.dailyForecasts != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DailyForecastWidget(
                        forecasts: weather.dailyForecasts!,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
