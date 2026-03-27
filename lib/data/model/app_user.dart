class AppUser {
  final String email;
  final String password;
  final bool isAdmin;

  const AppUser({
    required this.email,
    required this.password,
    required this.isAdmin,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      email: map['email'] as String,
      password: map['password'] as String,
      isAdmin: map['is_admin'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'is_admin': isAdmin,
    };
  }
}