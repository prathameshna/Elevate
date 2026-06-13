import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:elevate/features/news/data/repositories/news_repository_impl.dart';
import 'package:elevate/features/news/domain/entities/news_article.dart';
import 'package:elevate/features/news/domain/repositories/news_repository.dart';

// ── Repository ───────────────────────────────────────────────────────────────
final newsRepositoryProvider = Provider<NewsRepository>(
  (_) => NewsRepositoryImpl(),
);

// ── Active category ──────────────────────────────────────────────────────────
final newsCategoryProvider = StateProvider<String>((ref) => 'For You');

// ── Bookmarks ───────────────────────────────────────────────────────────────
final bookmarkedArticlesProvider =
    NotifierProvider<BookmarkedArticlesNotifier, Set<String>>(
        BookmarkedArticlesNotifier.new);

class BookmarkedArticlesNotifier extends Notifier<Set<String>> {
  late final Box _box;

  @override
  Set<String> build() {
    _box = Hive.box('newsBox');
    final saved = _box.get('bookmarks');
    if (saved != null) {
      return Set<String>.from(saved as List);
    }
    return {};
  }

  void toggleBookmark(String id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state, id};
    }
    _box.put('bookmarks', state.toList());
  }
}

// ── Article list notifier ────────────────────────────────────────────────────
class NewsNotifier extends AsyncNotifier<List<NewsArticle>> {
  @override
  Future<List<NewsArticle>> build() async {
    final category = ref.watch(newsCategoryProvider);
    final repo = ref.read(newsRepositoryProvider);
    if (category == 'Bookmarks') {
      return repo.getBookmarkedArticles();
    }
    return repo.getArticles(
      category: category == 'For You' ? null : category,
    );
  }

  Future<void> toggleBookmark(String id) async {
    final repo = ref.read(newsRepositoryProvider);
    final current = state.valueOrNull ?? [];
    final article = current.firstWhere((a) => a.id == id);

    // Optimistic update
    state = AsyncData(
      current.map((a) {
        return a.id == id ? a.copyWith(isBookmarked: !a.isBookmarked) : a;
      }).toList(),
    );

    ref.read(bookmarkedArticlesProvider.notifier).toggleBookmark(id);

    if (article.isBookmarked) {
      await repo.unbookmarkArticle(id);
    } else {
      await repo.bookmarkArticle(id);
    }
  }
}

final newsProvider =
    AsyncNotifierProvider<NewsNotifier, List<NewsArticle>>(NewsNotifier.new);
