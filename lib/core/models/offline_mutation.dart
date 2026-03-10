import 'dart:convert';

class OfflineMutation {
  final String id;
  final String idempotencyKey;
  final String method;
  final String path;
  final Map<String, dynamic> headers;
  final Map<String, dynamic> queryParameters;
  final dynamic body;
  final int attemptCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OfflineMutation({
    required this.id,
    required this.idempotencyKey,
    required this.method,
    required this.path,
    this.headers = const <String, dynamic>{},
    this.queryParameters = const <String, dynamic>{},
    this.body,
    this.attemptCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  OfflineMutation copyWith({int? attemptCount, DateTime? updatedAt}) {
    return OfflineMutation(
      id: id,
      idempotencyKey: idempotencyKey,
      method: method,
      path: path,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
      attemptCount: attemptCount ?? this.attemptCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'idempotencyKey': idempotencyKey,
      'method': method,
      'path': path,
      'headers': headers,
      'queryParameters': queryParameters,
      'body': body,
      'attemptCount': attemptCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory OfflineMutation.fromJson(Map<String, dynamic> json) {
    return OfflineMutation(
      id: json['id']?.toString() ?? '',
      idempotencyKey: json['idempotencyKey']?.toString() ?? '',
      method: json['method']?.toString() ?? 'POST',
      path: json['path']?.toString() ?? '/',
      headers:
          (json['headers'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value),
          ) ??
          <String, dynamic>{},
      queryParameters:
          (json['queryParameters'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value),
          ) ??
          <String, dynamic>{},
      body: json['body'],
      attemptCount: (json['attemptCount'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  String toStorageValue() => jsonEncode(toJson());

  factory OfflineMutation.fromStorageValue(String value) {
    final json = jsonDecode(value) as Map<String, dynamic>;
    return OfflineMutation.fromJson(json);
  }
}
