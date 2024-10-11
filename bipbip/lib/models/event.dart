import 'package:bipbip/models/medication.dart';

class Event {
  final int id;
  final String name;
  final String description;
  final int author;
  final DateTime? creationDate;
  final DateTime? takePillDate;
  final int medicationId;
  Medication? medication;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.author,
    required this.creationDate,
    required this.takePillDate,
    required this.medicationId,
    this.medication, 
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      author: json['author'],
      creationDate: json['creation_date'] != null ? DateTime.parse(json['creation_date']) : null,
      takePillDate: json['take_pill_date'] != null ? DateTime.parse(json['take_pill_date']) : null,
      medicationId: json['medication'],
      medication: null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'author': author,
      'creationDate': creationDate?.toIso8601String(),
      'takePillDate': takePillDate?.toIso8601String(),
      'medication': medication?.id
    };
  }
}
