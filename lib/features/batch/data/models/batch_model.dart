import '../../domain/entities/batch_entity.dart';

class BatchModel extends BatchEntity {
  const BatchModel({
    required super.id,
    required super.session,
    required super.degreeProgram,
    required super.adviserName,
    required super.adviserEmail,
    required super.adviserOffice,
    required super.sections,
    required super.totalStudents,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawSections = json['sections'] is List ? json['sections'] as List : ['Section A', 'Section B'];
    final sections = rawSections.map((e) => e.toString()).toList();

    return BatchModel(
      id: json['id']?.toString() ?? '',
      session: json['session'] ?? json['year'] ?? '2022-2026',
      degreeProgram: json['degree_program'] ?? json['program'] ?? 'BS Computer Science',
      adviserName: json['adviser_name'] ?? json['adviser']?['name'] ?? 'Dr. Adviser',
      adviserEmail: json['adviser_email'] ?? json['adviser']?['email'] ?? 'adviser@uetmardan.edu.pk',
      adviserOffice: json['adviser_office'] ?? json['office'] ?? 'CS Faculty Block, Room 204',
      sections: sections,
      totalStudents: json['total_students'] ?? json['students_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session': session,
      'degree_program': degreeProgram,
      'adviser_name': adviserName,
      'adviser_email': adviserEmail,
      'adviser_office': adviserOffice,
      'sections': sections,
      'total_students': totalStudents,
    };
  }
}
