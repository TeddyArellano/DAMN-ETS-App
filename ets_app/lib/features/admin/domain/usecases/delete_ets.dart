import '../repositories/admin_repository.dart';

/// Caso de uso: dar de baja un ETS de la oferta administrativa.
class DeleteEts {
  const DeleteEts(this._repository);

  final AdminRepository _repository;

  Future<void> call(int id) {
    return _repository.deleteEts(id);
  }
}
