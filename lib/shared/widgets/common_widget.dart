// Các widget dùng chung trong toàn bộ ứng dụng.
// Bao gồm LoadingWidget để hiển thị trạng thái đang tải.

import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
