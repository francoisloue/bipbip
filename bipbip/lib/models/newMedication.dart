class NewMedication {
  final String name;
  final String? imageUrl;
  final String? noticeUrl;

  NewMedication({
    required this.name,
    this.imageUrl,
    this.noticeUrl,
  });

  factory NewMedication.fromJson(Map<String, dynamic> json) {
    return NewMedication(
      name: json['name'] ?? '',
      imageUrl: json['image_url'],
      noticeUrl: json['notice_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'image_url': imageUrl,
      'notice_url': noticeUrl,
    };
  }
}
