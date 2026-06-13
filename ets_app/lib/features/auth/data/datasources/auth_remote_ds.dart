import 'package:dio/dio.dart';

import '../../../../core/network/api_exceptions.dart';
import '../../domain/entities/user.dart';

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.user,
  });

  final String accessToken;
  final User user;
}

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      return _parseSession(response.data);
    } on DioException catch (exception) {
      throw ApiException.fromDio(exception);
    }
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    String? boleta,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/register',
        data: {
          'name': name.trim(),
          'email': email.trim(),
          'password': password,
          if (boleta != null && boleta.trim().isNotEmpty)
            'boleta': boleta.trim(),
        },
      );

      return _parseSession(response.data);
    } on DioException catch (exception) {
      throw ApiException.fromDio(exception);
    }
  }

  Future<User> me() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/auth/me');
      final data = response.data;

      if (data == null) {
        throw const ApiException('El servidor devolvió una respuesta vacía.');
      }

      return User.fromJson(data);
    } on DioException catch (exception) {
      throw ApiException.fromDio(exception);
    }
  }

  AuthSession _parseSession(Map<String, dynamic>? data) {
    if (data == null) {
      throw const ApiException('El servidor devolvió una respuesta vacía.');
    }

    final accessToken = data['accessToken']?.toString();
    final userData = data['user'];

    if (accessToken == null || userData is! Map<String, dynamic>) {
      throw const ApiException(
        'La respuesta de autenticación no tiene el formato esperado.',
      );
    }

    return AuthSession(
      accessToken: accessToken,
      user: User.fromJson(userData),
    );
  }
}