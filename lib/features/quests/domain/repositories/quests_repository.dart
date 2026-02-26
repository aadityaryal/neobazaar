import 'package:dartz/dartz.dart';
import 'package:neobazaar/core/error/failures.dart';

abstract interface class IQuestsRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> listQuests({
    Map<String, dynamic>? query,
  });

  Future<Either<Failure, Map<String, dynamic>>> createQuest(
    Map<String, dynamic> payload,
  );

  Future<Either<Failure, Map<String, dynamic>>> completeQuest(
    String questId,
    Map<String, dynamic> payload,
  );
}
