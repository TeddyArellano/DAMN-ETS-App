import '../entities/building.dart';
import '../repositories/admin_repository.dart';

class GetBuildings {
  const GetBuildings(this._repository);

  final AdminRepository _repository;

  Future<List<Building>> call() {
    return _repository.getBuildings();
  }
}