class Ets {
  const Ets({
    required this.id,
    required this.ua,
    required this.carrera,
    required this.carreraNombre,
    required this.careerId,
    required this.plan,
    required this.semestre,
    required this.fechaIso,
    required this.turno,
    required this.salon,
    required this.profesor,
    required this.correo,
    this.buildingId,
    this.edificio,
  });

  final int id;
  final String ua;
  final String carrera;
  final String carreraNombre;
  final int careerId;
  final String plan;
  final int semestre;
  final String fechaIso;
  final String turno;
  final String salon;
  final String profesor;
  final String correo;
  final int? buildingId;
  final String? edificio;

  DateTime get fecha => DateTime.parse(fechaIso);
}