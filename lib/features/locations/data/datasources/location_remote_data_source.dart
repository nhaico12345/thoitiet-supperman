// Tìm kiếm địa điểm qua API Open-Meteo Geocoding.
// Trả về danh sách vị trí khớp với từ khóa tìm kiếm.

import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/models/location_model.dart';

abstract class LocationRemoteDataSource {
  Future<List<LocationModel>> searchLocation(String query);
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final DioClient dioClient;

  LocationRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<LocationModel>> searchLocation(String query) async {
    final response = await dioClient.dio.get(
      'https://geocoding-api.open-meteo.com/v1/search',
      queryParameters: {
        'name': query,
        'count': 10,
        'language': 'en',
        'format': 'json',
      },
    );

    if (response.statusCode == 200) {
      final results = response.data['results'];
      if (results != null && results is List) {
        return results.map((e) => LocationModel.fromJson(e)).toList();
      }
      return [];
    } else {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
    }
  }
}
