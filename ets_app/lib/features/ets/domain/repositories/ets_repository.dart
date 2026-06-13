import '../entities/ets_result.dart';

abstract class EtsRepository {
  Future<EtsResult> getEts();
}