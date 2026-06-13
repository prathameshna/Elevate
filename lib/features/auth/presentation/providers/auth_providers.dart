import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elevate/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:elevate/features/auth/domain/entities/user_entity.dart';
import 'package:elevate/features/auth/domain/repositories/auth_repository.dart';
import 'package:elevate/features/auth/domain/usecases/get_current_user.dart';
import 'package:elevate/features/auth/domain/usecases/sign_out.dart';

// ── Repository ────────────────────────────────────────────────────────────────
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

// ── Use-cases ─────────────────────────────────────────────────────────────────
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.read(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.read(authRepositoryProvider));
});

// ── Auth controller notifier ──────────────────────────────────────────────────
class AuthController extends AsyncNotifier<UserEntity> {
  @override
  Future<UserEntity> build() async {
    final useCase = ref.read(getCurrentUserUseCaseProvider);
    return useCase();
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    final useCase = ref.read(signOutUseCaseProvider);
    state = await AsyncValue.guard(() => useCase().then((_) =>
        const UserEntity(id: '', fullName: '', email: '', plan: 'free')));
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserEntity>(AuthController.new);
