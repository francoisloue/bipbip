class Medication {
  final int id;
  final String name;
  final String? description;

  Medication({
    required this.id,
    required this.name,
    this.description,
  });

  // Conversion d'un JSON vers un objet Dart
  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}
