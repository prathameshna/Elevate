import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:elevate/core/theme/app_theme.dart';
import 'package:elevate/features/auth/domain/entities/user_entity.dart';
import 'package:elevate/features/auth/presentation/providers/auth_providers.dart';
import 'package:elevate/features/profile/presentation/widgets/profile_menu_card.dart';
import 'package:elevate/features/profile/presentation/widgets/profile_avatar.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: authAsync.when(
        loading: () => const _ProfileLoadingView(),
        error: (e, _) => _ProfileErrorView(
          onRetry: () => ref.invalidate(authControllerProvider),
        ),
        data: (user) => _ProfileContent(user: user),
      ),
    );
  }
}

// ─── Loading ──────────────────────────────────────────────────────────────────
class _ProfileLoadingView extends StatelessWidget {
  const _ProfileLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppTheme.primaryBlue,
        strokeWidth: 2.5,
      ),
    );
  }
}

// ─── Error ────────────────────────────────────────────────────────────────────
class _ProfileErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ProfileErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: AppTheme.textSecondary),
          const SizedBox(height: 12),
          Text(
            'Could not load profile',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

// ─── Main content ─────────────────────────────────────────────────────────────
class _ProfileContent extends ConsumerWidget {
  final UserEntity user;
  const _ProfileContent({required this.user});

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    await ref.read(authControllerProvider.notifier).signOut();
    if (context.mounted) {
      context.go('/login');
    }
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('This feature is coming soon'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        backgroundColor: AppTheme.textPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ── ACCOUNT items ────────────────────────────────────────────────────────
    final accountItems = [
      ProfileMenuItemData(
        icon: Icons.person_outline_rounded,
        label: 'Edit Profile',
        onTap: () => _showComingSoon(context),
      ),
      ProfileMenuItemData(
        icon: Icons.flag_outlined,
        label: 'Connected Apps',
        onTap: () => _showComingSoon(context),
      ),
    ];

    // ── PRODUCTIVITY items ────────────────────────────────────────────────────
    final productivityItems = [
      ProfileMenuItemData(
        icon: Icons.bar_chart_rounded,
        label: 'Reports',
        onTap: () => _showComingSoon(context),
      ),
      ProfileMenuItemData(
        icon: Icons.workspace_premium_outlined,
        label: 'Subscription and Plan',
        onTap: () => _showComingSoon(context),
        badge: const ProfileMenuBadge(
          label: 'Upgrade',
          backgroundColor: Color(0xFFEEF2FF),
          textColor: AppTheme.primaryBlue,
        ),
      ),
    ];

    // ── SUPPORT items ─────────────────────────────────────────────────────────
    final supportItems = [
      ProfileMenuItemData(
        icon: Icons.check_circle_outline_rounded,
        label: 'FAQ',
        onTap: () => _showComingSoon(context),
      ),
      ProfileMenuItemData(
        icon: Icons.card_giftcard_rounded,
        label: 'Refer a Friend',
        onTap: () => _showComingSoon(context),
        badge: const ProfileMenuBadge(
          label: 'Get 1 month free',
          backgroundColor: Color(0xFFDCFCE7),
          textColor: AppTheme.greenAccent,
        ),
      ),
    ];

    return SafeArea(
      child: Column(
        children: [
          // ── Scrollable body ────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back arrow
                  _BackRow()
                      .animate()
                      .fadeIn(
                        duration: 250.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .slideY(
                        begin: 0.05,
                        end: 0,
                        duration: 250.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: 16),

                  // Avatar — spring scale from 0.85 → 1.0
                  ProfileAvatar(initials: user.initials)
                      .animate()
                      .fadeIn(duration: 300.ms, curve: Curves.easeOutCubic)
                      .scale(
                        begin: const Offset(0.85, 0.85),
                        end: const Offset(1.0, 1.0),
                        duration: 300.ms,
                        curve: Curves.easeOutBack,
                      ),

                  const SizedBox(height: 16),

                  // Name + Pro badge
                  _UserNameRow(user: user)
                      .animate()
                      .fadeIn(
                        delay: 60.ms,
                        duration: 250.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .slideY(
                        begin: 0.04,
                        end: 0,
                        delay: 60.ms,
                        duration: 250.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: 4),

                  // Email
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textSecondary,
                    ),
                  )
                      .animate()
                      .fadeIn(
                        delay: 80.ms,
                        duration: 250.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: 32),

                  // ACCOUNT
                  const _SectionLabel(label: 'ACCOUNT')
                      .animate()
                      .fadeIn(
                        delay: 100.ms,
                        duration: 250.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  const SizedBox(height: 8),
                  ProfileMenuCard(items: accountItems)
                      .animate()
                      .fadeIn(
                        delay: 120.ms,
                        duration: 250.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .slideY(
                        begin: 0.04,
                        end: 0,
                        delay: 120.ms,
                        duration: 250.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: 20),

                  // PRODUCTIVITY
                  const _SectionLabel(label: 'PRODUCTIVITY')
                      .animate()
                      .fadeIn(
                        delay: 180.ms,
                        duration: 250.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  const SizedBox(height: 8),
                  ProfileMenuCard(items: productivityItems)
                      .animate()
                      .fadeIn(
                        delay: 200.ms,
                        duration: 250.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .slideY(
                        begin: 0.04,
                        end: 0,
                        delay: 200.ms,
                        duration: 250.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  const SizedBox(height: 20),

                  // SUPPORT
                  const _SectionLabel(label: 'SUPPORT')
                      .animate()
                      .fadeIn(
                        delay: 260.ms,
                        duration: 250.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  const SizedBox(height: 8),
                  ProfileMenuCard(items: supportItems)
                      .animate()
                      .fadeIn(
                        delay: 280.ms,
                        duration: 250.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .slideY(
                        begin: 0.04,
                        end: 0,
                        delay: 280.ms,
                        duration: 250.ms,
                        curve: Curves.easeOutCubic,
                      ),
                ],
              ),
            ),
          ),

          // ── Sign out (fades in last, after all cards) ──────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: _SignOutButton(
              onTap: () => _handleSignOut(context, ref),
            )
                .animate()
                .fadeIn(
                  delay: 360.ms,
                  duration: 250.ms,
                  curve: Curves.easeOutCubic,
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Back row ─────────────────────────────────────────────────────────────────
class _BackRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          context.pop();
        },
        behavior: HitTestBehavior.opaque,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Icon(
            Icons.arrow_back,
            size: 24,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}

// ─── Name + Pro badge ─────────────────────────────────────────────────────────
class _UserNameRow extends StatelessWidget {
  final UserEntity user;
  const _UserNameRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          user.fullName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        if (user.isPro) ...[
          const SizedBox(width: 8),
          _ProBadge(),
        ],
      ],
    );
  }
}

class _ProBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.25),
        ),
      ),
      child: const Text(
        'Pro',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryBlue,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppTheme.textTertiary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─── Sign out button ──────────────────────────────────────────────────────────
class _SignOutButton extends StatefulWidget {
  final VoidCallback onTap;
  const _SignOutButton({required this.onTap});

  @override
  State<_SignOutButton> createState() => _SignOutButtonState();
}

class _SignOutButtonState extends State<_SignOutButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
          child: Text(
            'Sign out',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFFE03434),
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }
}
