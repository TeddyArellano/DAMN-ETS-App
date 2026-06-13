class Career {
  const Career({
    required this.id,
    required this.code,
    required this.name,
    required this.plans,
  });

  final int id;
  final String code;
  final String name;
  final List<String> plans;
}