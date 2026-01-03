// Gọi API Groq AI để lấy gợi ý, tóm tắt thời tiết, tư vấn trang phục.

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// Service để gọi Groq AI API
typedef GeminiService = GroqService;

class GroqService {
  final String _apiKey;
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const int _maxRetries = 2;
  static const List<String> _models = [
    'llama-3.3-70b-versatile',
    'moonshotai/kimi-k2-instruct',
    'groq/compound',
    'meta-llama/llama-4-maverick-17b-128e-instruct',
    'meta-llama/llama-4-scout-17b-16e-instruct',
    'qwen/qwen3-32b',
    'groq/compound-mini',
    'llama-3.1-8b-instant',
    'gemma2-9b-it',
    'mixtral-8x7b-32768',
  ];

  GroqService({required String apiKey}) : _apiKey = apiKey {
    if (kDebugMode) {
      print('GroqService: Initialized with model: ${_models.first}');
    }
  }

  Future<String?> generateContent(String prompt) async {
    Exception? lastError;

    // Thử với model chính trước
    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        if (kDebugMode) {
          print(
            'GroqService: Attempt ${attempt + 1}/$_maxRetries with model: ${_models.first}',
          );
        }

        final result = await _callGroqAPI(prompt, _models.first);
        if (result != null && result.isNotEmpty) {
          if (kDebugMode) {
            print('GroqService: Success! Response length: ${result.length}');
          }
          return result;
        } else {
          lastError = Exception('Empty response from Groq API');
        }
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        if (kDebugMode) {
          print('GroqService: Error on attempt ${attempt + 1}: $e');
        }

        // Chờ trước khi thử lại (exponential backoff)
        if (attempt < _maxRetries - 1) {
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
        }
      }
    }

    // Thử các model dự phòng
    for (int i = 1; i < _models.length; i++) {
      try {
        if (kDebugMode) {
          print('GroqService: Trying fallback model: ${_models[i]}');
        }

        final result = await _callGroqAPI(prompt, _models[i]);
        if (result != null && result.isNotEmpty) {
          if (kDebugMode) {
            print('GroqService: Fallback model success! Model: ${_models[i]}');
          }
          return result;
        }
      } catch (e) {
        if (kDebugMode) {
          print('GroqService: Fallback model ${_models[i]} failed: $e');
        }
      }
    }

    if (kDebugMode) {
      print('GroqService: All attempts failed. Last error: $lastError');
    }
    return null;
  }

  Future<String?> _callGroqAPI(String prompt, String model) async {
    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: jsonEncode({
            'model': model,
            'messages': [
              {'role': 'user', 'content': prompt},
            ],
            'temperature': 0.7,
            'max_tokens': 1024,
          }),
        )
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('Request timeout after 30 seconds');
          },
        );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices']?[0]?['message']?['content'];
      return content as String?;
    } else {
      final errorBody = response.body;
      if (kDebugMode) {
        print('GroqService: API Error ${response.statusCode}: $errorBody');
      }
      throw Exception('Groq API Error: ${response.statusCode} - $errorBody');
    }
  }
}
