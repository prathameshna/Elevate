import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:elevate/core/theme/app_theme.dart';
import 'package:elevate/features/dashboard/domain/entities/dashboard_data.dart';
import 'package:elevate/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:elevate/features/dashboard/presentation/widgets/alarm_card.dart';
import 'package:elevate/features/dashboard/presentation/widgets/app_bottom_nav_bar.dart';
import 'package:elevate/features/dashboard/presentation/widgets/dashboard_shimmer.dart';
import 'package:elevate/features/dashboard/presentation/widgets/focus_time_card.dart';
import 'package:elevate/features/dashboard/presentation/widgets/highlight_card.dart';
import 'package:elevate/features/dashboard/presentation/widgets/news_card.dart';
import 'package:elevate/features/dashboard/presentation/widgets/stats_card.dart';
import 'package:elevate/features/dashboard/presentation/widgets/sticky_notes_card.dart';
import 'package:elevate/features/dashboard/presentation/widgets/tasks_done_card.dart';
import 'package:elevate/features/dashboard/presentation/widgets/workspace_card.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    HapticFeedback.mediumImpact();
    ref.invalidate(dashboardDataProvider);
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: dashboardAsync.when(
        loading: () => const SafeArea(child: DashboardShimmer()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppTheme.textSecondary),
              const SizedBox(height: 12),
              Text('Something went wrong',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(dashboardDataProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) => _DashboardContent(
          data: data,
          scrollController: _scrollController,
          onRefresh: _onRefresh,
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(),
      floatingActionButton: _ElevateFAB(),
    );
  }
}

class _ElevateFAB extends StatefulWidget {
  @override
  State<_ElevateFAB> createState() => _ElevateFABState();
}

class _ElevateFABState extends State<_ElevateFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.lightImpact();
    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: _onTap,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Dashboard Content — the scrollable card grid with stagger anim
// ─────────────────────────────────────────────────────────────────
class _DashboardContent extends StatelessWidget {
  final DashboardData data;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;

  const _DashboardContent({
    required this.data,
    required this.scrollController,
    required this.onRefresh,
  });

  // Stagger helper — fade + 8px slideY with per-card delay
  Widget _stagger(Widget child, int index) {
    return RepaintBoundary(
      child: child
          .animate()
          .fadeIn(
            delay: Duration(milliseconds: index * 40),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
          )
          .slideY(
            begin: 0.04,
            end: 0,
            delay: Duration(milliseconds: index * 40),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppTheme.primaryBlue,
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      child: CustomScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // ── Header ──────────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _stagger(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Good morning John',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          context.push('/profile');
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0F000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            size: 20,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  0,
                ),
              ),
            ),
          ),

          // ── Cards grid ──────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Row 0: Stats card (full width)
                _stagger(
                  StatsCard(
                    dayStreak: data.dayStreak,
                    weeklyPoints: data.weeklyPoints,
                    weeklyPointsDelta: data.weeklyPointsDelta,
                  ),
                  1,
                ),
                const SizedBox(height: 12),

                // Row 1: Focus Time | Highlight
                _stagger(
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: FocusTimeCard(focusTime: data.focusTime),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: HighlightCard(
                            title: data.highlightTitle,
                            date: data.highlightDate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  2,
                ),
                const SizedBox(height: 12),

                // Row 2: Alarm | Tasks Done
                _stagger(
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: AlarmCard(alarmTime: data.nextAlarmTime),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TasksDoneCard(
                            tasksDone: data.tasksDone,
                            tasksTotal: data.tasksTotal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  3,
                ),
                const SizedBox(height: 12),

                // Row 3: News (wider) | Sticky Notes
                _stagger(
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 55,
                        child: NewsCard(
                          title: data.newsTitle,
                          category: data.newsCategory,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 45,
                        child: const StickyNotesCard(),
                      ),
                    ],
                  ),
                  4,
                ),
                const SizedBox(height: 12),

                // Row 4: Workspace (full width)
                _stagger(
                  WorkspaceCard(
                    workspaceName: data.workspaceName,
                    activeProjects: data.activeProjects,
                    newDocuments: data.newDocuments,
                    avatarInitials: data.workspaceAvatars,
                  ),
                  5,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
