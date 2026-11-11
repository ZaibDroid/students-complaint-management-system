class BatchModel {
  final String id;
  final String name;
  final List<String> sections;

  BatchModel({
    required this.id,
    required this.name,
    required this.sections,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      sections: List<String>.from(json['sections'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sections': sections,
    };
  }
}
