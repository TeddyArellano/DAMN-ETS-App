import '../../domain/entities/admin_dashboard.dart';

class AdminDashboardModel extends AdminDashboard {
  const AdminDashboardModel({
    required super.totalEts,
    required super.totalCareers,
    required super.totalBuildings,
    required super.totalUsers,
    required super.examsByCareer,
  });

  factory AdminDashboardModel.fromJson(Map<String, dynamic> json) {
    final careersJson = json['examsByCareer'];

    return AdminDashboardModel(
      totalEts: _readInt(json['totalEts']),
      totalCareers: _readInt(json['totalCareers']),
      totalBuildings: _readInt(json['totalBuildings']),
      totalUsers: _readInt(json['totalUsers']),
      examsByCareer: careersJson is List
          ? careersJson
              .whereType<Map<String, dynamic>>()
              .map(EtsByCareerModel.fromJson)
              .toList()
          : const [],
    );
  }

  static int _readInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString()) ?? 0;
  }
}

class EtsByCareerModel extends EtsByCareer {
  const EtsByCareerModel({
    required super.careerId,
    required super.careerCode,
    required super.careerName,
    required super.totalEts,
  });

  factory EtsByCareerModel.fromJson(Map<String, dynamic> json) {
    return EtsByCareerModel(
      careerId: AdminDashboardModel._readInt(json['careerId']),
      careerCode: json['careerCode']?.toString() ?? '',
      careerName: json['careerName']?.toString() ?? '',
      totalEts: AdminDashboardModel._readInt(json['totalEts']),
    );
  }
}