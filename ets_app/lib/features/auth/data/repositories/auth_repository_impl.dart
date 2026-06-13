import '../../../../core/network/api_exceptions.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_ds.dart';
import '../datasources/auth_remote_ds.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final session = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    await _localDataSource.saveToken(session.accessToken);

    return session.user;
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    String? boleta,
  }) async {
    final session = await _remoteDataSource.register(
      name: name,
      email: email,
      password: password,
      boleta: boleta,
    );

    await _localDataSource.saveToken(session.accessToken);

    return session.user;
  }

  @override
  Future<User?> restoreSession() async {
    final token = await _localDataSource.getToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      return await _remoteDataSource.me();
    } on ApiException catch (exception) {
      if (exception.statusCode == 401 || exception.statusCode == 403) {
        await _localDataSource.clearToken();
        return null;
      }

      rethrow;
    }
  }

  @override
  Future<void> logout() {
    return _localDataSource.clearToken();
  }
}