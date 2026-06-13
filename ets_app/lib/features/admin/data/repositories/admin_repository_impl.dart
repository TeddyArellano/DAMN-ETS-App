import '../../../ets/domain/entities/ets.dart';
import '../../domain/entities/admin_dashboard.dart';
import '../../domain/entities/building.dart';
import '../../domain/entities/career.dart';
import '../../domain/entities/subject.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  const AdminRepositoryImpl(this._remoteDataSource);

  final AdminRemoteDataSource _remoteDataSource;

  @override
  Future<AdminDashboard> getDashboard() {
    return _remoteDataSource.getDashboard();
  }

  @override
  Future<List<Career>> getCareers() {
    return _remoteDataSource.getCareers();
  }

  @override
  Future<Career> createCareer({
    required String code,
    required String name,
    required List<String> plans,
  }) {
    return _remoteDataSource.createCareer(
      code: code,
      name: name,
      plans: plans,
    );
  }

  @override
  Future<void> deleteCareer(int id) {
    return _remoteDataSource.deleteCareer(id);
  }

  @override
  Future<List<Building>> getBuildings() {
    return _remoteDataSource.getBuildings();
  }

  @override
  Future<Building> createBuilding({
    required String name,
  }) {
    return _remoteDataSource.createBuilding(name: name);
  }

  @override
  Future<void> deleteBuilding(int id) {
    return _remoteDataSource.deleteBuilding(id);
  }

  @override
  Future<List<Ets>> getAdminEts() {
    return _remoteDataSource.getAdminEts();
  }

  @override
  Future<Ets> createEts({
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
    return _remoteDataSource.createEts(
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

  @override
  Future<Ets> updateEts({
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
    return _remoteDataSource.updateEts(
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

  @override
  Future<void> deleteEts(int id) {
    return _remoteDataSource.deleteEts(id);
  }

  @override
  Future<List<Subject>> getSubjects({
    int? careerId,
    String? plan,
    int? semestre,
  }) {
    return _remoteDataSource.getSubjects(
      careerId: careerId,
      plan: plan,
      semestre: semestre,
    );
  }
}