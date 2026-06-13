import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../data/datasources/ets_local_ds.dart';
import '../data/datasources/ets_remote_ds.dart';
import '../data/repositories/ets_repository_impl.dart';
import '../domain/entities/ets.dart';
import '../domain/entities/ets_result.dart';
import '../domain/repositories/ets_repository.dart';
import '../domain/usecases/get_ets.dart';

final etsRemoteDataSourceProvider = Provider<EtsRemoteDataSource>((ref) {
  return EtsRemoteDataSource(ref.watch(dioProvider));
});

final etsLocalDataSourceProvider = Provider<EtsLocalDataSource>((ref) {
  return EtsLocalDataSource();
});

final etsRepositoryProvider = Provider<EtsRepository>((ref) {
  return EtsRepositoryImpl(
    ref.watch(etsRemoteDataSourceProvider),
    ref.watch(etsLocalDataSourceProvider),
  );
});

final getEtsUseCaseProvider = Provider<GetEts>((ref) {
  return GetEts(ref.watch(etsRepositoryProvider));
});

final etsListProvider =
    AsyncNotifierProvider<EtsListController, EtsResult>(EtsListController.new);

class EtsListController extends AsyncNotifier<EtsResult> {
  @override
  Future<EtsResult> build() {
    return ref.read(getEtsUseCaseProvider).call();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
      () => ref.read(getEtsUseCaseProvider).call(),
    );
  }
}

class EtsFilters {
  const EtsFilters({
    this.query = '',
    this.carrera,
    this.plan,
    this.semestre,
  });

  final String query;
  final String? carrera;
  final String? plan;
  final int? semestre;

  EtsFilters copyWith({
    String? query,
    String? carrera,
    String? plan,
    int? semestre,
    bool clearCarrera = false,
    bool clearPlan = false,
    bool clearSemestre = false,
  }) {
    return EtsFilters(
      query: query ?? this.query,
      carrera: clearCarrera ? null : carrera ?? this.carrera,
      plan: clearPlan ? null : plan ?? this.plan,
      semestre: clearSemestre ? null : semestre ?? this.semestre,
    );
  }
}

final etsFiltersProvider =
    NotifierProvider<EtsFiltersController, EtsFilters>(EtsFiltersController.new);

class EtsFiltersController extends Notifier<EtsFilters> {
  @override
  EtsFilters build() {
    return const EtsFilters();
  }

  void updateQuery(String value) {
    state = state.copyWith(query: value);
  }

  void updateCarrera(String? value) {
    state = value == null
        ? state.copyWith(
            clearCarrera: true,
            clearPlan: true,
            clearSemestre: true,
          )
        : state.copyWith(
            carrera: value,
            clearPlan: true,
            clearSemestre: true,
          );
  }

  void updatePlan(String? value) {
    state = value == null
        ? state.copyWith(clearPlan: true)
        : state.copyWith(plan: value);
  }

  void updateSemestre(int? value) {
    state = value == null
        ? state.copyWith(clearSemestre: true)
        : state.copyWith(semestre: value);
  }

  void clear() {
    state = const EtsFilters();
  }
}

final filteredEtsProvider = Provider<AsyncValue<EtsResult>>((ref) {
  final result = ref.watch(etsListProvider);
  final filters = ref.watch(etsFiltersProvider);

  return result.whenData((data) {
    final normalizedQuery = filters.query.trim().toLowerCase();

    final filteredItems = data.items.where((exam) {
      final matchesQuery = normalizedQuery.isEmpty ||
          exam.ua.toLowerCase().contains(normalizedQuery) ||
          exam.profesor.toLowerCase().contains(normalizedQuery) ||
          exam.salon.toLowerCase().contains(normalizedQuery) ||
          exam.carreraNombre.toLowerCase().contains(normalizedQuery);

      final matchesCarrera =
          filters.carrera == null || exam.carrera == filters.carrera;

      final matchesPlan = filters.plan == null || exam.plan == filters.plan;

      final matchesSemestre =
          filters.semestre == null || exam.semestre == filters.semestre;

      return matchesQuery &&
          matchesCarrera &&
          matchesPlan &&
          matchesSemestre;
    }).toList();

    return data.copyWith(items: filteredItems);
  });
});

List<String> getCarreras(List<Ets> items) {
  final values = items.map((item) => item.carrera).toSet().toList()..sort();
  return values;
}

List<String> getPlanes(List<Ets> items) {
  final values = items.map((item) => item.plan).toSet().toList()..sort();
  return values;
}

List<int> getSemestres(List<Ets> items) {
  final values = items.map((item) => item.semestre).toSet().toList()..sort();
  return values;
}