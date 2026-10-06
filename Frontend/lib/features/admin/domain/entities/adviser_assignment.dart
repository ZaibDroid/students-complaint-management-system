class AdviserAssignment {
  final String semester;
  final String section;
  final String? adviserId;
  final String? adviserName;

  AdviserAssignment({
    required this.semester,
    required this.section,
    this.adviserId,
    this.adviserName,
  });
}
