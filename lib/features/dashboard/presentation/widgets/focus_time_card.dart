import 'package:flutter/material.dart';
import 'package:elevate/core/theme/app_theme.dart';
import 'package:elevate/features/dashboard/presentation/widgets/pressable_card.dart';

/// Focus time card — shows today's focused time.
class FocusTimeCard extends StatelessWidget {
  final String focusTime;

  const FocusTimeCard({super.key, required this.focusTime});

  @override
  Widget build(BuildContext context) {
    return PressableCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Focus time today',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              focusTime,
              style: const TextStyle(
                fontSize: 28,
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
