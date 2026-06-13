import 'package:flutter/material.dart';
import 'package:elevate/core/theme/app_theme.dart';
import 'package:elevate/features/dashboard/presentation/widgets/pressable_card.dart';

/// Workspace card — shows project portal with avatars.
class WorkspaceCard extends StatelessWidget {
  final String workspaceName;
  final int activeProjects;
  final int newDocuments;
  final List<String> avatarInitials;

  const WorkspaceCard({
    super.key,
    required this.workspaceName,
    required this.activeProjects,
    required this.newDocuments,
    required this.avatarInitials,
  });

  static const List<Color> _avatarColors = [
    Color(0xFF4C7BF4),
    Color(0xFF2D2D2D),
    Color(0xFF6C63FF),
    Color(0xFFE8762B),
    Color(0xFF22C55E),
  ];

  @override
  Widget build(BuildContext context) {
    return PressableCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.work_outline_rounded,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'WORKSPACE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Name & folder icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workspaceName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$activeProjects active projects · $newDocuments new documents',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.folder_open_rounded,
                    size: 18,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Avatars row
            _AvatarStack(
              initials: avatarInitials,
              colors: _avatarColors,
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  final List<String> initials;
  final List<Color> colors;

  const _AvatarStack({required this.initials, required this.colors});

  @override
  Widget build(BuildContext context) {
    const double size = 28;
    const double overlap = 10;
    final visible = initials.take(5).toList();
    final extra = initials.length > 5 ? initials.length - 5 : 0;

    return SizedBox(
      height: size,
      width: visible.length * (size - overlap) + overlap + (extra > 0 ? 34 : 0),
      child: Stack(
        children: [
          for (int i = 0; i < visible.length; i++)
            Positioned(
              left: i * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: colors[i % colors.length],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  visible[i],
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          if (extra > 0)
            Positioned(
              left: visible.length * (size - overlap),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                height: size,
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(size / 2),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$extra',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
