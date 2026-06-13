import '../entities/career.dart';
import '../repositories/admin_repository.dart';

class GetCareers {
  const GetCareers(this._repository);

  final AdminRepository _repository;

  Future<List<Career>> call() {
    return _repository.getCareers();
  }
}