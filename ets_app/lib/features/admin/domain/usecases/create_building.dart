import '../entities/building.dart';
import '../repositories/admin_repository.dart';

class CreateBuilding {
  const CreateBuilding(this._repository);

  final AdminRepository _repository;

  Future<Building> call({
    required String name,
  }) {
    return _repository.createBuilding(name: name);
  }
}