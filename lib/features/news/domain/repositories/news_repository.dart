import 'package:elevate/features/news/domain/entities/news_article.dart';

abstract class NewsRepository {
  Future<List<NewsArticle>> getArticles({String? category});
  Future<void> bookmarkArticle(String id);
  Future<void> unbookmarkArticle(String id);
  Future<List<NewsArticle>> getBookmarkedArticles();
}
