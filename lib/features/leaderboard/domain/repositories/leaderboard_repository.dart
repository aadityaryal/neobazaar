import 'package:dartz/dartz.dart';
import 'package:neobazaar/core/error/failures.dart';

abstract interface class ILeaderboardRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> listLeaderboard({
    required String tab,
  });
}
