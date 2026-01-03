// Interceptor xử lý request/response HTTP.
// Log request, response và chuyển đổi mã lỗi HTTP thành thông báo tiếng Việt.

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class NetworkInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('--> ${options.method} ${options.uri}');
      print('Headers: ${options.headers}');
      if (options.data != null) {
        print('Body: ${options.data}');
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('<-- ${response.statusCode} ${response.requestOptions.uri}');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('<-- ERROR ${err.message} ${err.requestOptions.uri}');
    }

    String errorDescription = "Unknown Error";
    if (err.response != null) {
      switch (err.response?.statusCode) {
        case 400:
          errorDescription = "Kết nối không thành công (400)";
          break;
        case 401:
          errorDescription = "Kết nối không thành công (401)";
          break;
        case 403:
          errorDescription = "Kết nối không thành công (403)";
          break;
        case 404:
          errorDescription = "Kết nối không thành công (404)";
          break;
        case 500:
          errorDescription = "Kết nối không thành công (500)";
          break;
        case 503:
          errorDescription = "Kết nối không thành công (503)";
          break;
        default:
          errorDescription =
              "Received invalid status code: ${err.response?.statusCode}";
      }
    } else {
      switch (err.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorDescription = "Kết nối không thành công (Timeout)";
          break;
        case DioExceptionType.cancel:
          errorDescription = "Yêu cầu bị hủy";
          break;
        case DioExceptionType.connectionError:
          errorDescription =
              "Kết nối không thành công (No Internet Connection)";
          break;
        default:
          errorDescription = "Kết nối không thành công: ${err.message}";
      }
    }

    final modifiedError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: err.error,
      message: errorDescription,
    );

    super.onError(modifiedError, handler);
  }
}
