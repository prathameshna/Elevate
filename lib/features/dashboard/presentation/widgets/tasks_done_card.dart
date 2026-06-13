import 'package:flutter/material.dart';
import 'package:elevate/core/theme/app_theme.dart';
import 'package:elevate/features/dashboard/presentation/widgets/pressable_card.dart';

/// Tasks done card — shows X / Y completion with progress bar.
class TasksDoneCard extends StatelessWidget {
  final int tasksDone;
  final int tasksTotal;

  const TasksDoneCard({
    super.key,
    required this.tasksDone,
    required this.tasksTotal,
  });

  @override
  Widget build(BuildContext context) {
    final progress = tasksTotal > 0 ? tasksDone / tasksTotal : 0.0;

    return PressableCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TASKS DONE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$tasksDone',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    height: 1.0,
                  ),
                ),
                const Text(
                  ' / ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  '$tasksTotal',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            RepaintBoundary(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 6,
                      backgroundColor: AppTheme.progressBg,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.progressFill),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
