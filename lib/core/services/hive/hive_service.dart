import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:neobazaar/core/constants/hive_table_constant.dart';
import 'package:neobazaar/features/auth/data/models/auth_hive_model.dart';
import 'package:path_provider/path_provider.dart';

// Provider
final hiveServiceProvider = Provider<HiveService>((ref) {
  final hiveService = HiveService();
  return hiveService;
});

class HiveService {
  // Initialize Hive
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);
    _registerAdapters();
    await _openBoxes();
  }

  // Register all type adapters
  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  // Open all boxes
  Future<void> _openBoxes() async {
    // auth
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
  }

  // Delete all batches
  Future<void> deleteAllBatches() async {
    await _authBox.clear();
  }

  // Close all boxes
  Future<void> close() async {
    await Hive.close();
  }

  // =======================Auth Queries=============================
  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);

  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    await _authBox.put(model.authId, model);
    return model;
  }

  // login
  Future<AuthHiveModel?> login(String email, String password) async {
    final users = _authBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  // logout
  Future<void> logoutUser() async {}
  // get current user
  AuthHiveModel? getCurrentUser(String authId) {
    return _authBox.get(authId);
  }

  // check email exists
  bool isEmailExists(String email) {
    final users = _authBox.values.where((user) => user.email == email);
    return users.isNotEmpty;
  }

    AuthHiveModel? getUserByEmail(String email) {
    try {
      final users = _authBox.values.where(
        (user) => user.email == email,
      );
      return users.isNotEmpty ? users.first : null;
    } catch (e) {
      return null;
    }
  }

  // Check if email exists

}
