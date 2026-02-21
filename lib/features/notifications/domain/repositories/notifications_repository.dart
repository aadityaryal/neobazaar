import 'package:dartz/dartz.dart';
import 'package:neobazaar/core/error/failures.dart';

abstract interface class INotificationsRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> listNotifications({
    Map<String, dynamic>? query,
  });

  Future<Either<Failure, Map<String, dynamic>>> createNotification(
    Map<String, dynamic> payload,
  );

  Future<Either<Failure, Map<String, dynamic>>> markNotificationRead(
    String notificationId,
    Map<String, dynamic> payload,
  );
}
