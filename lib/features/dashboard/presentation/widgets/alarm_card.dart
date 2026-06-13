import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:elevate/core/theme/app_theme.dart';
import 'package:elevate/features/dashboard/presentation/widgets/pressable_card.dart';

/// Next alarm card — shows the next scheduled alarm time.
class AlarmCard extends StatelessWidget {
  final String alarmTime;

  const AlarmCard({super.key, required this.alarmTime});

  @override
  Widget build(BuildContext context) {
    return PressableCard(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('/alarms');
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.alarm_rounded,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Next alarm',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              alarmTime,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
