import '../../domain/entities/subject.dart';

class SubjectModel extends Subject {
  const SubjectModel({
    required super.id,
    required super.name,
    required super.semestre,
    required super.plan,
    required super.careerId,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as int,
      name: json['name'] as String,
      semestre: json['semestre'] as int,
      plan: json['plan'] as String,
      careerId: json['careerId'] as int,
    );
  }
}