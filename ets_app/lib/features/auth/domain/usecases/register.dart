import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class Register {
  const Register(this._repository);

  final AuthRepository _repository;

  Future<User> call({
    required String name,
    required String email,
    required String password,
    String? boleta,
  }) {
    return _repository.register(
      name: name,
      email: email,
      password: password,
      boleta: boleta,
    );
  }
}