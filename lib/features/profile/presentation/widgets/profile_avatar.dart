import 'package:flutter/material.dart';
import 'package:elevate/core/theme/app_theme.dart';

/// Circular avatar showing the user's initials, matching the screenshot style.
class ProfileAvatar extends StatelessWidget {
  final String initials;
  final double size;

  const ProfileAvatar({
    super.key,
    required this.initials,
    this.size = 88,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Soft periwinkle/lavender fill from the screenshot
        color: const Color(0xFFE8ECFF),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.32,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryBlue,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
