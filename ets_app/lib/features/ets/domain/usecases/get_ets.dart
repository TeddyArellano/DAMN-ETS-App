import '../entities/ets_result.dart';
import '../repositories/ets_repository.dart';

class GetEts {
  const GetEts(this._repository);

  final EtsRepository _repository;

  Future<EtsResult> call() {
    return _repository.getEts();
  }
}