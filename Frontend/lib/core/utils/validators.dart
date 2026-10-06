class AppValidators {
  static String? requiredField(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? loginEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final email = value.trim().toLowerCase();
    if (!email.endsWith('@uetmardan.edu.pk')) {
      return 'Must be an @uetmardan.edu.pk email';
    }
    
    return null;
  }

  static String? universityEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    final email = value.trim().toLowerCase();
    if (!email.endsWith('@uetmardan.edu.pk')) {
      return 'Must be an @uetmardan.edu.pk email';
    }
    
    final localPart = email.split('@')[0];
    
    // Explicitly allow specific staff emails to bypass student format restriction
    final allowedStaff = ['admin', 'chairman', 'dean', 'coordinator', 'office'];
    if (allowedStaff.contains(localPart) || localPart.startsWith('adviser') || localPart.startsWith('batchadviser')) {
      return null;
    }
    
    // Student format: e.g. 23mdbcs495 (2 digits year + letters + digits reg num)
    final studentRegex = RegExp(r'^\d{2}[a-z]+\d+$');
    
    if (!studentRegex.hasMatch(localPart)) {
      return 'Invalid format. Use e.g., 23mdbcs495@uetmardan.edu.pk';
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
