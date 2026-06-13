import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:elevate/core/theme/app_theme.dart';
import 'package:elevate/features/alarms/domain/entities/alarm_entity.dart';

class AlarmCard extends StatefulWidget {
  final AlarmEntity alarm;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const AlarmCard({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onDelete,
    this.onTap,
  });

  @override
  State<AlarmCard> createState() => _AlarmCardState();
}

class _AlarmCardState extends State<AlarmCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  String _formatTime(DateTime t) {
    final h = t.hour == 0
        ? 12
        : t.hour > 12
            ? t.hour - 12
            : t.hour;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatRepeat(List<int> days) {
    if (days.isEmpty) return 'One time';
    if (days.length == 7) return 'Daily';
    if (days.toSet().containsAll({1, 2, 3, 4, 5}) && days.length == 5) {
      return 'Weekdays';
    }
    if (days.toSet().containsAll({6, 7}) && days.length == 2) {
      return 'Weekends';
    }
    const names = {
      1: 'Mon',
      2: 'Tue',
      3: 'Wed',
      4: 'Thu',
      5: 'Fri',
      6: 'Sat',
      7: 'Sun'
    };
    return days.map((d) => names[d] ?? '').join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final alarm = widget.alarm;
    final timeStr = _formatTime(alarm.time);
    final repeatStr = _formatRepeat(alarm.repeatDays);
    final isEnabled = alarm.enabled;

    return Dismissible(
      key: ValueKey(alarm.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        HapticFeedback.mediumImpact();
        return true;
      },
      onDismissed: (_) => widget.onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFFF3B30),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
      ),
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) {
          _pressCtrl.reverse();
          HapticFeedback.selectionClick();
          widget.onTap?.call();
        },
        onTapCancel: () => _pressCtrl.reverse(),
        child: ScaleTransition(
          scale: _scaleAnim,
          child: AnimatedOpacity(
            opacity: isEnabled ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 12,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Row 1: Time + Toggle ────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time in DM Serif Display — very large
                      Text(
                        timeStr,
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 56,
                          fontWeight: FontWeight.w400,
                          color: isEnabled
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                          height: 1.0,
                          letterSpacing: -1,
                        ),
                      ),
                      const Spacer(),
                      // Toggle switch — top right
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: _AnimatedToggle(
                          value: isEnabled,
                          onChanged: (val) {
                            HapticFeedback.selectionClick();
                            widget.onToggle(val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // ── Row 2: Repeat · Label ──────────────────────────────
                  Text(
                    '$repeatStr · ${alarm.label}',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  // ── Row 3: NEXT ALARM badge (conditional) ─────────────
                  if (alarm.isNextAlarm) ...[
                    const SizedBox(height: 10),
                    _NextAlarmBadge(alarm: alarm),
                  ],
                  // ── Row 4: Mission chips + snooze ─────────────────────
                  if (alarm.missions.isNotEmpty ||
                      alarm.snoozeDurationMinutes != null) ...[
                    const SizedBox(height: 10),
                    _ChipsRow(alarm: alarm),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Toggle (spring 150ms)
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AnimatedToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        width: 50,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: value ? AppTheme.primaryBlue : const Color(0xFFE5E7EB),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutBack,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x20000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NEXT ALARM green badge
// ─────────────────────────────────────────────────────────────────────────────
class _NextAlarmBadge extends StatelessWidget {
  final AlarmEntity alarm;
  const _NextAlarmBadge({required this.alarm});

  String _nextAlarmIn() {
    final now = DateTime.now();
    var next = DateTime(
        now.year, now.month, now.day, alarm.time.hour, alarm.time.minute);
    if (next.isBefore(now)) next = next.add(const Duration(days: 1));
    final diff = next.difference(now);
    final h = diff.inHours;
    final m = diff.inMinutes.remainder(60);
    if (h > 0 && m > 0) return 'IN ${h}H ${m}M';
    if (h > 0) return 'IN ${h}H';
    return 'IN ${m}M';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time_rounded,
            size: 13,
            color: Color(0xFF16A34A),
          ),
          const SizedBox(width: 5),
          Text(
            'NEXT ALARM · ${_nextAlarmIn()}',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF16A34A),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Missions + Snooze chips row
// ─────────────────────────────────────────────────────────────────────────────
class _ChipsRow extends StatelessWidget {
  final AlarmEntity alarm;
  const _ChipsRow({required this.alarm});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        // Mission chips
        for (final m in alarm.missions)
          _Chip(
            label: m.label,
            backgroundColor: m.backgroundColor,
            textColor: m.textColor,
          ),
        // Snooze chip
        if (alarm.snoozeDurationMinutes != null)
          _Chip(
            label: '${alarm.snoozeDurationMinutes} MIN\nSNOOZE',
            backgroundColor: const Color(0xFFF3F4F6),
            textColor: AppTheme.textSecondary,
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _Chip({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
          letterSpacing: 0.4,
          height: 1.3,
        ),
      ),
    );
  }
}
