import 'package:flutter/material.dart';

const List<String> kStaffRoles = [
  'Vice Chancellor',
  'Dean',
  'Chairman',
  'Office Staff',
];

IconData getRoleIcon(String? role) {
  switch (role) {
    case 'Vice Chancellor':
      return Icons.account_balance;
    case 'Dean':
      return Icons.school;
    case 'Chairman':
      return Icons.person;
    case 'Office Staff':
      return Icons.desk;
    default:
      return Icons.person_outline;
  }
}

