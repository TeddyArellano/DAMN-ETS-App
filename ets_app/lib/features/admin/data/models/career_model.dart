import '../../domain/entities/career.dart';

class CareerModel extends Career {
  const CareerModel({
    required super.id,
    required super.code,
    required super.name,
    required super.plans,
  });

  factory CareerModel.fromJson(Map<String, dynamic> json) {
    final plansJson = json['plans'];

    return CareerModel(
      id: (json['id'] as num).toInt(),
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      plans: plansJson is List
          ? plansJson.map((item) => item.toString()).toList()
          : const [],
    );
  }
}