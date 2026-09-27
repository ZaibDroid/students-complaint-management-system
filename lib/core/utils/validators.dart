/// Form & Input Validators
class Validators {
  Validators._();

  /// Validates that an email ends with @uetmardan.edu.pk
  static String? validateUetEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final email = value.trim().toLowerCase();
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@uetmardan\.edu\.pk$');
    if (!emailRegex.hasMatch(email)) {
      return 'Only official @uetmardan.edu.pk emails are allowed';
    }
    return null;
  }

  /// Validates password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  /// Validates confirmation password
  static String? validateConfirmPassword(String? value, String originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Required field validator
  static String? validateRequired(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Registration number validator (e.g. 21MRCS01, 22MRSE15)
  static String? validateRegNo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Registration number is required';
    }
    final reg = value.trim().toUpperCase();
    if (reg.length < 5) {
      return 'Please enter a valid Registration Number';
    }
    return null;
  }
}
