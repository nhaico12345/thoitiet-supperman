// Cấu hình HTTP client (Dio) để gọi API.
// Thiết lập base URL, timeout, interceptor log và tự động retry khi lỗi.

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'network_interceptor.dart';

class DioClient {
  final Dio _dio;

  DioClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'https://api.open-meteo.com/v1',
          connectTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      ) {
    _dio.interceptors.addAll([
      NetworkInterceptor(),
      RetryInterceptor(
        dio: _dio,
        logPrint: print,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
      ),
    ]);
  }

  Dio get dio => _dio;
}
