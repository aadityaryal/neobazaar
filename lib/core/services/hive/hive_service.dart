// import 'package:hive/hive.dart';
// import 'package:lost_n_found/features/auth/data/models/batch_hive_model.dart';
// import 'package:neobazaar/core/constants/hive_table_constant.dart';
// import 'package:path_provider/path_provider.dart';

// class HiveService {
//   // Initialize Hive
//   Future<void> init() async {
//     final directory = await getApplicationDocumentsDirectory();
//     final path = '${directory.path}/${HiveTableConstant.dbName}';
//     Hive.init(path);
//     _registerAdapters();
//     await _openBoxes();
//   }

//   // Register all type adapters 
//   void _registerAdapters() {
//     if (!Hive.isAdapterRegistered(HiveTableConstant.batchTypeId)) {
//       Hive.registerAdapter(BatchHiveModelAdapter());
//     }
//   }

//   // Open all boxes
//   Future<void> _openBoxes() async{
//     await Hive.openBox<BatchHiveModel>(HiveTableConstant.batchTable);
//   }

//   // Delete all batches
//   Future<void> deleteAllBatches() async {
//     await _batchBox.clear();
//   }

//   // Close all boxes
//   Future<void> close() async {
//     await Hive.close();
//   }

//   // ==================== Batch CRUD Operations ====================

//   // Get batch box
//   Box<BatchHiveModel> get _batchBox =>
//       Hive.box<BatchHiveModel>(HiveTableConstant.batchTable);

//   // Create a new batch
//   Future<BatchHiveModel> createBatch(BatchHiveModel batch) async {
//     await _batchBox.put(batch.batchId, batch);
//     return batch;
//   }

//   // Get all batches
//   List<BatchHiveModel> getAllBatches() {
//     return _batchBox.values.toList();
//   }

//   // Get batch by ID
//   BatchHiveModel? getBatchById(String batchId) {
//     return _batchBox.get(batchId);
//   }

//   // Update a batch
//   Future<void> updateBatch(BatchHiveModel batch) async {
//     await _batchBox.put(batch.batchId, batch);
//   }

//   // Delete a batch
//   Future<void> deleteBatch(String batchId) async {
//     await _batchBox.delete(batchId);
//   }

//   // ==================== Category CRUD Operations ====================
//   // Get category box
//   Box<BatchHiveModel> get _categoryBox =>
//       Hive.box<BatchHiveModel>(HiveTableConstant.categoryTable);
  
//   // Create a new Category
//   Future<BatchHiveModel> createCategory(BatchHiveModel category) async {
//     await _categoryBox.put(category.batchId, category);
//     return category;
//   }


  
// }