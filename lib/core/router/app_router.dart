import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:elevate/features/alarms/presentation/pages/alarms_page.dart';
import 'package:elevate/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:elevate/features/news/presentation/pages/news_feed_page.dart';
import 'package:elevate/features/notepad/domain/entities/note_entity.dart';
import 'package:elevate/features/notepad/presentation/pages/note_detail_page.dart';
import 'package:elevate/features/notepad/presentation/pages/notepad_page.dart';
import 'package:elevate/features/notepad/presentation/pages/notepad_web_page.dart';
import 'package:elevate/features/profile/presentation/pages/profile_page.dart';

// ── Custom page transition: fade + slide up 12 px, 280 ms easeOutCubic ────────
CustomTransitionPage<void> _fadeSlideUp({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Forward: fade + slide up 12px; reverse animates back naturally
      final fadeIn = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.03), // ~12px slide up on a 400-px screen
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      return FadeTransition(
        opacity: fadeIn,
        child: SlideTransition(
          position: slide,
          child: child,
        ),
      );
    },
  );
}

// ── Router ────────────────────────────────────────────────────────────────────
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ── Dashboard (shell route — has bottom nav bar) ───────────────────────
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const DashboardPage(),
    ),

    // ── Alarms — pushed on top, no bottom nav bar ─────────────────────────
    GoRoute(
      path: '/alarms',
      name: 'alarms',
      pageBuilder: (context, state) => _fadeSlideUp(
        context: context,
        state: state,
        child: const AlarmsPage(),
      ),
    ),

    // ── Profile — pushed on top, no bottom nav bar ─────────────────────────
    GoRoute(
      path: '/profile',
      name: 'profile',
      pageBuilder: (context, state) => _fadeSlideUp(
        context: context,
        state: state,
        child: const ProfilePage(),
      ),
    ),

    // ── News Feed — slides up from bottom, no bottom nav bar ─────────────
    GoRoute(
      path: '/news',
      name: 'news',
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: const NewsFeedPage(),
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slideIn = Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );
          final fadeIn = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: fadeIn,
            child: SlideTransition(position: slideIn, child: child),
          );
        },
      ),
    ),

    // ── Notepad — slides up from bottom, no bottom nav bar ─────────────
    GoRoute(
      path: '/notepad',
      name: 'notepad',
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: const NotepadPage(),
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slideIn = Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );
          return SlideTransition(position: slideIn, child: child);
        },
      ),
      routes: [
        GoRoute(
          path: 'detail',
          name: 'note_detail',
          pageBuilder: (context, state) {
            final existingNote = state.extra as NoteEntity?;
            return CustomTransitionPage<void>(
              key: state.pageKey,
              child: NoteDetailPage(existingNote: existingNote),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                final slideIn = Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                );
                return SlideTransition(position: slideIn, child: child);
              },
            );
          },
        ),
      ],
    ),

    // ── Notepad Web — slides up from bottom, no bottom nav bar ─────────────
    GoRoute(
      path: '/notepad/web',
      name: 'notepad_web',
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: const NotepadWebPage(),
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slideIn = Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );
          return SlideTransition(position: slideIn, child: child);
        },
      ),
    ),

    // ── Login stub — destination after sign-out ────────────────────────────
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: const _LoginStubPage(),
        transitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
            child: child,
          );
        },
      ),
    ),
  ],
);

// ── Login stub page (replace when auth UI is built) ───────────────────────────
class _LoginStubPage extends StatelessWidget {
  const _LoginStubPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline_rounded, size: 48, color: Color(0xFF2D6BE4)),
            const SizedBox(height: 16),
            const Text(
              'Login',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Login screen — coming soon',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
