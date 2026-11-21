class DepartmentInfo {
  final String id;
  final String code;
  final String name;

  const DepartmentInfo({
    required this.id,
    required this.code,
    required this.name,
  });
}

const List<DepartmentInfo> kOfficialDepartments = [
  DepartmentInfo(id: '1', code: 'CS', name: 'Department of Computer Science'),
  DepartmentInfo(id: '3', code: 'NS', name: 'Department of Natural Sciences'),
  DepartmentInfo(id: '4', code: 'CAI', name: 'Department of Center of AI'),
  DepartmentInfo(id: '5', code: 'CIV', name: 'Department of Civil Engineering'),
  DepartmentInfo(id: '6', code: 'EE', name: 'Department of Electrical Engineering'),
  DepartmentInfo(id: '7', code: 'ME', name: 'Department of Mechanical Engineering'),
  DepartmentInfo(id: '8', code: 'SE', name: 'Department of Software Engineering'),
  DepartmentInfo(id: '9', code: 'TE', name: 'Department of Telecommunication Engineering'),
];

