import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:elevate/features/news/domain/entities/news_article.dart';
import 'package:elevate/features/news/domain/repositories/news_repository.dart';

class NewsRepositoryImpl implements NewsRepository {
  Set<String> get _bookmarked {
    final box = Hive.box('newsBox');
    final saved = box.get('bookmarks');
    return saved != null ? Set<String>.from(saved as List) : {};
  }

  Future<void> _saveBookmarks(Set<String> bookmarks) async {
    final box = Hive.box('newsBox');
    await box.put('bookmarks', bookmarks.toList());
  }

  static final _articles = [
    const NewsArticle(
      id: '1',
      title: 'Trump warns Netanyahu that US may leave Israel alone against Iran',
      summary:
          'United States President Donald Trump said that US may leave Israel alone against Iran if it resumed the war against Iran. "I said, \'Bibi, you better be careful\'," Trump said. This comes as Israel defied Trump\'s request and retaliated against Iranian strikes.',
      category: 'World News',
      author: 'Bhuvnesh Ojha',
      source: 'The Indian Express',
      timeAgo: '4 hours ago',
      articleUrl: 'https://indianexpress.com',
      relatedTitle: 'Energy crisis: The hidden cost of training AI',
    ),
    const NewsArticle(
      id: '2',
      title: 'India\'s GDP growth surprises analysts at 7.8% in Q1 2025',
      summary:
          'India\'s economy expanded at 7.8% in the first quarter of 2025, beating analyst forecasts of 7.2%. Strong domestic consumption and rising exports in manufacturing and IT services drove the surprise uptick.',
      category: 'Markets',
      author: 'Priya Sharma',
      source: 'Economic Times',
      timeAgo: '2 hours ago',
      articleUrl: 'https://economictimes.com',
    ),
    const NewsArticle(
      id: '3',
      title: 'OpenAI releases GPT-5 with real-time reasoning capabilities',
      summary:
          'OpenAI has released its next-generation model GPT-5, featuring multi-modal reasoning, live web search, and significantly improved performance on complex STEM tasks. The model is now available via API for enterprise customers.',
      category: 'Science & AI',
      author: 'Marcus Chen',
      source: 'The Verge',
      timeAgo: '6 hours ago',
      articleUrl: 'https://theverge.com',
      relatedTitle: 'Gemini Ultra 2.0 to launch next quarter',
    ),
    const NewsArticle(
      id: '4',
      title: 'Daily meditation for 10 minutes rewires the brain, study finds',
      summary:
          'A new study from Harvard Medical School found that just 10 minutes of daily mindfulness meditation causes measurable changes in the prefrontal cortex and amygdala after 8 weeks, improving stress resilience and focus.',
      category: 'Daily Ritual',
      author: 'Dr. Ananya Rao',
      source: 'Harvard Health',
      timeAgo: '1 day ago',
      articleUrl: 'https://health.harvard.edu',
    ),
    const NewsArticle(
      id: '5',
      title: 'Federer foundation opens 100 new schools across East Africa',
      summary:
          'The Roger Federer Foundation has announced the opening of 100 new primary schools across Tanzania, Kenya, and Mozambique as part of its 2025 education initiative, bringing quality education to over 60,000 children.',
      category: 'World',
      author: 'Sophie Laurent',
      source: 'Reuters',
      timeAgo: '8 hours ago',
      articleUrl: 'https://reuters.com',
    ),
    const NewsArticle(
      id: '6',
      title: 'Virat Kohli breaks Sachin\'s ODI century record with a sublime 105',
      summary:
          'Virat Kohli scored a flawless century against Australia in the first ODI in Mumbai, breaking Sachin Tendulkar\'s all-time record of 49 ODI centuries. The Indian captain reached the milestone in just 87 balls.',
      category: 'Sports',
      author: 'Ramesh Gupta',
      source: 'Cricinfo',
      timeAgo: '3 hours ago',
      articleUrl: 'https://espncricinfo.com',
      relatedTitle: 'Kohli announces limited-overs captaincy extension',
    ),
  ];

  @override
  Future<List<NewsArticle>> getArticles({String? category}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var list = _articles.map((a) {
      return _bookmarked.contains(a.id) ? a.copyWith(isBookmarked: true) : a;
    }).toList();

    if (category == null ||
        category == 'For You' ||
        category == 'Daily Ritual') {
      return list;
    }
    return list.where((a) => a.category == category).toList();
  }

  @override
  Future<void> bookmarkArticle(String id) async {
    final b = _bookmarked;
    b.add(id);
    await _saveBookmarks(b);
  }

  @override
  Future<void> unbookmarkArticle(String id) async {
    final b = _bookmarked;
    b.remove(id);
    await _saveBookmarks(b);
  }

  @override
  Future<List<NewsArticle>> getBookmarkedArticles() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _articles
        .where((a) => _bookmarked.contains(a.id))
        .map((a) => a.copyWith(isBookmarked: true))
        .toList();
  }

  /// Helper to resolve category badge color pair.
  static (Color bg, Color text) categoryColors(
      String category, BuildContext context) {
    switch (category.toLowerCase()) {
      case 'world news':
      case 'world':
        return (const Color(0xFFFFDAD6), const Color(0xFF93000A));
      case 'markets':
        return (const Color(0xFFEEF2FF), const Color(0xFF3730A3));
      case 'science & ai':
        return (const Color(0xFFECFDF5), const Color(0xFF065F46));
      case 'sports':
        return (const Color(0xFFFFF7ED), const Color(0xFFC2410C));
      case 'daily ritual':
        return (const Color(0xFFF0F9FF), const Color(0xFF0369A1));
      default:
        return (const Color(0xFFF3F4F6), const Color(0xFF374151));
    }
  }

  static Color categoryBg(String category) {
    switch (category.toLowerCase()) {
      case 'world news':
      case 'world':
        return const Color(0xFFFCEBEB);
      case 'markets':
        return const Color(0xFFEBF3FC);
      case 'science & ai':
        return const Color(0xFFEBFCF4);
      case 'sports':
        return const Color(0xFFFFF3E0);
      case 'daily ritual':
        return const Color(0xFFF0F0FF);
      default:
        return const Color(0xFFF5F5F7);
    }
  }
}
