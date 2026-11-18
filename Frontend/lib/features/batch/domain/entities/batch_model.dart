class BatchSectionItem {
  final String id;
  final String name;
  final String? adviserId;
  final String? adviserName;

  BatchSectionItem({
    required this.id,
    required this.name,
    this.adviserId,
    this.adviserName,
  });

  factory BatchSectionItem.fromJson(Map<String, dynamic> json) {
    String? aId;
    String? aName;
    if (json['assigned_staff'] is List && (json['assigned_staff'] as List).isNotEmpty) {
      final staff = (json['assigned_staff'] as List).first as Map<String, dynamic>;
      aId = staff['id']?.toString();
      aName = staff['name']?.toString();
    }
    return BatchSectionItem(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      adviserId: aId,
      adviserName: aName,
    );
  }
}

class BatchModel {
  final String id;
  final String name;
  final List<String> sections;
  final List<BatchSectionItem> sectionItems;

  BatchModel({
    required this.id,
    required this.name,
    required this.sections,
    this.sectionItems = const [],
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    final rawSections = List<String>.from(json['sections'] ?? []);
    final items = <BatchSectionItem>[];
    if (json['section_details'] is List) {
      for (final s in (json['section_details'] as List)) {
        if (s is Map<String, dynamic>) {
          items.add(BatchSectionItem.fromJson(s));
        }
      }
    }
    return BatchModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      sections: rawSections,
      sectionItems: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sections': sections,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
