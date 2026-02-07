class FormValidators {
  FormValidators._();

  static String? requiredField(String? value, {String fieldName = 'Field'}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? password(String? value, {int minLength = 8}) {
    final input = value ?? '';
    if (input.isEmpty) {
      return 'Password is required';
    }

    if (input.length < minLength) {
      return 'Password must be at least $minLength characters';
    }

    return null;
  }

  static String? minLength(
    String? value, {
    required int length,
    String fieldName = 'Field',
  }) {
    final input = value?.trim() ?? '';
    if (input.length < length) {
      return '$fieldName must be at least $length characters';
    }
    return null;
  }

  static String? phoneNp(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return null;
    }

    final phoneRegex = RegExp(r'^(\+977[- ]?)?(98|97)\d{8}$');
    if (!phoneRegex.hasMatch(input)) {
      return 'Please enter a valid Nepali phone number';
    }

    return null;
  }

  static String? compose(List<String? Function()> validators) {
    for (final validate in validators) {
      final result = validate();
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}
