class Medication {
  final int id;
  final String name;
  final String? imageUrl;
  final String? noticeUrl;

  Medication({
    required this.id,
    required this.name,
    this.imageUrl,
    this.noticeUrl,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['image_url'],
      noticeUrl: json['notice_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'notice_url': noticeUrl,
    };
  }
}
