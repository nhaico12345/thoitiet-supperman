// Xử lý quyền và cấu hình thiết bị.
// Yêu cầu quyền thông báo, hướng dẫn bật Auto-start cho Xiaomi/Oppo/Vivo.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class DeviceService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Xin quyền vị trí và thông báo khi người dùng mới cài app
  Future<void> requestInitialPermissions() async {
    // Xin quyền vị trí trước
    await checkAndRequestLocationPermission();
    // Sau đó xin quyền thông báo
    await checkAndRequestNotificationPermission();
  }

  Future<void> checkAndRequestLocationPermission() async {
    if (await Permission.location.isDenied) {
      await Permission.location.request();
    }
  }

  Future<void> checkAndRequestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> checkAndShowAutoStartDialog(BuildContext context) async {
    if (!Platform.isAndroid) return;

    final androidInfo = await _deviceInfo.androidInfo;
    final manufacturer = androidInfo.manufacturer.toLowerCase();

    if (manufacturer.contains('xiaomi') ||
        manufacturer.contains('oppo') ||
        manufacturer.contains('vivo')) {
      if (context.mounted) {
        _showAutoStartDialog(context, manufacturer);
      }
    }
  }

  void _showAutoStartDialog(BuildContext context, String manufacturer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lưu ý quan trọng'),
        content: Text(
          'Bạn đang sử dụng thiết bị $manufacturer. '
          'Để nhận thông báo thời tiết ổn định, vui lòng cấp quyền "Tự khởi chạy" (Auto-start) cho ứng dụng trong phần Cài đặt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đã hiểu'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text('Mở Cài đặt'),
          ),
        ],
      ),
    );
  }
}
