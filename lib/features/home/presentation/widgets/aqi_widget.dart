// Widget hiển thị chỉ số chất lượng không khí (AQI).
// Hiển thị màu sắc và mô tả trạng thái theo thang AQI (Tốt→Nguy hại).

import 'package:flutter/material.dart';

class AqiWidget extends StatelessWidget {
  final int? aqi;

  const AqiWidget({super.key, required this.aqi});

  @override
  Widget build(BuildContext context) {
    if (aqi == null) return const SizedBox();

    final color = _getAqiColor(aqi!);
    final status = _getAqiStatus(aqi!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chất lượng không khí (AQI)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$aqi',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              status,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAqiColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow[700]!;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return Colors.purple;
    return Colors.brown;
  }

  String _getAqiStatus(int aqi) {
    if (aqi <= 50) return "Tốt";
    if (aqi <= 100) return "Trung bình";
    if (aqi <= 150) return "Kém cho người nhạy cảm";
    if (aqi <= 200) return "Kém";
    if (aqi <= 300) return "Rất kém";
    return "Nguy hại";
  }
}
