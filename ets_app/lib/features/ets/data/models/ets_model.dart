import '../../domain/entities/ets.dart';

class EtsModel extends Ets {
  const EtsModel({
    required super.id,
    required super.ua,
    required super.carrera,
    required super.carreraNombre,
    required super.careerId,
    required super.plan,
    required super.semestre,
    required super.fechaIso,
    required super.turno,
    required super.salon,
    required super.profesor,
    required super.correo,
    super.buildingId,
    super.edificio,
  });

  factory EtsModel.fromJson(Map<String, dynamic> json) {
    final careerValue = json['career'] ?? json['carrera'];
    final buildingValue = json['building'] ?? json['edificio'];

    final careerMap = careerValue is Map<String, dynamic>
        ? careerValue
        : careerValue is Map
            ? Map<String, dynamic>.from(careerValue)
            : null;

    final buildingMap = buildingValue is Map<String, dynamic>
        ? buildingValue
        : buildingValue is Map
            ? Map<String, dynamic>.from(buildingValue)
            : null;

    return EtsModel(
      id: _readInt(json['id']),
      ua: json['ua']?.toString() ?? '',
      carrera: careerMap?['code']?.toString() ??
          (careerValue is String ? careerValue : ''),
      carreraNombre: json['carreraNombre']?.toString() ??
          careerMap?['name']?.toString() ??
          '',
      careerId: _readInt(json['careerId'] ?? careerMap?['id']),
      plan: json['plan']?.toString() ?? '',
      semestre: _readInt(json['semestre']),
      fechaIso: json['fechaIso']?.toString() ?? '',
      turno: json['turno']?.toString() ?? '',
      salon: json['salon']?.toString() ?? '',
      profesor: json['profesor']?.toString() ?? '',
      correo: json['correo']?.toString() ?? '',
      buildingId: _readNullableInt(
        json['buildingId'] ?? buildingMap?['id'],
      ),
      edificio: buildingMap?['name']?.toString() ??
          (buildingValue is String ? buildingValue : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ua': ua,
      'carrera': carrera,
      'carreraNombre': carreraNombre,
      'careerId': careerId,
      'plan': plan,
      'semestre': semestre,
      'fechaIso': fechaIso,
      'turno': turno,
      'salon': salon,
      'profesor': profesor,
      'correo': correo,
      'buildingId': buildingId,
      'edificio': edificio,
    };
  }

  static int _readInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _readNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }
}