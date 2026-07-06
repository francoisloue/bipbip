class NewEvent {
  final int? id;
  final int userId;
  final String name;
  final String description;
  final String frequency;
  final bool isActive;
  final int medicationId;
  final DateTime? takePillDate;

  NewEvent({
    this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.frequency,
    required this.isActive,
    required this.medicationId,
    required this.takePillDate,
  });

  factory NewEvent.fromJson(Map<String, dynamic> json) {
    return NewEvent(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      description: json['description'],
      frequency: json['frequency'],
      isActive: json['is_active'] ?? true,
      medicationId: json['medication_id'],
      takePillDate: json['take_pill_date']
          ? DateTime.tryParse(json['take_pill_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'frequency': frequency,
      'is_active': isActive,
      'medication_id': medicationId,
      'take_pill_date': takePillDate?.toIso8601String(),
    };
  }
}
