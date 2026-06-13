import 'package:dio/dio.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../../ets/data/models/ets_model.dart';
import '../models/admin_dashboard_model.dart';
import '../models/building_model.dart';
import '../models/career_model.dart';
import '../models/subject_model.dart';

class AdminRemoteDataSource {
  const AdminRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AdminDashboardModel> getDashboard() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/admin/dashboard',
      );

      final data = response.data;

      if (data == null) {
        throw const ApiException(
          'El servidor devolvió una respuesta vacía.',
        );
      }

      return AdminDashboardModel.fromJson(data);
    } on DioException catch (exception) {
      throw ApiException.fromDio(exception);
    }
  }

  Future<List<CareerModel>> getCareers() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/catalog/careers',
      );

      final data = response.data ?? const <dynamic>[];

      return data
          .whereType<Map<String, dynamic>>()
          .map(CareerModel.fromJson)
          .toList();
    } on DioException catch (exception) {
      throw ApiException.fromDio(exception);
    }
  }

  Future<CareerModel> createCareer({
    required String code,
    required String name,
    required List<String> plans,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/admin/catalog/careers',
        data: {
          'code': code.trim().toUpperCase(),
          'name': name.trim(),
          'plans': plans,
        },
      );

      final data = response.data;

      if (data == null) {
        throw const ApiException(
          'No fue posible leer la carrera creada.',
        );
      }

      return CareerModel.fromJson(data);
    } on DioException catch (exception) {
      throw ApiException.fromDio(exception);
    }
  }

    Future<void> deleteCareer(int id) async {
    try {
      await _dio.delete<Map<String, dynamic>>(
        '/admin/catalog/careers/$id',
      );
    } on DioException catch (exception) {
      throw ApiException.fromDio(exception);
    }
  }

  Future<List<BuildingModel>> getBuildings() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/catalog/buildings',
      );

      final data = response.data ?? const <dynamic>[];

      return data
          .whereType<Map<String, dynamic>>()
          .map(BuildingModel.fromJson)
          .toList();
    } on DioException catch (exception) {
      throw ApiException.fromDio(exception);
    }
  }

  Future<BuildingModel> createBuilding({
    required String name,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/admin/catalog/buildings',
        data: {
          'name': name.trim(),
        },
      );

      final data = response.data;

      if (data == null) {
        throw const ApiException(
          'No fue posible leer el edificio creado.',
        );
      }

      return BuildingModel.fromJson(data);
    } on DioException catch (exception) {
      throw ApiException.fromDio(exception);
    }
  }

    Future<void> deleteBuilding(int id) async {
    try {
      await _dio.delete<Map<String, dynamic>>(
        '/admin/catalog/buildings/$id',
      );
    } on DioException catch (exception) {
      throw ApiException.fromDio(exception);
    }
  }

  Future<List<EtsModel>> getAdminEts() async {
    try {
      final response = await _dio.get<List<dynamic>>('/admin/ets');
      final data = response.data ?? const <dynamic>[];

      return data
          .whereType<Map<String, dynamic>>()
          .map(EtsModel.fromJson)
          .toList();
    } on DioException catch (exception) {
      throw ApiException.fromDio(exception);
    }
  }

  Future<EtsModel> createEts({
      required String ua,
      required int subjectId,
      required int careerId,
      required String plan,
      required int semestre,
      required String fechaIso,
      required String turno,
      required String salon,
      required String profesor,
      required String correo,
      required int buildingId,
    }) async {
      try {
        final response = await _dio.post<Map<String, dynamic>>(
          '/admin/ets',
          data: {
            'ua': ua,
            'subjectId': subjectId,
            'careerId': careerId,
            'plan': plan,
            'semestre': semestre,
            'fechaIso': fechaIso,
            'turno': turno,
            'salon': salon,
            'profesor': profesor,
            'correo': correo,
            'buildingId': buildingId,
          },
        );

        final data = response.data;

        if (data == null) {
          throw const ApiException(
            'No fue posible leer el ETS creado.',
          );
        }

        return EtsModel.fromJson(data);
      } on DioException catch (exception) {
        throw ApiException.fromDio(exception);
      }
    }

  Future<EtsModel> updateEts({
      required int id,
      required String ua,
      required int subjectId,
      required int careerId,
      required String plan,
      required int semestre,
      required String fechaIso,
      required String turno,
      required String salon,
      required String profesor,
      required String correo,
      required int buildingId,
    }) async {
      try {
        final response = await _dio.put<Map<String, dynamic>>(
          '/admin/ets/$id',
          data: {
            'ua': ua,
            'subjectId': subjectId,
            'careerId': careerId,
            'plan': plan,
            'semestre': semestre,
            'fechaIso': fechaIso,
            'turno': turno,
            'salon': salon,
            'profesor': profesor,
            'correo': correo,
            'buildingId': buildingId,
          },
        );

        final data = response.data;

        if (data == null) {
          throw const ApiException(
            'No fue posible leer el ETS actualizado.',
          );
        }

        return EtsModel.fromJson(data);
      } on DioException catch (exception) {
        throw ApiException.fromDio(exception);
      }
    }

    Future<void> deleteEts(int id) async {
      try {
        await _dio.delete<void>('/admin/ets/$id');
      } on DioException catch (exception) {
        throw ApiException.fromDio(exception);
      }
    }

  Future<List<SubjectModel>> getSubjects({
    int? careerId,
    String? plan,
    int? semestre,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      queryParameters.addAll(
        careerId == null
            ? const <String, dynamic>{}
            : <String, dynamic>{'careerId': careerId},
      );

      queryParameters.addAll(
        plan == null || plan.isEmpty
            ? const <String, dynamic>{}
            : <String, dynamic>{'plan': plan},
      );

      queryParameters.addAll(
        semestre == null
            ? const <String, dynamic>{}
            : <String, dynamic>{'semestre': semestre},
      );

      final response = await _dio.get<List<dynamic>>(
        '/catalog/subjects',
        queryParameters: queryParameters,
      );

      final data = response.data ?? const <dynamic>[];

      return data
          .whereType<Map<String, dynamic>>()
          .map(SubjectModel.fromJson)
          .toList();
    } on DioException catch (exception) {
      throw ApiException.fromDio(exception);
    }
  }
}
