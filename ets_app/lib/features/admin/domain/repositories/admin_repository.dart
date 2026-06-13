import '../../../ets/domain/entities/ets.dart';
import '../entities/admin_dashboard.dart';
import '../entities/building.dart';
import '../entities/career.dart';
import '../entities/subject.dart';

abstract class AdminRepository {
  Future<AdminDashboard> getDashboard();

  Future<List<Career>> getCareers();

  Future<List<Building>> getBuildings();

  Future<List<Subject>> getSubjects({
    int? careerId,
    String? plan,
    int? semestre,
  });

  Future<Career> createCareer({
    required String code,
    required String name,
    required List<String> plans,
  });

  Future<Building> createBuilding({
    required String name,
  });

  Future<List<Ets>> getAdminEts();

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
  });

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
  });

  Future<void> deleteEts(int id);

  Future<void> deleteCareer(int id);

  Future<void> deleteBuilding(int id);
}