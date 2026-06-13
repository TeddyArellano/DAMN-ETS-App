import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class Me {
  const Me(this._repository);

  final AuthRepository _repository;

  Future<User?> call() {
    return _repository.restoreSession();
  }
}