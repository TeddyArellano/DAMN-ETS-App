class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.boleta,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final String? boleta;

  bool get isAdmin => role.toUpperCase() == 'ADMIN';

  bool get isStudent => role.toUpperCase() == 'STUDENT';

  factory User.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final rawName = json['name'];
    final rawEmail = json['email'];
    final rawRole = json['role'];
    final rawBoleta = json['boleta'];

    return User(
      id: rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0,
      name: rawName?.toString() ?? '',
      email: rawEmail?.toString() ?? '',
      role: rawRole?.toString() ?? 'STUDENT',
      boleta: rawBoleta?.toString(),
    );
  }
}