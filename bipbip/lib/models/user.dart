class User {
  final String id;
  final String name;
  final String surname;
  final int age;
  final int weight;
  final int height;

  User({
    required this.id,
    required this.name,
    required this.surname,
    required this.age,
    required this.height,
    required this.weight
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      surname: json['surname'],
      age: json['age'],
      height: json['height'],
      weight: json['weight'],
    );
  }
}
