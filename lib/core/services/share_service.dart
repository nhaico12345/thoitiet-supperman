// Chụp và chia sẻ thẻ thời tiết đẹp mắt.

import 'dart:io';

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import '../../features/home/domain/entities/weather.dart';
import '../../features/home/presentation/widgets/shareable_weather_card.dart';
import '../utils/share_utils.dart';

// Dịch vụ chụp và chia sẻ thẻ thời tiết
class ShareService {
  static final ShareService _instance = ShareService._internal();

  factory ShareService() {
    return _instance;
  }

  ShareService._internal();

  /// Chụp widget thành ảnh
  Future<Uint8List?> captureWidget(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Lỗi khi chụp widget: $e');
      return null;
    }
  }

  /// Lưu bytes vào file tạm thời và trả về đường dẫn
  Future<String?> saveToTempFile(Uint8List bytes, String filename) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$filename');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      debugPrint('Lỗi khi lưu file: $e');
      return null;
    }
  }

  /// Chia sẻ file ảnh
  Future<void> shareImage(String filePath, {String? text}) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          text: text ?? 'Thời tiết hôm nay từ WeatherStyle Pro 🌤️',
        ),
      );
    } catch (e) {
      debugPrint('Lỗi khi chia sẻ: $e');
    }
  }

  /// Chia sẻ thời tiết dưới dạng văn bản
  Future<void> shareWeatherText(
    WeatherEntity weather, {
    String? ootdAdvice,
  }) async {
    final text = formatWeatherShareTextWithOOTD(weather, ootdAdvice);
    await SharePlus.instance.share(ShareParams(text: text));
  }
}

// Dialog hiển thị thẻ chia sẻ và xử lý việc chia sẻ
class ShareWeatherDialog extends StatefulWidget {
  final WeatherEntity weather;
  final String? ootdAdvice;

  const ShareWeatherDialog({super.key, required this.weather, this.ootdAdvice});

  /// Hiển thị dialog chia sẻ
  static Future<void> show(
    BuildContext context,
    WeatherEntity weather, {
    String? ootdAdvice,
  }) {
    return showDialog(
      context: context,
      builder: (context) =>
          ShareWeatherDialog(weather: weather, ootdAdvice: ootdAdvice),
    );
  }

  @override
  State<ShareWeatherDialog> createState() => _ShareWeatherDialogState();
}

class _ShareWeatherDialogState extends State<ShareWeatherDialog> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _shareAsImage() async {
    setState(() => _isSharing = true);

    try {
      final shareService = ShareService();

      // Chụp widget
      final bytes = await shareService.captureWidget(_cardKey);
      if (bytes == null) {
        _showError('Không thể tạo ảnh');
        return;
      }

      // Lưu vào file tạm thời
      final filename = 'weather_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = await shareService.saveToTempFile(bytes, filename);
      if (filePath == null) {
        _showError('Không thể lưu ảnh');
        return;
      }

      // Share
      await shareService.shareImage(filePath);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showError('Lỗi khi chia sẻ: $e');
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _shareAsText() async {
    final shareService = ShareService();
    await shareService.shareWeatherText(
      widget.weather,
      ootdAdvice: widget.ootdAdvice,
    );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _copyToClipboard() async {
    final text = formatWeatherShareTextWithOOTD(
      widget.weather,
      widget.ootdAdvice,
    );
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã copy! 📋'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Thẻ xem trước (thu nhỏ để xem trước)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: 270,
              height: 480,
              child: FittedBox(
                fit: BoxFit.contain,
                child: RepaintBoundary(
                  key: _cardKey,
                  child: ShareableWeatherCard(
                    weather: widget.weather,
                    ootdAdvice: widget.ootdAdvice,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Các nút hành động
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Nút chia sẻ ảnh
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSharing ? null : _shareAsImage,
                    icon: _isSharing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.image),
                    label: Text(_isSharing ? 'Đang xử lý...' : 'Chia sẻ ảnh'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Nút copy vào clipboard
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _copyToClipboard,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy text'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Nút chia sẻ văn bản
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _shareAsText,
                    icon: const Icon(Icons.text_fields),
                    label: const Text('Chia sẻ text'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Nút hủy
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
