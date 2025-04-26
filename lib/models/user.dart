class User {
  final int? id;
  final String email;
  final String name;
  final String password;

  const User({
    this.id,
    required this.email,
    required this.name,
    required this.password,
  });

  Map<String, Object?> toMap() => {
    "id": id,
    "name": name,
    "email": email,
    "password": password
  };

  @override
  String toString() => "User(id: $id, name: $name, email: $email)";
} 