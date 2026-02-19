import 'dart:convert';

class ListingMediaLocalModel {
  final String id;
  final String originalPath;
  final String compressedPath;
  final int originalBytes;
  final int compressedBytes;
  final int width;
  final int height;
  final String mimeType;
  final DateTime createdAt;

  const ListingMediaLocalModel({
    required this.id,
    required this.originalPath,
    required this.compressedPath,
    required this.originalBytes,
    required this.compressedBytes,
    required this.width,
    required this.height,
    required this.mimeType,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'originalPath': originalPath,
      'compressedPath': compressedPath,
      'originalBytes': originalBytes,
      'compressedBytes': compressedBytes,
      'width': width,
      'height': height,
      'mimeType': mimeType,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ListingMediaLocalModel.fromJson(Map<String, dynamic> json) {
    return ListingMediaLocalModel(
      id: json['id']?.toString() ?? '',
      originalPath: json['originalPath']?.toString() ?? '',
      compressedPath: json['compressedPath']?.toString() ?? '',
      originalBytes: (json['originalBytes'] as num?)?.toInt() ?? 0,
      compressedBytes: (json['compressedBytes'] as num?)?.toInt() ?? 0,
      width: (json['width'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num?)?.toInt() ?? 0,
      mimeType: json['mimeType']?.toString() ?? 'image/jpeg',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  String toStorageValue() => jsonEncode(toJson());

  factory ListingMediaLocalModel.fromStorageValue(String value) {
    final json = jsonDecode(value) as Map<String, dynamic>;
    return ListingMediaLocalModel.fromJson(json);
  }
}
