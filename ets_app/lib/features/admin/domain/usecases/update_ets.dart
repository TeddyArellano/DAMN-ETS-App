import '../../../ets/domain/entities/ets.dart';
import '../repositories/admin_repository.dart';

/// Caso de uso: modificar un ETS existente.
class UpdateEts {
  const UpdateEts(this._repository);

  final AdminRepository _repository;

  Future<Ets> call({
    required int id,
    required String ua,
    required int subjectId,
    required int careerId,
    required String plan,
    required int semestre,
    required String fechaIso,
    required String turno,
    required String salon,
    required String profesor,
    required String correo,
    required int buildingId,
  }) {
    return _repository.updateEts(
      id: id,
      ua: ua,
      subjectId: subjectId,
      careerId: careerId,
      plan: plan,
      semestre: semestre,
      fechaIso: fechaIso,
      turno: turno,
      salon: salon,
      profesor: profesor,
      correo: correo,
      buildingId: buildingId,
    );
  }
}
