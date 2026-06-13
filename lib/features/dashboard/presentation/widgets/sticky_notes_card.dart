import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:elevate/core/theme/app_theme.dart';
import 'package:elevate/features/dashboard/presentation/widgets/pressable_card.dart';

/// Sticky Notes card — a simple shortcut tile.
class StickyNotesCard extends StatelessWidget {
  const StickyNotesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return PressableCard(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('/notepad/web');
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFFE082),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.sticky_note_2_rounded,
                size: 18,
                color: Color(0xFFE6A817),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sticky Notes',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
