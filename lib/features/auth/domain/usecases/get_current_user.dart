import 'package:elevate/features/auth/domain/entities/user_entity.dart';
import 'package:elevate/features/auth/domain/repositories/auth_repository.dart';

/// Fetches the currently authenticated user profile.
class GetCurrentUserUseCase {
  final AuthRepository _repository;

  const GetCurrentUserUseCase(this._repository);

  Future<UserEntity> call() => _repository.getCurrentUser();
}
