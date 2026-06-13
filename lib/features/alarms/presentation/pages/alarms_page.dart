import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:elevate/core/theme/app_theme.dart';
import 'package:elevate/features/alarms/domain/entities/alarm_entity.dart';
import 'package:elevate/features/alarms/presentation/providers/alarm_providers.dart';
import 'package:elevate/features/alarms/presentation/widgets/alarm_list_item.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Alarms Page
// ─────────────────────────────────────────────────────────────────────────────
class AlarmsPage extends ConsumerWidget {
  const AlarmsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarmsAsync = ref.watch(alarmProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // ── Safe area top padding ──────────────────────────────────────
          SizedBox(height: MediaQuery.of(context).padding.top),
          // ── Header ───────────────────────────────────────────────────
          const _AlarmsHeader(),
          // ── "NO UPCOMING ALARMS" banner ───────────────────────────────
          const _NoUpcomingBanner(),
          // ── Content ──────────────────────────────────────────────────
          Expanded(
            child: alarmsAsync.when(
              loading: () => const _AlarmsShimmer(),
              error: (err, _) => _ErrorState(
                onRetry: () => ref.invalidate(alarmProvider),
              ),
              data: (alarms) => alarms.isEmpty
                  ? const _EmptyState()
                  : _AlarmsList(alarms: alarms),
            ),
          ),
        ],
      ),
      // ── FAB ──────────────────────────────────────────────────────────
      floatingActionButton: const _AddAlarmFAB()
          .animate()
          .scale(
            begin: const Offset(0, 0),
            end: const Offset(1, 1),
            duration: 300.ms,
            curve: Curves.elasticOut,
            delay: 200.ms,
          ),
      // ── Bottom Nav Bar (persistent) ────────────────────────────────
      bottomNavigationBar: const _AlarmsBottomNav(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header — "Alarms" DM Serif Display + subtitle + settings gear
// ─────────────────────────────────────────────────────────────────────────────
class _AlarmsHeader extends StatelessWidget {
  const _AlarmsHeader();

  String _subtitle() {
    final now = DateTime.now();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final tomorrow = now.add(const Duration(days: 1));
    final dayName = days[tomorrow.weekday - 1];
    final monthName = months[tomorrow.month - 1];
    return 'Tomorrow · $dayName ${tomorrow.day} $monthName';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Alarms',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 36,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textPrimary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _subtitle(),
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Settings gear with circle background
          GestureDetector(
            onTap: () => HapticFeedback.selectionClick(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.settings_outlined,
                size: 20,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 200.ms, curve: Curves.easeOut)
        .slideY(begin: -0.05, end: 0, duration: 200.ms, curve: Curves.easeOut);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// "NO UPCOMING ALARMS" pill banner
// ─────────────────────────────────────────────────────────────────────────────
class _NoUpcomingBanner extends StatelessWidget {
  const _NoUpcomingBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEAEAEA),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          'NO UPCOMING ALARMS',
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 80.ms, duration: 200.ms)
        .slideY(begin: 0.05, end: 0, delay: 80.ms, duration: 200.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Alarms scrollable list
// ─────────────────────────────────────────────────────────────────────────────
class _AlarmsList extends ConsumerWidget {
  final List<AlarmEntity> alarms;
  const _AlarmsList({required this.alarms});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        ref.invalidate(alarmProvider);
        await Future.delayed(const Duration(milliseconds: 600));
      },
      color: AppTheme.primaryBlue,
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: alarms.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final alarm = alarms[i];
          return AlarmCard(
            key: ValueKey(alarm.id),
            alarm: alarm,
            onToggle: (enabled) {
              ref
                  .read(alarmProvider.notifier)
                  .toggleAlarm(alarm.id, enabled: enabled);
            },
            onDelete: () {
              ref.read(alarmProvider.notifier).deleteAlarm(alarm.id);
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(
                  content: Text('${alarm.label} removed'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  backgroundColor: AppTheme.textPrimary,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 100 + i * 50),
                duration: 220.ms,
                curve: Curves.easeOutCubic,
              )
              .slideY(
                begin: 0.05,
                end: 0,
                delay: Duration(milliseconds: 100 + i * 50),
                duration: 220.ms,
                curve: Curves.easeOutCubic,
              );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FAB — Add Alarm
// ─────────────────────────────────────────────────────────────────────────────
class _AddAlarmFAB extends ConsumerStatefulWidget {
  const _AddAlarmFAB();

  @override
  ConsumerState<_AddAlarmFAB> createState() => _AddAlarmFABState();
}

class _AddAlarmFABState extends ConsumerState<_AddAlarmFAB>
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
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.lightImpact();
    _ctrl.forward().then((_) => _ctrl.reverse());
    _showAddAlarmSheet(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 60,
          height: 60,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withValues(alpha: 0.40),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Alarm bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
void _showAddAlarmSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AddAlarmSheet(),
  );
}

class _AddAlarmSheet extends ConsumerStatefulWidget {
  const _AddAlarmSheet();

  @override
  ConsumerState<_AddAlarmSheet> createState() => _AddAlarmSheetState();
}

class _AddAlarmSheetState extends ConsumerState<_AddAlarmSheet> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  final _labelController = TextEditingController(text: 'New Alarm');
  final Set<int> _selectedDays = {1, 2, 3, 4, 5};

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'New Alarm',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 22,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          // Time picker
          GestureDetector(
            onTap: () async {
              final t = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (t != null) setState(() => _selectedTime = t);
            },
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 20, color: AppTheme.primaryBlue),
                  const SizedBox(width: 12),
                  Text(
                    _selectedTime.format(context),
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 22,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppTheme.textTertiary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Label
          TextField(
            controller: _labelController,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: 'Label',
              labelStyle: GoogleFonts.dmSans(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
              filled: true,
              fillColor: AppTheme.background,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.label_outline_rounded,
                  size: 18, color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 14),
          // Repeat days
          Text(
            'Repeat',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final day = i + 1;
              final selected = _selectedDays.contains(day);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    selected
                        ? _selectedDays.remove(day)
                        : _selectedDays.add(day);
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.primaryBlue
                        : AppTheme.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _dayLabels[i],
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color:
                          selected ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                'Save Alarm',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    final now = DateTime.now();
    final alarm = AlarmEntity(
      id: '${now.millisecondsSinceEpoch}',
      time: DateTime(now.year, now.month, now.day, _selectedTime.hour,
          _selectedTime.minute),
      label: _labelController.text.trim().isEmpty
          ? 'Alarm'
          : _labelController.text.trim(),
      enabled: true,
      repeatDays: _selectedDays.toList()..sort(),
    );
    ref.read(alarmProvider.notifier).addAlarm(alarm);
    Navigator.of(context).pop();
    HapticFeedback.mediumImpact();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton shimmer
// ─────────────────────────────────────────────────────────────────────────────
class _AlarmsShimmer extends StatelessWidget {
  const _AlarmsShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => Container(
        height: i == 0 ? 160 : 140,
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
      )
          .animate(onPlay: (c) => c.repeat())
          .shimmer(
            duration: const Duration(milliseconds: 1200),
            color: const Color(0x1A2D6BE4),
          ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state (different from "no upcoming alarms" banner)
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.alarm_off_rounded,
              size: 32,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No alarms yet',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 20,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to add your first alarm',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      )
          .animate()
          .fadeIn(duration: 300.ms)
          .scale(begin: const Offset(0.92, 0.92), end: const Offset(1, 1)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error state
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

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
            'Could not load alarms',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Persistent Bottom Nav Bar (Alarms tab active)
// ─────────────────────────────────────────────────────────────────────────────
class _AlarmsBottomNav extends StatelessWidget {
  const _AlarmsBottomNav();

  static const _tabs = [
    _Tab(icon: Icons.grid_view_rounded, label: 'DASHBOARD'),
    _Tab(icon: Icons.alarm_rounded, label: 'ALARM'),
    _Tab(icon: Icons.check_circle_outline_rounded, label: 'TASK'),
    _Tab(icon: Icons.calendar_month_outlined, label: 'CALENDAR'),
    _Tab(icon: Icons.adjust_rounded, label: 'FOCUS'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < _tabs.length; i++)
                _NavTabItem(
                  tab: _tabs[i],
                  isSelected: i == 1, // Alarm tab is always active here
                  onTap: () {
                    if (i != 1) {
                      HapticFeedback.selectionClick();
                      context.go('/');
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTabItem extends StatefulWidget {
  final _Tab tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTabItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavTabItem> createState() => _NavTabItemState();
}

class _NavTabItemState extends State<_NavTabItem>
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
    _scale = Tween<double>(begin: 1.0, end: 0.85)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.isSelected;
    return GestureDetector(
      onTap: () {
        _ctrl.forward().then((_) => _ctrl.reverse());
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          width: 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.tab.icon,
                  size: 22,
                  color: selected
                      ? AppTheme.primaryBlue
                      : AppTheme.navUnselected,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.tab.label,
                style: GoogleFonts.dmSans(
                  fontSize: 9,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected
                      ? AppTheme.primaryBlue
                      : AppTheme.navUnselected,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab {
  final IconData icon;
  final String label;
  const _Tab({required this.icon, required this.label});
}
