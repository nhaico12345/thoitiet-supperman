// Widget hiển thị gợi ý trang phục dựa trên thời tiết.

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/clothing_item.dart';
import '../../../../core/services/outfit_recommendation_service.dart';

class OutfitSuggestionWidget extends StatelessWidget {
  final double temperature;
  final int weatherCode;
  final List<ClothingItem> allItems;
  final List<String> favoriteIds;

  const OutfitSuggestionWidget({
    super.key,
    required this.temperature,
    required this.weatherCode,
    required this.allItems,
    this.favoriteIds = const [],
  });

  @override
  Widget build(BuildContext context) {
    final service = OutfitRecommendationService();
    final combo = service.suggestOutfitCombo(
      allItems: allItems,
      temperature: temperature,
      weatherCode: weatherCode,
      favoriteIds: favoriteIds,
    );

    final warmthLevel = service.getRequiredWarmthLevel(temperature);
    final warmthDesc = service.getWarmthDescription(warmthLevel);
    final isRainy = service.isRainyWeather(weatherCode);

    final hasItems =
        combo['top'] != null ||
        combo['bottom'] != null ||
        combo['outer'] != null;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.checkroom, color: Colors.deepPurple),
                const SizedBox(width: 8),
                const Text(
                  'Gợi Ý Trang Phục Hôm Nay',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),

            // Weather info
            Row(
              children: [
                _buildInfoChip(
                  icon: Icons.thermostat,
                  label: '${temperature.round()}°C',
                  color: _getWarmthColor(warmthLevel),
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  icon: Icons.style,
                  label: warmthDesc,
                  color: Colors.blueGrey,
                ),
              ],
            ),

            if (isRainy) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.umbrella, size: 18, color: Colors.blue),
                    SizedBox(width: 6),
                    Text(
                      'Trời có mưa - mang áo khoác!',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Outfit combo
            if (hasItems) ...[
              const Text(
                '👕 Outfit gợi ý:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    if (combo['top'] != null)
                      _buildItemCard(combo['top']!, 'Áo'),
                    if (combo['bottom'] != null)
                      _buildItemCard(combo['bottom']!, 'Quần'),
                    if (combo['outer'] != null)
                      _buildItemCard(combo['outer']!, 'Khoác'),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Chưa có đồ phù hợp trong tủ.\nHãy đóng góp thêm để nhận gợi ý!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(ClothingItem item, String label) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (_, __) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            item.name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Color _getWarmthColor(int level) {
    if (level <= 3) return Colors.blue;
    if (level <= 6) return Colors.orange;
    return Colors.red;
  }
}
