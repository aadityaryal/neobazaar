import 'package:neobazaar/features/item/data/models/product_api_model.dart';
import 'package:neobazaar/features/item/data/models/product_list_query_model.dart';

abstract interface class IProductRemoteDatasource {
  Future<List<ProductApiModel>> getProducts(ProductListQueryModel query);
  Future<ProductApiModel> getProductById(String productId);
  Future<Map<String, dynamic>> getPublicProductPayload(String productId);
  Future<ProductApiModel> createProduct(Map<String, dynamic> payload);
}
