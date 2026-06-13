import '../../../../core/network/api_exceptions.dart';
import '../../domain/entities/ets_result.dart';
import '../../domain/repositories/ets_repository.dart';
import '../datasources/ets_local_ds.dart';
import '../datasources/ets_remote_ds.dart';

class EtsRepositoryImpl implements EtsRepository {
  const EtsRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  final EtsRemoteDataSource _remoteDataSource;
  final EtsLocalDataSource _localDataSource;

  @override
  Future<EtsResult> getEts() async {
    try {
      final items = await _remoteDataSource.getEts();

      await _localDataSource.saveEts(items);

      return EtsResult(
        items: items,
        fromCache: false,
        lastUpdated: DateTime.now(),
      );
    } on ApiException {
      final cachedData = await _localDataSource.getCachedEts();

      if (cachedData == null) {
        rethrow;
      }

      return EtsResult(
        items: cachedData.items,
        fromCache: true,
        lastUpdated: cachedData.lastUpdated,
      );
    }
  }
}