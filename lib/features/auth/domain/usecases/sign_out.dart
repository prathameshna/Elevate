import 'package:elevate/features/auth/domain/repositories/auth_repository.dart';

/// Signs the current user out.
class SignOutUseCase {
  final AuthRepository _repository;

  const SignOutUseCase(this._repository);

  Future<void> call() => _repository.signOut();
}
