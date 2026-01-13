class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - change this for production
  static const String baseUrl = 'http://127.0.0.1:5050/api';
  //static const String baseUrl = 'http://10.0.2.2:5050/api'; // Android Studio Emulator only
  //static const String baseUrl = 'http://localhost:5050/api';
  // For Android Studio Emulator: 'http://10.0.2.2:5050/api'
  // For LDPlayer/BlueStacks: Use your PC's IP 'http://192.168.42.133:5050/api'
  // For iOS Simulator use: 'http://localhost:5050/api'

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ Batch Endpoints ============
  static const String batches = '/batches';
  static String batchById(String id) => '/batches/$id';

  // ============ Category Endpoints ============
  static const String categories = '/categories';
  static String categoryById(String id) => '/categories/$id';

  // ============ Auth Endpoints ============
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';

  // ============ Item Endpoints ============
  static const String items = '/items';
  static String itemById(String id) => '/items/$id';
  static String itemClaim(String id) => '/items/$id/claim';

  // ============ Comment Endpoints ============
  static const String comments = '/comments';
  static String commentById(String id) => '/comments/$id';
  static String commentsByItem(String itemId) => '/comments/item/$itemId';
  static String commentLike(String id) => '/comments/$id/like';
}
