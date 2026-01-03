// Banner cảnh báo khi dữ liệu thời tiết đã cũ (>30 phút).
// Hiển thị thời gian cập nhật cuối cùng để người dùng biết dữ liệu không mới.

import 'package:flutter/material.dart';

class LastUpdatedBanner extends StatelessWidget {
  final String? lastUpdated;

  const LastUpdatedBanner({super.key, this.lastUpdated});

  @override
  Widget build(BuildContext context) {
    if (lastUpdated == null) return const SizedBox();

    final date = DateTime.tryParse(lastUpdated!);
    if (date == null) return const SizedBox();

    final isStale = DateTime.now().difference(date).inMinutes > 30;

    if (!isStale) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.black87,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Đang hiển thị dữ liệu cũ (Cập nhật lúc ${_formatDate(date)})',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} - ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
