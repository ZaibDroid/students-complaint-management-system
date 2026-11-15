import 'package:flutter/services.dart';

class StudentEmailInputFormatter extends TextInputFormatter {
  final bool isStudentOnly;

  const StudentEmailInputFormatter({this.isStudentOnly = false});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    // Disallow whitespace in email
    if (text.contains(' ')) {
      final noSpaces = text.replaceAll(' ', '');
      final offset = (newValue.selection.baseOffset - (text.length - noSpaces.length)).clamp(0, noSpaces.length);
      return TextEditingValue(
        text: noSpaces,
        selection: TextSelection.collapsed(offset: offset),
      );
    }

    String formatted;
    if (text.contains('@')) {
      final atIndex = text.indexOf('@');
      final local = text.substring(0, atIndex);
      final domain = text.substring(atIndex + 1).toLowerCase();

      // If student format (starts with 2 digits) or if isStudentOnly
      if (isStudentOnly || RegExp(r'^\d{2}').hasMatch(local)) {
        formatted = '${local.toUpperCase()}@$domain';
      } else {
        formatted = '$local@$domain';
      }
    } else {
      // No '@' symbol yet
      if (isStudentOnly || RegExp(r'^\d{2}').hasMatch(text)) {
        formatted = text.toUpperCase();
      } else {
        formatted = text;
      }
    }

    if (formatted == text) {
      return newValue;
    }

    return TextEditingValue(
      text: formatted,
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}

class AppValidators {
  static String? requiredField(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Normalizes student emails: capital local prefix (e.g. 00MDBCS000) and lowercase domain (uetmardan.edu.pk)
  static String formatEmail(String email) {
    final trimmed = email.trim();
    if (!trimmed.contains('@')) {
      if (RegExp(r'^\d{2}').hasMatch(trimmed)) {
        return trimmed.toUpperCase();
      }
      return trimmed;
    }
    final atIndex = trimmed.indexOf('@');
    final local = trimmed.substring(0, atIndex);
    final domain = trimmed.substring(atIndex + 1).toLowerCase();

    if (RegExp(r'^\d{2}').hasMatch(local)) {
      return '${local.toUpperCase()}@$domain';
    }
    return '$local@$domain';
  }

  static String? loginEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final raw = value.trim();
    if (!raw.toLowerCase().endsWith('@uetmardan.edu.pk')) {
      return 'Must be an @uetmardan.edu.pk email';
    }

    final parts = raw.split('@');
    final localPart = parts[0];
    final domainPart = parts.length > 1 ? parts.sublist(1).join('@') : '';

    if (domainPart != 'uetmardan.edu.pk') {
      return 'Domain must be lowercase: @uetmardan.edu.pk';
    }

    // If it's a student email (starts with 2 digits followed by letters and digits)
    if (RegExp(r'^\d{2}[a-zA-Z]+\d+$').hasMatch(localPart)) {
      if (!RegExp(r'^\d{2}[A-Z]+\d+$').hasMatch(localPart)) {
        return 'Student ID must be capitalized (e.g., 00MDBCS000@uetmardan.edu.pk)';
      }
    }
    
    return null;
  }

  static String? universityEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final raw = value.trim();
    if (!raw.toLowerCase().endsWith('@uetmardan.edu.pk')) {
      return 'Must be an @uetmardan.edu.pk email';
    }
    
    final parts = raw.split('@');
    final localPart = parts[0];
    final domainPart = parts.length > 1 ? parts.sublist(1).join('@') : '';

    if (domainPart != 'uetmardan.edu.pk') {
      return 'Domain must be lowercase: @uetmardan.edu.pk';
    }
    
    // Explicitly allow specific staff emails to bypass student format restriction
    final allowedStaff = ['admin', 'chairman', 'dean', 'coordinator', 'office'];
    if (allowedStaff.contains(localPart.toLowerCase()) || 
        localPart.toLowerCase().startsWith('adviser') || 
        localPart.toLowerCase().startsWith('batchadviser')) {
      return null;
    }
    
    // Student format: e.g. 00MDBCS000 (2 digits year + CAPITAL letters + digits reg num)
    final studentRegex = RegExp(r'^\d{2}[A-Z]+\d+$');
    
    if (!studentRegex.hasMatch(localPart)) {
      return 'Registration must be capital (e.g., 00MDBCS000@uetmardan.edu.pk)';
    }
    
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
