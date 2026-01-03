// Service upload ảnh lên Cloudinary và trả về URL.

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  static const String _cloudName = 'dbvq5g1ef';
  static const String _uploadPreset = 'ml_default';

  // Upload ảnh từ file và trả về secure URL
  Future<String?> uploadImage(File imageFile, {String? folder}) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri);

      // Thêm file
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      // Dùng unsigned upload preset
      request.fields['upload_preset'] = _uploadPreset;

      if (folder != null && folder.isNotEmpty) {
        request.fields['folder'] = folder;
      }

      if (kDebugMode) {
        print('CloudinaryService: Đang upload ảnh...');
        print('CloudinaryService: Cloud Name: $_cloudName');
        print('CloudinaryService: Upload Preset: $_uploadPreset');
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('CloudinaryService: Status Code: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final secureUrl = data['secure_url'] as String?;

        if (kDebugMode) {
          print('CloudinaryService: Upload thành công!');
          print('CloudinaryService: Public ID: ${data['public_id']}');
          print('CloudinaryService: Secure URL: $secureUrl');
        }

        return secureUrl;
      } else {
        if (kDebugMode) {
          print('CloudinaryService: Upload thất bại!');
          print('CloudinaryService: Status: ${response.statusCode}');
          print('CloudinaryService: Body: ${response.body}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('CloudinaryService: Exception: $e');
      }
      return null;
    }
  }
}
