import 'package:elevate/features/auth/domain/entities/user_entity.dart';
import 'package:elevate/features/auth/domain/repositories/auth_repository.dart';

/// Stub implementation — replace with real auth backend (Firebase, Supabase, etc.)
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<UserEntity> getCurrentUser() async {
    // Simulate a slight network delay
    await Future.delayed(const Duration(milliseconds: 150));
    return const UserEntity(
      id: 'user_001',
      fullName: 'John Prathamesh',
      email: 'john@elevate.app',
      plan: 'pro',
    );
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Clear any locally cached tokens / Hive boxes here when auth is wired up.
  }
}
