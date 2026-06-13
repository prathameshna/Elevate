import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:elevate/core/theme/app_theme.dart';
import 'package:elevate/features/notepad/domain/entities/note_entity.dart';
import 'package:elevate/features/notepad/presentation/providers/notepad_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Notepad Page
// ─────────────────────────────────────────────────────────────────────────────
class NotepadPage extends ConsumerStatefulWidget {
  const NotepadPage({super.key});

  @override
  ConsumerState<NotepadPage> createState() => _NotepadPageState();
}

class _NotepadPageState extends ConsumerState<NotepadPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        _searchFocus.requestFocus();
      } else {
        _searchCtrl.clear();
        ref.read(noteSearchQueryProvider.notifier).state = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.background,
      // The drawer implementation is attached to the Scaffold
      drawer: const _NotepadDrawer(),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // ── Custom App Bar (Sticky) ────────────────────────────────────
              SliverPersistentHeader(
                pinned: true,
                delegate: _NotepadAppBarDelegate(
                  onMenuTap: () {
                    HapticFeedback.selectionClick();
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  isSearching: _isSearching,
                  searchCtrl: _searchCtrl,
                  searchFocus: _searchFocus,
                  onSearchToggle: _toggleSearch,
                  onSearchChanged: (val) {
                    ref.read(noteSearchQueryProvider.notifier).state = val;
                  },
                  onPdfExport: () => _showPdfExportSheet(context),
                ),
              ),

              // ── Sort Row ───────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Consumer(
                    builder: (context, ref, child) {
                      final sortOption = ref.watch(noteSortProvider);
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(noteSortProvider.notifier).state =
                              sortOption.next;
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
                              child: Text(
                                sortOption.label,
                                key: ValueKey(sortOption),
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: AppTheme.textTertiary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.sort_rounded,
                              size: 18,
                              color: AppTheme.textTertiary,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // ── Masonry Grid ───────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: notesAsync.when(
                  loading: () => const SliverToBoxAdapter(child: _NotesShimmer()),
                  error: (err, _) => SliverToBoxAdapter(
                    child: _ErrorState(
                      onRetry: () => ref.invalidate(notesProvider),
                    ),
                  ),
                  data: (notes) {
                    if (notes.isEmpty) {
                      return const SliverToBoxAdapter(child: _EmptyState());
                    }
                    return SliverMasonryGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 16,
                      childCount: notes.length,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return _NoteCard(
                          note: note,
                          index: index,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            context.push('/notepad/detail', extra: note);
                          },
                          onDelete: () {
                            ref.read(notesProvider.notifier).deleteNote(note.id);
                          },
                        )
                            .animate()
                            .fadeIn(
                              delay: Duration(milliseconds: index * 35),
                              duration: 180.ms,
                              curve: Curves.easeOut,
                            )
                            .slideY(
                              begin: 0.1,
                              end: 0,
                              delay: Duration(milliseconds: index * 35),
                              duration: 180.ms,
                              curve: Curves.easeOut,
                            );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // ── Floating Action Button ───────────────────────────────────────
          Positioned(
            right: 24,
            bottom: 24,
            child: const _Fab()
                .animate()
                .scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  duration: 300.ms,
                  curve: Curves.elasticOut,
                ),
          ),
        ],
      ),
    );
  }

  void _showPdfExportSheet(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _PdfExportSheet(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Sticky App Bar Delegate
// ─────────────────────────────────────────────────────────────────────────────
class _NotepadAppBarDelegate extends SliverPersistentHeaderDelegate {
  final VoidCallback onMenuTap;
  final bool isSearching;
  final TextEditingController searchCtrl;
  final FocusNode searchFocus;
  final VoidCallback onSearchToggle;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onPdfExport;

  _NotepadAppBarDelegate({
    required this.onMenuTap,
    required this.isSearching,
    required this.searchCtrl,
    required this.searchFocus,
    required this.onSearchToggle,
    required this.onSearchChanged,
    required this.onPdfExport,
  });

  @override
  double get minExtent => 64.0 + 44.0; // Assume top padding ~44 for safe area
  @override
  double get maxExtent => 64.0 + 44.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final topPadding = MediaQuery.of(context).padding.top;
    final totalHeight = 64.0 + topPadding;

    return Container(
      height: totalHeight,
      padding: EdgeInsets.only(top: topPadding),
      decoration: BoxDecoration(
        color: AppTheme.background.withValues(alpha: 0.9),
      ),        child: ClipRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // ── Menu / Back button ───────────────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isSearching
                      ? IconButton(
                          key: const ValueKey('back'),
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: AppTheme.textPrimary,
                          onPressed: onSearchToggle,
                        )
                      : GestureDetector(
                          key: const ValueKey('menu'),
                          onTap: onMenuTap,
                          child: Stack(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.menu_rounded,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primaryBlue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(width: 16),

                // ── Title / Search Input ─────────────────────────────────────
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: isSearching
                        ? TextField(
                            controller: searchCtrl,
                            focusNode: searchFocus,
                            onChanged: onSearchChanged,
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              color: AppTheme.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search notes...',
                              hintStyle: GoogleFonts.dmSans(
                                color: AppTheme.textTertiary,
                              ),
                              border: InputBorder.none,
                            ),
                          )
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Notepad',
                              style: GoogleFonts.dmSerifDisplay(
                                fontSize: 22,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                  ),
                ),

                // ── Actions ──────────────────────────────────────────────────
                if (!isSearching) ...[
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    color: AppTheme.textPrimary,
                    onPressed: onPdfExport,
                  ),
                  IconButton(
                    icon: const Icon(Icons.search_rounded),
                    color: AppTheme.textPrimary,
                    onPressed: onSearchToggle,
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert_rounded),
                    color: AppTheme.textPrimary,
                    onPressed: () {},
                  ),
                ] else if (searchCtrl.text.isNotEmpty) ...[
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: AppTheme.textPrimary,
                    onPressed: () {
                      searchCtrl.clear();
                      onSearchChanged('');
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _NotepadAppBarDelegate oldDelegate) {
    return isSearching != oldDelegate.isSearching ||
        searchCtrl.text != oldDelegate.searchCtrl.text;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation Drawer (Custom Sidebar)
// ─────────────────────────────────────────────────────────────────────────────
class _NotepadDrawer extends StatelessWidget {
  const _NotepadDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 288,
      backgroundColor: AppTheme.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Elevate',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 32,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 32),
              _DrawerItem(
                icon: Icons.description_outlined,
                label: 'All Notes',
                isActive: true,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 4),
              _DrawerItem(
                icon: Icons.folder_outlined,
                label: 'Notebooks',
                isActive: false,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 4),
              _DrawerItem(
                icon: Icons.archive_outlined,
                label: 'Archive',
                isActive: false,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 4),
              _DrawerItem(
                icon: Icons.delete_outline_rounded,
                label: 'Trash',
                isActive: false,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryBlue.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? AppTheme.primaryBlue : AppTheme.textSecondary,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppTheme.primaryBlue : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Note Card (Masonry Item)
// ─────────────────────────────────────────────────────────────────────────────
class _NoteCard extends StatefulWidget {
  final NoteEntity note;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<_NoteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late double _rotationAngle;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.98).animate(_ctrl);

    // Deterministic random rotation based on ID so it stays the same
    final rand = Random(widget.note.id.hashCode);
    
    // Rotation logic based on sticking style
    switch (widget.note.stickingStyleId) {
      case 1: // Tape center: -0.8 to 0.8
        _rotationAngle = (rand.nextDouble() * 1.6 - 0.8) * pi / 180;
        break;
      case 2: // Tape corners: -1.0 to 1.0
        _rotationAngle = (rand.nextDouble() * 2.0 - 1.0) * pi / 180;
        break;
      case 3: // Paperclip: 0
        _rotationAngle = 0;
        break;
      case 4: // Pin center: -1.2 to 1.2
      case 5: // Pin corners: -1.2 to 1.2
        _rotationAngle = (rand.nextDouble() * 2.4 - 1.2) * pi / 180;
        break;
      default:
        _rotationAngle = 0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _getBgColor() {
    switch (widget.note.type) {
      case 'default':
        return const Color(0xFFF9F8FF); // Soft lavender
      case 'list':
        return const Color(0xFFFFFAF5); // Soft cream
      case 'design':
        return const Color(0xFFFAFAF8); // Soft white
      case 'travel':
        return const Color(0xFFF9FDF6); // Soft green
      case 'meeting':
        return const Color(0xFFF9F8FF); // Soft lavender
      case 'quote':
        return const Color(0xFFFAFAF8); // Soft neutral
      default:
        return AppTheme.cardWhite;
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      onLongPress: () {
        HapticFeedback.heavyImpact();
        showModalBottomSheet(
          context: context,
          backgroundColor: AppTheme.cardWhite,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.edit_rounded, color: AppTheme.textPrimary),
                  title: Text('Edit', style: GoogleFonts.dmSans(fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.onTap();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: AppTheme.streakOrange),
                  title: Text('Delete', style: GoogleFonts.dmSans(color: AppTheme.streakOrange, fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.onDelete();
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
      child: ScaleTransition(
        scale: _scale,
        child: Transform.rotate(
          angle: _rotationAngle,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Main Card
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getBgColor(),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0x0F000000),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      widget.note.body,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.6,
                        fontStyle: widget.note.type == 'quote'
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.note.title,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(widget.note.dateModified).toUpperCase(),
                          style: GoogleFonts.dmSans(
                            fontSize: 9,
                            color: AppTheme.textTertiary,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Physical sticking elements
              ..._buildStickingElements(widget.note.stickingStyleId, widget.note.id),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStickingElements(int styleId, String seed) {
    final rand = Random(seed.hashCode);
    
    // Helper to generate tape
    Widget buildTape({double? top, double? left, double? right, double angle = 0, double width = 38}) {
      return Positioned(
        top: top,
        left: left,
        right: right,
        child: Transform.rotate(
          angle: angle * pi / 180,
          child: Container(
            width: width,
            height: 11,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.52),
              borderRadius: BorderRadius.circular(1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Helper to generate push pin
    Widget buildPin() {
      const pinColors = [
        Color(0xFFE53935),
        Color(0xFFFFB300),
        Color(0xFF43A047),
        Color(0xFF1E88E5),
        Color(0xFF8E24AA)
      ];
      final color = pinColors[rand.nextInt(pinColors.length)];
      return Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 3,
              offset: Offset(1, 2),
            ),
          ],
          gradient: RadialGradient(
            center: Alignment.bottomRight,
            radius: 1.0,
            colors: [
              color,
              color.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin: const EdgeInsets.only(top: 2, left: 2),
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    // Helper to generate paperclip
    Widget buildClip() {
      const clipColors = [
        Color(0xFFD4AF37),
        Color(0xFFFF7F50),
        Color(0xFF4169E1),
        Color(0xFF9DC183),
        Color(0xFF9370DB)
      ];
      final color = clipColors[rand.nextInt(clipColors.length)];
      return Positioned(
        top: -8,
        left: 12,
        child: Icon(
          Icons.attach_file_rounded, // Approximate visual for paperclip
          color: color,
          size: 24,
        ),
      );
    }

    switch (styleId) {
      case 1:
        return [
          buildTape(top: -4, left: 0, right: 0, width: 38)
        ]; // Need to center it manually
      case 2:
        return [
          buildTape(top: -3, left: -8, width: 32, angle: -35),
          buildTape(top: -3, right: -8, width: 32, angle: 35),
        ];
      case 3:
        return [buildClip()];
      case 4:
        return [
          Positioned(
            top: -5,
            left: 0,
            right: 0,
            child: Center(
              child: buildPin(),
            ),
          )
        ];
      case 5:
        return [
          Positioned(top: -4, left: 12, child: buildPin()),
          Positioned(top: -4, right: 12, child: buildPin()),
        ];
      default:
        return [];
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating Action Button
// ─────────────────────────────────────────────────────────────────────────────
class _Fab extends StatefulWidget {
  const _Fab();

  @override
  State<_Fab> createState() => _FabState();
}

class _FabState extends State<_Fab> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.90).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        HapticFeedback.selectionClick();
        context.push('/notepad/detail');
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.edit_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PDF Export Bottom Sheet (Dummy)
// ─────────────────────────────────────────────────────────────────────────────
class _PdfExportSheet extends ConsumerStatefulWidget {
  const _PdfExportSheet();

  @override
  ConsumerState<_PdfExportSheet> createState() => _PdfExportSheetState();
}

class _PdfExportSheetState extends ConsumerState<_PdfExportSheet> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider).valueOrNull ?? [];
    
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(24),
      ),
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
            'Export to PDF',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 22,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (notes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('No notes available to export.'),
            )
          else ...[
            SizedBox(
              height: 250,
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  final isSelected = _selected.contains(note.id);
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selected.add(note.id);
                        } else {
                          _selected.remove(note.id);
                        }
                      });
                    },
                    title: Text(
                      note.title,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    activeColor: AppTheme.primaryBlue,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selected.isEmpty
                    ? null
                    : () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Generating PDF...')),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Export selected'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton Shimmer
// ─────────────────────────────────────────────────────────────────────────────
class _NotesShimmer extends StatelessWidget {
  const _NotesShimmer();

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 24,
      crossAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        final heights = [140.0, 100.0, 180.0, 120.0];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: heights[index % heights.length],
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(height: 8),
            Container(height: 14, width: 100, color: AppTheme.divider),
            const SizedBox(height: 4),
            Container(height: 10, width: 60, color: AppTheme.divider),
          ],
        ).animate(onPlay: (c) => c.repeat()).shimmer(
              duration: 1200.ms,
              color: const Color(0x1A2D6BE4),
            );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 60),
          Text(
            'No notes yet',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 22,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the edit button to create your first note',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error State
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
          const SizedBox(height: 60),
          const Icon(Icons.error_outline_rounded,
              size: 48, color: AppTheme.textSecondary),
          const SizedBox(height: 12),
          Text(
            'Could not load notes',
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
