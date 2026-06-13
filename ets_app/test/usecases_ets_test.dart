import 'package:ets_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:ets_app/features/admin/domain/usecases/create_ets.dart';
import 'package:ets_app/features/admin/domain/usecases/delete_ets.dart';
import 'package:ets_app/features/admin/domain/usecases/update_ets.dart';
import 'package:ets_app/features/ets/domain/entities/ets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake del repositorio admin: registra qué se llamó. Solo implementa los
/// métodos de ETS; el resto se resuelve por noSuchMethod (no se invoca aquí).
class _FakeAdminRepository implements AdminRepository {
  String? createdUa;
  int? updatedId;
  int? deletedId;

  Ets _sample(int id, String ua) => Ets(
        id: id,
        ua: ua,
        carrera: 'ISC',
        carreraNombre: 'Ingeniería en Sistemas Computacionales',
        careerId: 1,
        plan: '2020',
        semestre: 1,
        fechaIso: '2026-06-22T14:30:00.000Z',
        turno: 'Matutino',
        salon: '2204',
        profesor: 'X',
        correo: 'x@escom.ipn.mx',
      );

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
  }) async {
    createdUa = ua;
    return _sample(99, ua);
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
  }) async {
    updatedId = id;
    return _sample(id, ua);
  }

  @override
  Future<void> deleteEts(int id) async {
    deletedId = id;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeAdminRepository repo;

  setUp(() => repo = _FakeAdminRepository());

  test('CreateEts delega en el repositorio y devuelve el ETS creado', () async {
    final result = await CreateEts(repo).call(
      ua: 'Bases de Datos',
      subjectId: 1,
      careerId: 1,
      plan: '2020',
      semestre: 4,
      fechaIso: '2026-06-22T14:30:00.000Z',
      turno: 'Matutino',
      salon: '2204',
      profesor: 'Profe',
      correo: 'p@escom.ipn.mx',
      buildingId: 1,
    );

    expect(repo.createdUa, 'Bases de Datos');
    expect(result.ua, 'Bases de Datos');
  });

  test('UpdateEts delega con el id correcto', () async {
    await UpdateEts(repo).call(
      id: 42,
      ua: 'Redes',
      subjectId: 1,
      careerId: 1,
      plan: '2020',
      semestre: 5,
      fechaIso: '2026-06-22T14:30:00.000Z',
      turno: 'Vespertino',
      salon: '3302',
      profesor: 'Profe',
      correo: 'p@escom.ipn.mx',
      buildingId: 2,
    );

    expect(repo.updatedId, 42);
  });

  test('DeleteEts delega con el id correcto', () async {
    await DeleteEts(repo).call(7);
    expect(repo.deletedId, 7);
  });
}
