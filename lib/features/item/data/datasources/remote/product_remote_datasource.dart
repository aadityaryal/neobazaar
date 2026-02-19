import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neobazaar/core/api/api_client.dart';
import 'package:neobazaar/core/api/api_endpoints.dart';
import 'package:neobazaar/features/item/data/datasources/product_datasource.dart';
import 'package:neobazaar/features/item/data/models/product_api_model.dart';
import 'package:neobazaar/features/item/data/models/product_list_query_model.dart';
import 'package:path/path.dart' as path_util;

final productRemoteDatasourceProvider = Provider<IProductRemoteDatasource>((
  ref,
) {
  return ProductRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

class ProductRemoteDatasource implements IProductRemoteDatasource {
  final ApiClient _apiClient;

  ProductRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<ProductApiModel>> getProducts(ProductListQueryModel query) async {
    final response = await _apiClient.get(
      ApiEndpoints.products,
      queryParameters: query.toQueryParameters(),
    );

    return _apiClient.parseDataEnvelope<List<ProductApiModel>>(response, (
      data,
    ) {
      final list = data is List ? data : <dynamic>[];
      return list
          .whereType<Map<String, dynamic>>()
          .map(ProductApiModel.fromJson)
          .toList();
    });
  }

  @override
  Future<ProductApiModel> getProductById(String productId) async {
    final response = await _apiClient.get(ApiEndpoints.productById(productId));

    return _apiClient.parseDataEnvelope<ProductApiModel>(
      response,
      (data) => ProductApiModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Map<String, dynamic>> getPublicProductPayload(String productId) async {
    final response = await _apiClient.get(
      ApiEndpoints.productPublicById(productId),
    );

    return _apiClient.parseDataEnvelope<Map<String, dynamic>>(
      response,
      (data) =>
          (data as Map).map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  @override
  Future<ProductApiModel> createProduct(Map<String, dynamic> payload) async {
    final normalizedPayload = Map<String, dynamic>.from(payload);
    final rawImages =
        (normalizedPayload['images'] as List?)
            ?.map((item) => item.toString())
            .where((item) => item.isNotEmpty)
            .toList() ??
        <String>[];

    if (rawImages.isNotEmpty) {
      final resolvedImages = <String>[];
      for (final image in rawImages) {
        resolvedImages.add(await _normalizeImageSource(image));
      }
      normalizedPayload['images'] = resolvedImages;
    }

    final response = await _apiClient.post(
      ApiEndpoints.products,
      data: normalizedPayload,
    );

    return _apiClient.parseDataEnvelope<ProductApiModel>(
      response,
      (data) => ProductApiModel.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<String> _normalizeImageSource(String imageSource) async {
    final normalized = imageSource.trim();
    if (normalized.isEmpty) {
      return normalized;
    }

    if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
      return normalized;
    }

    if (normalized.startsWith('/uploads/')) {
      return _absoluteBackendUrl(normalized);
    }

    if (normalized.startsWith('/') || normalized.startsWith('file://')) {
      return _uploadImageFromLocalPath(normalized);
    }

    return normalized;
  }

  Future<String> _uploadImageFromLocalPath(String localPath) async {
    final filePath = localPath.startsWith('file://')
        ? Uri.parse(localPath).toFilePath()
        : localPath;

    final file = File(filePath);
    if (!await file.exists()) {
      return localPath;
    }

    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        filePath,
        filename: path_util.basename(filePath),
      ),
    });

    final response = await _apiClient.uploadFile(
      ApiEndpoints.productImageUpload,
      formData: formData,
    );

    final uploaded = _apiClient.parseDataEnvelope<String>(response, (data) {
      final map = data as Map<String, dynamic>;
      final rawUrl = (map['url'] ?? map['path'] ?? '').toString();
      return rawUrl;
    });

    if (uploaded.startsWith('/')) {
      return _absoluteBackendUrl(uploaded);
    }

    return uploaded;
  }

  String _absoluteBackendUrl(String path) {
    final base = Uri.parse(ApiEndpoints.baseUrl);
    return '${base.scheme}://${base.authority}$path';
  }
}
