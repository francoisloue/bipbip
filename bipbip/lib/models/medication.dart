class Composition {
  final String denominationSubstance;
  final String dosage;

  Composition({
    required this.denominationSubstance,
    required this.dosage,
  });

  factory Composition.fromJson(Map<String, dynamic> json) {
    return Composition(
      denominationSubstance: json['denominationSubstance'] ?? '',
      dosage: json['dosage'] ?? '',
    );
  }
}

class Medication {
  final int id;
  final String name;
  final String? imageUrl;
  final String? noticeUrl;
  final String formePharmaceutique;
  final List<Composition> composition;

  Medication({
    required this.id,
    required this.name,
    this.imageUrl,
    this.noticeUrl,
    required this.formePharmaceutique,
    this.composition = const [],
  });

  String get dosageSummary {
    if (composition.isEmpty) return '';
    return composition.map((c) => '${c.denominationSubstance} ${c.dosage}').join(' + ');
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    final compositionList = (json['composition'] as List<dynamic>?)
            ?.map((c) => Composition.fromJson(c as Map<String, dynamic>))
            .toList() ??
        [];
    return Medication(
      id: json['cis'] ?? 0,
      name: json['elementPharmaceutique'] ?? '',
      imageUrl: json['image_url'],
      noticeUrl: json['notice_url'],
      formePharmaceutique: json['formePharmaceutique'] ?? '',
      composition: compositionList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cis': id,
      'elementPharmaceutique': name,
      'image_url': imageUrl,
      'notice_url': noticeUrl,
      'formePharmaceutique': formePharmaceutique,
      'composition': composition.map((c) => {
        'denominationSubstance': c.denominationSubstance,
        'dosage': c.dosage,
      }).toList(),
    };
  }
}
