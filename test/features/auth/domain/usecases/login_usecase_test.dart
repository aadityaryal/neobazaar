import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neobazaar/features/auth/domain/entities/auth_entity.dart';
import 'package:neobazaar/features/auth/domain/repositories/auth_categories.dart';
import 'package:neobazaar/features/auth/domain/usecases/login_usecase.dart';

class _MockAuthRepository extends Mock implements IAuthRepository {}


void main() {
  test('forwards email/password/idempotency to repository', () async {
    final repository = _MockAuthRepository();
    const user = AuthEntity(
      authId: 'u1',
      fullName: 'Neo User',
      email: 'neo@neo.com',
      username: 'neo',
    );

    when(
      () => repository.login('neo@neo.com', 'password123', idempotencyKey: 'k1'),
    ).thenAnswer((_) async => const Right(user));

    final usecase = LoginUsecase(authRepository: repository);
    final result = await usecase(
      const LoginUsecaseParams(
        email: 'neo@neo.com',
        password: 'password123',
        idempotencyKey: 'k1',
      ),
    );

    expect(result, const Right(user));
    verify(
      () => repository.login('neo@neo.com', 'password123', idempotencyKey: 'k1'),
    ).called(1);
  });
}