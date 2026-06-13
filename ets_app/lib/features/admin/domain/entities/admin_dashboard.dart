class AdminDashboard {
  const AdminDashboard({
    required this.totalEts,
    required this.totalCareers,
    required this.totalBuildings,
    required this.totalUsers,
    required this.examsByCareer,
  });

  final int totalEts;
  final int totalCareers;
  final int totalBuildings;
  final int totalUsers;
  final List<EtsByCareer> examsByCareer;
}

class EtsByCareer {
  const EtsByCareer({
    required this.careerId,
    required this.careerCode,
    required this.careerName,
    required this.totalEts,
  });

  final int careerId;
  final String careerCode;
  final String careerName;
  final int totalEts;
}