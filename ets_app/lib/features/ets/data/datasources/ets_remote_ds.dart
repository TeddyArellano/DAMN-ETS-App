import 'package:dio/dio.dart';

import '../../../../core/network/api_exceptions.dart';
import '../models/ets_model.dart';

class EtsRemoteDataSource {
  const EtsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<EtsModel>> getEts() async {
    try {
      final response = await _dio.get<List<dynamic>>('/ets');
      final data = response.data ?? [];

      return data
          .whereType<Map<String, dynamic>>()
          .map(EtsModel.fromJson)
          .toList();
    } on DioException catch (exception) {
      throw ApiException.fromDio(exception);
    }
  }
}