class ErrorCategories {
  ErrorCategories._();

  static const String network = 'network';
  static const String auth = 'auth';
  static const String validation = 'validation';
  static const String forbidden = 'forbidden';
  static const String notFound = 'not_found';
  static const String conflict = 'conflict';
  static const String unknown = 'unknown';

  static const Set<String> values = <String>{
    network,
    auth,
    validation,
    forbidden,
    notFound,
    conflict,
    unknown,
  };
}
