import 'package:dartz/dartz.dart';
import 'package:neobazaar/core/error/failures.dart';

abstract interface class IWalletRepository {
  Future<Either<Failure, Map<String, dynamic>>> topup(
    Map<String, dynamic> payload,
  );

  Future<Either<Failure, Map<String, dynamic>>> topupViaUserAlias(
    Map<String, dynamic> payload,
  );
}
