import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/auth_providers.dart';
import '../../../ets/domain/entities/ets.dart';
import '../../../ets/presentation/ets_providers.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/entities/admin_dashboard.dart';
import '../../domain/entities/building.dart';
import '../../domain/entities/career.dart';
import '../../domain/entities/subject.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../domain/usecases/create_building.dart';
import '../../domain/usecases/create_career.dart';
import '../../domain/usecases/get_admin_dashboard.dart';
import '../../domain/usecases/get_buildings.dart';
import '../../domain/usecases/get_careers.dart';

final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource>((ref) {
  return AdminRemoteDataSource(ref.watch(dioProvider));
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepositoryImpl(
    ref.watch(adminRemoteDataSourceProvider),
  );
});

final getAdminDashboardUseCaseProvider = Provider<GetAdminDashboard>((ref) {
  return GetAdminDashboard(ref.watch(adminRepositoryProvider));
});

final getCareersUseCaseProvider = Provider<GetCareers>((ref) {
  return GetCareers(ref.watch(adminRepositoryProvider));
});

final createCareerUseCaseProvider = Provider<CreateCareer>((ref) {
  return CreateCareer(ref.watch(adminRepositoryProvider));
});

final getBuildingsUseCaseProvider = Provider<GetBuildings>((ref) {
  return GetBuildings(ref.watch(adminRepositoryProvider));
});

final createBuildingUseCaseProvider = Provider<CreateBuilding>((ref) {
  return CreateBuilding(ref.watch(adminRepositoryProvider));
});

final adminDashboardProvider =
    AsyncNotifierProvider<AdminDashboardController, AdminDashboard>(
  AdminDashboardController.new,
);

class AdminDashboardController extends AsyncNotifier<AdminDashboard> {
  @override
  Future<AdminDashboard> build() {
    return ref.read(getAdminDashboardUseCaseProvider).call();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref.read(getAdminDashboardUseCaseProvider).call(),
    );
  }
}

final adminCareersProvider =
    AsyncNotifierProvider<AdminCareersController, List<Career>>(
  AdminCareersController.new,
);

class AdminCareersController extends AsyncNotifier<List<Career>> {
  @override
  Future<List<Career>> build() {
    return ref.read(getCareersUseCaseProvider).call();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref.read(getCareersUseCaseProvider).call(),
    );
  }

  Future<Career> createCareer({
    required String code,
    required String name,
    required List<String> plans,
  }) async {
    final created = await ref.read(createCareerUseCaseProvider).call(
          code: code,
          name: name,
          plans: plans,
        );

    final updatedItems = <Career>[
      ...state.value ?? const <Career>[],
      created,
    ]..sort((first, second) => first.code.compareTo(second.code));

    state = AsyncData(updatedItems);

    ref.invalidate(adminDashboardProvider);
    ref.invalidate(etsListProvider);

    return created;
  }

  Future<void> deleteCareer(int id) async {
    await ref.read(adminRepositoryProvider).deleteCareer(id);

    final updatedItems = (state.value ?? const <Career>[])
        .where((item) => item.id != id)
        .toList();

    state = AsyncData(updatedItems);

    ref.invalidate(adminDashboardProvider);
    ref.invalidate(adminEtsProvider);
    ref.invalidate(etsListProvider);
  }
}

final adminBuildingsProvider =
    AsyncNotifierProvider<AdminBuildingsController, List<Building>>(
  AdminBuildingsController.new,
);

class AdminBuildingsController extends AsyncNotifier<List<Building>> {
  @override
  Future<List<Building>> build() {
    return ref.read(getBuildingsUseCaseProvider).call();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref.read(getBuildingsUseCaseProvider).call(),
    );
  }

  Future<Building> createBuilding({
    required String name,
  }) async {
    final created = await ref.read(createBuildingUseCaseProvider).call(
          name: name,
        );

    final updatedItems = <Building>[
      ...state.value ?? const <Building>[],
      created,
    ]..sort((first, second) => first.name.compareTo(second.name));

    state = AsyncData(updatedItems);

    ref.invalidate(adminDashboardProvider);
    ref.invalidate(etsListProvider);

    return created;
  }

  Future<void> deleteBuilding(int id) async {
    await ref.read(adminRepositoryProvider).deleteBuilding(id);

    final updatedItems = (state.value ?? const <Building>[])
        .where((item) => item.id != id)
        .toList();

    state = AsyncData(updatedItems);

    ref.invalidate(adminDashboardProvider);
    ref.invalidate(adminEtsProvider);
    ref.invalidate(etsListProvider);
  }
}

final adminEtsProvider =
    AsyncNotifierProvider<AdminEtsController, List<Ets>>(
  AdminEtsController.new,
);

class AdminEtsController extends AsyncNotifier<List<Ets>> {
  AdminRepository get _repository => ref.read(adminRepositoryProvider);

  @override
  Future<List<Ets>> build() {
    return _repository.getAdminEts();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return _repository.getAdminEts();
    });
  }

  Future<void> createEts({
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
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repository.createEts(
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

      return _repository.getAdminEts();
    });

    _invalidateRelatedData();
  }

  Future<void> updateEts({
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
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repository.updateEts(
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

      return _repository.getAdminEts();
    });

    _invalidateRelatedData();
  }

  Future<void> deleteEts(int id) async {
    await _repository.deleteEts(id);

    final updatedItems = (state.value ?? const <Ets>[])
        .where((item) => item.id != id)
        .toList();

    state = AsyncData(updatedItems);

    _invalidateRelatedData();
  }

  void _invalidateRelatedData() {
    ref.invalidate(adminDashboardProvider);
    ref.invalidate(etsListProvider);
  }
}

final adminSubjectsProvider =
    AsyncNotifierProvider<AdminSubjectsController, List<Subject>>(
  AdminSubjectsController.new,
);

class AdminSubjectsController extends AsyncNotifier<List<Subject>> {
  AdminRepository get _repository => ref.read(adminRepositoryProvider);

  @override
  Future<List<Subject>> build() {
    return _repository.getSubjects();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() {
      return _repository.getSubjects();
    });
  }
}

