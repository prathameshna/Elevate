import 'package:elevate/features/auth/domain/entities/user_entity.dart';

/// Contract for authentication data operations.
abstract class AuthRepository {
  /// Returns the currently authenticated user.
  Future<UserEntity> getCurrentUser();

  /// Signs the user out.
  Future<void> signOut();
}
