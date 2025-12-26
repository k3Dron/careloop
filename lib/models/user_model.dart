class UserModel {
  final String name;
  final String email;
  final int age;
  final String role; // 'patient' or 'caregiver'
  final DateTime createdAt;

  UserModel({
    required this.name,
    required this.email,
    required this.age,
    required this.role,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'age': age,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] ?? 0,
      role: map['role'] ?? 'patient',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}