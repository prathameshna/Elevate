import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:elevate/core/theme/app_theme.dart';

// ─── Public data models ───────────────────────────────────────────────────────

class ProfileMenuBadge {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const ProfileMenuBadge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });
}

class ProfileMenuItemData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ProfileMenuBadge? badge;

  const ProfileMenuItemData({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
  });
}

// ─── Card ─────────────────────────────────────────────────────────────────────
/// A grouped, rounded card that renders a list of tappable menu rows separated
/// by subtle dividers — matches the screenshot exactly.
class ProfileMenuCard extends StatelessWidget {
  final List<ProfileMenuItemData> items;

  const ProfileMenuCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0)
                const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 52,
                  endIndent: 0,
                  color: AppTheme.divider,
                ),
              _ProfileMenuRow(item: items[i]),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Row ──────────────────────────────────────────────────────────────────────
class _ProfileMenuRow extends StatefulWidget {
  final ProfileMenuItemData item;

  const _ProfileMenuRow({required this.item});

  @override
  State<_ProfileMenuRow> createState() => _ProfileMenuRowState();
}

class _ProfileMenuRowState extends State<_ProfileMenuRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    HapticFeedback.selectionClick();
    setState(() => _pressed = true);
    _ctrl.forward();
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
    _ctrl.reverse();
    widget.item.onTap();
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final badge = widget.item.badge;

    return RepaintBoundary(
      child: ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            color: _pressed
                ? AppTheme.divider.withValues(alpha: 0.6)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                // Leading icon
                Icon(
                  widget.item.icon,
                  size: 22,
                  color: AppTheme.textSecondary,
                ),

                const SizedBox(width: 14),

                // Label
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textPrimary,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),

                // Optional badge
                if (badge != null) ...[
                  _Badge(
                    label: badge.label,
                    backgroundColor: badge.backgroundColor,
                    textColor: badge.textColor,
                  ),
                  const SizedBox(width: 8),
                ],

                // Trailing chevron
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppTheme.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Badge chip ───────────────────────────────────────────────────────────────
class _Badge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _Badge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
