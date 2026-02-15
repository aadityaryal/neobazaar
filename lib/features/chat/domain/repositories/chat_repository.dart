import 'package:dartz/dartz.dart';
import 'package:neobazaar/core/error/failures.dart';

abstract interface class IChatRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> replay({
    Map<String, dynamic>? query,
  });

  Future<Either<Failure, Map<String, dynamic>>> createChat(
    Map<String, dynamic> payload,
  );

  Future<Either<Failure, List<Map<String, dynamic>>>> getMessages(
    String chatId, {
    Map<String, dynamic>? query,
  });

  Future<Either<Failure, Map<String, dynamic>>> createMessage(
    String chatId,
    Map<String, dynamic> payload,
  );

  Future<Either<Failure, Map<String, dynamic>>> markMessageRead(
    String chatId,
    String messageId,
    Map<String, dynamic> payload,
  );

  Future<Either<Failure, List<Map<String, dynamic>>>> suggestReplies(
    Map<String, dynamic> payload,
  );
}
