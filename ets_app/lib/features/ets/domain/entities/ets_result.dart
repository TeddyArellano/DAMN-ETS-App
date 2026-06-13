import 'ets.dart';

class EtsResult {
  const EtsResult({
    required this.items,
    required this.fromCache,
    this.lastUpdated,
  });

  final List<Ets> items;
  final bool fromCache;
  final DateTime? lastUpdated;

  EtsResult copyWith({
    List<Ets>? items,
    bool? fromCache,
    DateTime? lastUpdated,
  }) {
    return EtsResult(
      items: items ?? this.items,
      fromCache: fromCache ?? this.fromCache,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}