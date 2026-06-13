import '../../../../core/storage/token_storage.dart';

class AuthLocalDataSource {
  const AuthLocalDataSource(this._tokenStorage);

  final TokenStorage _tokenStorage;

  Future<void> saveToken(String token) {
    return _tokenStorage.saveToken(token);
  }

  Future<String?> getToken() {
    return _tokenStorage.getToken();
  }

  Future<void> clearToken() {
    return _tokenStorage.clearToken();
  }
}