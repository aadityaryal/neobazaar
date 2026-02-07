String serializeDateToBackend(DateTime value) {
  return value.toUtc().toIso8601String();
}

String? serializeNullableDateToBackend(DateTime? value) {
  if (value == null) {
    return null;
  }
  return serializeDateToBackend(value);
}

DateTime parseBackendDate(String value) {
  return DateTime.parse(value).toLocal();
}

DateTime? parseNullableBackendDate(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  return parseBackendDate(value);
}
