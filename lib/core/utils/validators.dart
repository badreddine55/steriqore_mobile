class Validators {
  Validators._();

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validateCabinetCode(String? value) {
    if (value == null || value.trim().length < 4) {
      return 'Cabinet code must be at least 4 characters';
    }
    return null;
  }

  static String? validatePasswordStrength(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
    final hasDigit = RegExp(r'[0-9]').hasMatch(value);
    if (!hasUppercase || !hasDigit) {
      return 'Must include at least 1 uppercase letter and 1 number';
    }
    return null;
  }

  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateLabelCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Label code is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 3) {
      return 'Code is too short (min 3 chars)';
    }
    if (trimmed.length > 60) {
      return 'Code is too long (max 60 chars)';
    }
    return null;
  }
}
