import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neobazaar/features/auth/domain/entities/auth_entity.dart';
import 'package:neobazaar/features/auth/domain/repositories/auth_categories.dart';
import 'package:neobazaar/features/auth/domain/usecases/register_usecase.dart';

class _MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const AuthEntity(
        fullName: 'Fallback User',
        email: 'fallback@neo.com',
        username: 'fallback',
      ),
    );
  });

  test('maps params to AuthEntity and delegates repository call', () async {
    final repository = _MockAuthRepository();

    when(() => repository.register(any(), idempotencyKey: 'k2'))
        .thenAnswer((_) async => const Right(true));

    final usecase = RegisterUsecase(authRepository: repository);
    final result = await usecase(
      const RegisterUsecaseParams(
        fullName: 'Neo User',
        email: 'neo@neo.com',
        username: 'neo_user',
        password: 'password123',
        location: 'Kathmandu',
        idempotencyKey: 'k2',
      ),
    );

    expect(result, const Right(true));
    verify(
      () => repository.register(
        any(
          that: isA<AuthEntity>()
              .having((e) => e.fullName, 'fullName', 'Neo User')
              .having((e) => e.location, 'location', 'Kathmandu'),
        ),
        idempotencyKey: 'k2',
      ),
    ).called(1);
  });
}
