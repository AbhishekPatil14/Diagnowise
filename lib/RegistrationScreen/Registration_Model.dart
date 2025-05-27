class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String role;
  final String? adminCode;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.adminCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'adminCode': adminCode,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
      adminCode: map['adminCode'],
    );
  }
}
