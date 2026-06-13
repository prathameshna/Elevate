import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:elevate/core/theme/app_theme.dart';
import 'package:elevate/features/news/data/repositories/news_repository_impl.dart';
import 'package:elevate/features/news/domain/entities/news_article.dart';
import 'package:elevate/features/news/presentation/providers/news_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// News Feed Page
// ─────────────────────────────────────────────────────────────────────────────
class NewsFeedPage extends ConsumerStatefulWidget {
  const NewsFeedPage({super.key});

  @override
  ConsumerState<NewsFeedPage> createState() => _NewsFeedPageState();
}

class _NewsFeedPageState extends ConsumerState<NewsFeedPage> {
  final PageController _pageCtrl = PageController();
  double _scrollFraction = 0.0;

  static const _tabs = [
    'For You',
    'Daily Ritual',
    'World Brief',
    'Markets',
    'Science & AI',
    'World',
    'Sports',
    'Bookmarks',
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl.addListener(() {
      if (_pageCtrl.position.hasContentDimensions &&
          _pageCtrl.position.maxScrollExtent > 0) {
        setState(() {
          _scrollFraction =
              _pageCtrl.offset / _pageCtrl.position.maxScrollExtent;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final articlesAsync = ref.watch(newsProvider);
    final activeCategory = ref.watch(newsCategoryProvider);

    return Scaffold(
      backgroundColor: AppTheme.cardWhite,
      body: Stack(
        children: [
          Column(
            children: [
              // ── Top tab bar (fixed) ─────────────────────────────────
              _TopTabBar(
                tabs: _tabs,
                activeTab: activeCategory,
                onTabSelected: (tab) {
                  ref.read(newsCategoryProvider.notifier).state = tab;
                  _pageCtrl.jumpToPage(0);
                },
                onBack: () {
                  HapticFeedback.selectionClick();
                  context.pop();
                },
              ).animate().slideY(
                    begin: -1,
                    end: 0,
                    duration: 250.ms,
                    curve: Curves.easeOutCubic,
                  ),
              // ── Article feed ────────────────────────────────────────
              Expanded(
                child: articlesAsync.when(
                  loading: () => const _NewsShimmer(),
                  error: (err, _) => _ErrorState(
                    onRetry: () => ref.invalidate(newsProvider),
                  ),
                  data: (articles) => articles.isEmpty
                      ? _EmptyState(category: activeCategory)
                      : _ArticleFeed(
                          articles: articles,
                          pageCtrl: _pageCtrl,
                          onBookmark: (id) => ref
                              .read(newsProvider.notifier)
                              .toggleBookmark(id),
                        ),
                ),
              ),
            ],
          ),

          // ── Scroll position indicator (right edge) ──────────────────
          Positioned(
            right: 4,
            top: 56 +
                16 +
                (_scrollFraction *
                    (MediaQuery.of(context).size.height - 56 - 40 - 16)),
            child: Container(
              width: 2,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top Category Tab Bar
// ─────────────────────────────────────────────────────────────────────────────
class _TopTabBar extends StatelessWidget {
  final List<String> tabs;
  final String activeTab;
  final ValueChanged<String> onTabSelected;
  final VoidCallback onBack;

  const _TopTabBar({
    required this.tabs,
    required this.activeTab,
    required this.onTabSelected,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56 + MediaQuery.of(context).padding.top,
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        border: const Border(
          bottom: BorderSide(color: Color(0x14000000), width: 0.5),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Row(
          children: [
            // Back button
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 48,
                height: 56,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 22,
                  color: AppTheme.textSecondary,
                ),
              )
                  .animate(target: 0)
                  .scale(
                    begin: const Offset(0.92, 0.92),
                    end: const Offset(1, 1),
                    duration: 80.ms,
                  ),
            ),
            // Scrollable tabs
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 4),
                itemCount: tabs.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: 24),
                itemBuilder: (ctx, i) {
                  final tab = tabs[i];
                  final isActive = tab == activeTab;
                  return GestureDetector(
                    onTap: () => onTabSelected(tab),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isActive
                                ? AppTheme.primaryBlue
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 180),
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: isActive
                              ? AppTheme.primaryBlue
                              : AppTheme.textSecondary,
                        ),
                        child: Text(tab),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Article Feed — vertical page snap
// ─────────────────────────────────────────────────────────────────────────────
class _ArticleFeed extends StatelessWidget {
  final List<NewsArticle> articles;
  final PageController pageCtrl;
  final ValueChanged<String> onBookmark;

  const _ArticleFeed({
    required this.articles,
    required this.pageCtrl,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: 180.ms,
      child: PageView.builder(
        key: ValueKey(articles.length),
        controller: pageCtrl,
        scrollDirection: Axis.vertical,
        physics: const PageScrollPhysics(),
        itemCount: articles.length,
        itemBuilder: (ctx, i) {
          return _ArticleCard(
            article: articles[i],
            onBookmark: () => onBookmark(articles[i].id),
          )
              .animate()
              .fadeIn(
                delay: i == 0 ? 0.ms : 0.ms,
                duration: i == 0 ? 300.ms : 200.ms,
                curve: Curves.easeOutCubic,
              );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single Article Card (fills one full page)
// ─────────────────────────────────────────────────────────────────────────────
class _ArticleCard extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onBookmark;

  const _ArticleCard({
    required this.article,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final hasRelated = article.relatedTitle != null;
    final imageBg = NewsRepositoryImpl.categoryBg(article.category);
    final (badgeBg, badgeText) =
        NewsRepositoryImpl.categoryColors(article.category, context);

    return Container(
      color: AppTheme.cardWhite,
      child: Column(
        children: [
          // ── Top image area 52% ─────────────────────────────────────
          Flexible(
            flex: 52,
            child: _ImageArea(
              backgroundBg: imageBg,
              imageUrl: article.imageUrl,
              category: article.category,
              onMenuTap: () => _showMenuSheet(context, article),
            ),
          ),
          // ── Bottom content area 48% ────────────────────────────────
          Flexible(
            flex: 48,
            child: _ContentArea(
              article: article,
              badgeBg: badgeBg,
              badgeText: badgeText,
              hasRelated: hasRelated,
              onBookmark: onBookmark,
            ),
          ),
        ],
      ),
    );
  }

  void _showMenuSheet(BuildContext ctx, NewsArticle article) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => _MenuSheet(article: article),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Image Area — top 52%
// ─────────────────────────────────────────────────────────────────────────────
class _ImageArea extends StatelessWidget {
  final Color backgroundBg;
  final String? imageUrl;
  final String category;
  final VoidCallback onMenuTap;

  const _ImageArea({
    required this.backgroundBg,
    required this.imageUrl,
    required this.category,
    required this.onMenuTap,
  });

  IconData _categoryIcon() {
    switch (category.toLowerCase()) {
      case 'world news':
      case 'world':
        return Icons.public_rounded;
      case 'markets':
        return Icons.trending_up_rounded;
      case 'science & ai':
        return Icons.biotech_rounded;
      case 'sports':
        return Icons.sports_cricket_rounded;
      case 'daily ritual':
        return Icons.self_improvement_rounded;
      default:
        return Icons.article_outlined;
    }
  }

  Color _iconColor() {
    switch (category.toLowerCase()) {
      case 'world news':
      case 'world':
        return const Color(0xFFA32D2D);
      case 'markets':
        return AppTheme.primaryBlue;
      case 'science & ai':
        return const Color(0xFF065F46);
      case 'sports':
        return const Color(0xFFC2410C);
      case 'daily ritual':
        return const Color(0xFF0369A1);
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: backgroundBg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Placeholder icon
          Center(
            child: Icon(
              _categoryIcon(),
              size: 80,
              color: _iconColor().withValues(alpha: 0.2),
            ),
          ),
          // ── 3-dot menu button ─────────────────────────────────────
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: onMenuTap,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  Icons.more_vert_rounded,
                  size: 20,
                  color: _iconColor(),
                ),
              ),
            ),
          ),
          // ── Branding pill — bottom left ───────────────────────────
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0x14000000),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'E',
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ELEVATE NEWS',
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Content Area — bottom 48%
// ─────────────────────────────────────────────────────────────────────────────
class _ContentArea extends StatelessWidget {
  final NewsArticle article;
  final Color badgeBg;
  final Color badgeText;
  final bool hasRelated;
  final VoidCallback onBookmark;

  const _ContentArea({
    required this.article,
    required this.badgeBg,
    required this.badgeText,
    required this.hasRelated,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.cardWhite,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 70),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Category badge ──────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    article.category.toUpperCase(),
                    style: GoogleFonts.dmSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: badgeText,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // ── Headline ────────────────────────────────────────
                Text(
                  article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 20,
                    color: AppTheme.textPrimary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),
                // ── Summary ─────────────────────────────────────────
                Expanded(
                  child: Text(
                    article.summary,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // ── Meta row ────────────────────────────────────────
                Row(
                  children: [
                    Text(
                      article.timeAgo.toUpperCase(),
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        color: AppTheme.textTertiary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const _Dot(),
                    Text(
                      article.author.toUpperCase(),
                      style: GoogleFonts.dmSans(
                        fontSize: 9,
                        color: AppTheme.textTertiary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const _Dot(),
                    Flexible(
                      child: Text(
                        article.source.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          color: AppTheme.textTertiary,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Action row (pinned bottom) ───────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: hasRelated ? 64 : 0,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                color: AppTheme.cardWhite,
                border: Border(
                  top: BorderSide(color: Color(0x14000000), width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  // Read full article
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      // In production: launch URL or WebView
                    },
                    child: Row(
                      children: [
                        Text(
                          'Read full article',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: AppTheme.primaryBlue,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Bookmark
                  _BookmarkButton(
                    isBookmarked: article.isBookmarked,
                    onTap: onBookmark,
                  ),
                  const SizedBox(width: 20),
                  // Share
                  GestureDetector(
                    onTap: () => HapticFeedback.selectionClick(),
                    child: const Icon(
                      Icons.share_outlined,
                      size: 22,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Related story strip ──────────────────────────────────
          if (hasRelated)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _RelatedStoryStrip(
                title: article.relatedTitle!,
                category: article.category,
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bookmark Button with spring animation
// ─────────────────────────────────────────────────────────────────────────────
class _BookmarkButton extends StatefulWidget {
  final bool isBookmarked;
  final VoidCallback onTap;

  const _BookmarkButton({
    required this.isBookmarked,
    required this.onTap,
  });

  @override
  State<_BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<_BookmarkButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.selectionClick();
    _ctrl.forward().then((_) => _ctrl.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          child: Icon(
            widget.isBookmarked
                ? Icons.bookmark_rounded
                : Icons.bookmark_border_rounded,
            key: ValueKey(widget.isBookmarked),
            size: 22,
            color: widget.isBookmarked
                ? AppTheme.primaryBlue
                : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Related Story Strip — dark bar at bottom
// ─────────────────────────────────────────────────────────────────────────────
class _RelatedStoryStrip extends StatelessWidget {
  final String title;
  final String category;

  const _RelatedStoryStrip({required this.title, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: AppTheme.textPrimary,
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D2A),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.bolt_rounded,
              size: 20,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RELATED STORY',
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.6),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Chevron button
          GestureDetector(
            onTap: () => HapticFeedback.selectionClick(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3-dot menu bottom sheet
// ─────────────────────────────────────────────────────────────────────────────
class _MenuSheet extends StatelessWidget {
  final NewsArticle article;

  const _MenuSheet({required this.article});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
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
          const SizedBox(height: 16),
          _SheetTile(
            icon: Icons.thumb_down_outlined,
            label: 'Not interested',
            onTap: () => Navigator.pop(context),
          ),
          _SheetTile(
            icon: Icons.flag_outlined,
            label: 'Report',
            onTap: () => Navigator.pop(context),
          ),
          _SheetTile(
            icon: Icons.link_rounded,
            label: 'Copy link',
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 20, color: AppTheme.textSecondary),
      title: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      onTap: onTap,
      dense: true,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Skeleton shimmer
// ─────────────────────────────────────────────────────────────────────────────
class _NewsShimmer extends StatelessWidget {
  const _NewsShimmer();

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height - 56;
    return Column(
      children: [
        // Image shimmer
        Container(
          height: h * 0.52,
          width: double.infinity,
          color: AppTheme.divider,
        )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(
              duration: 1200.ms,
              color: const Color(0x1A2D6BE4),
            ),
        // Content shimmer
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 20, width: 80, color: AppTheme.divider)
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 1200.ms),
                const SizedBox(height: 16),
                Container(
                    height: 26, width: double.infinity, color: AppTheme.divider)
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 1200.ms),
                const SizedBox(height: 8),
                Container(
                    height: 26, width: 220, color: AppTheme.divider)
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 1200.ms),
                const SizedBox(height: 16),
                ...List.generate(
                  4,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      height: 14,
                      width: double.infinity,
                      color: AppTheme.divider,
                    )
                        .animate(onPlay: (c) => c.repeat())
                        .shimmer(duration: 1200.ms),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String category;
  const _EmptyState({required this.category});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.newspaper_rounded,
              size: 28,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            category == 'Bookmarks'
                ? 'No saved articles'
                : 'No articles in $category',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 18,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            category == 'Bookmarks'
                ? 'Bookmark articles to read them later'
                : 'Check back soon for updates',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms).scale(
          begin: const Offset(0.92, 0.92), end: const Offset(1, 1)),
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
            'Could not load news',
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
// Dot separator in meta row
// ─────────────────────────────────────────────────────────────────────────────
class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: const BoxDecoration(
        color: AppTheme.textTertiary,
        shape: BoxShape.circle,
      ),
    );
  }
}
