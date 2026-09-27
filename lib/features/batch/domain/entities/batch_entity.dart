import 'package:equatable/equatable.dart';

class BatchEntity extends Equatable {
  final String id;
  final String session; // e.g. 2022-2026
  final String degreeProgram; // e.g. BS Computer Science
  final String adviserName;
  final String adviserEmail;
  final String adviserOffice;
  final List<String> sections;
  final int totalStudents;

  const BatchEntity({
    required this.id,
    required this.session,
    required this.degreeProgram,
    required this.adviserName,
    required this.adviserEmail,
    required this.adviserOffice,
    required this.sections,
    required this.totalStudents,
  });

  @override
  List<Object?> get props => [id, session, degreeProgram, adviserName, adviserEmail, adviserOffice, sections, totalStudents];
}

class AdviserRequestEntity extends Equatable {
  final String id;
  final String studentName;
  final String regNo;
  final String batch;
  final String section;
  final String reason;
  final String status; // pending, approved, rejected
  final DateTime createdAt;

  const AdviserRequestEntity({
    required this.id,
    required this.studentName,
    required this.regNo,
    required this.batch,
    required this.section,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, studentName, regNo, batch, section, reason, status, createdAt];
}
