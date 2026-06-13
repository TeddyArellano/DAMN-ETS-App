import '../entities/career.dart';
import '../repositories/admin_repository.dart';

class CreateCareer {
  const CreateCareer(this._repository);

  final AdminRepository _repository;

  Future<Career> call({
    required String code,
    required String name,
    required List<String> plans,
  }) {
    return _repository.createCareer(
      code: code,
      name: name,
      plans: plans,
    );
  }
}