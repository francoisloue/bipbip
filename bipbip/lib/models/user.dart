class User {
  final int id;
  final String username;
  final String? tokenJWT;

  User({
    required this.id,
    required this.username,
    required this.tokenJWT,
  });

  // Conversion d'un JSON vers un objet Dart
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['name'],
      tokenJWT: null
    );
  }
  
  set tokenJWT(String? token) {
    tokenJWT = token;
  }
}
