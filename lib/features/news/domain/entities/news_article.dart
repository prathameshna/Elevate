/// A single news article entity.
class NewsArticle {
  final String id;
  final String title;
  final String summary;
  final String category; // "For You", "World", "Markets", etc.
  final String author;
  final String source;
  final String timeAgo;
  final String? imageUrl;
  final String? articleUrl;
  final String? relatedTitle;
  final String? relatedImageUrl;
  final bool isBookmarked;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.author,
    required this.source,
    required this.timeAgo,
    this.imageUrl,
    this.articleUrl,
    this.relatedTitle,
    this.relatedImageUrl,
    this.isBookmarked = false,
  });

  NewsArticle copyWith({
    String? id,
    String? title,
    String? summary,
    String? category,
    String? author,
    String? source,
    String? timeAgo,
    String? imageUrl,
    String? articleUrl,
    String? relatedTitle,
    String? relatedImageUrl,
    bool? isBookmarked,
  }) {
    return NewsArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      category: category ?? this.category,
      author: author ?? this.author,
      source: source ?? this.source,
      timeAgo: timeAgo ?? this.timeAgo,
      imageUrl: imageUrl ?? this.imageUrl,
      articleUrl: articleUrl ?? this.articleUrl,
      relatedTitle: relatedTitle ?? this.relatedTitle,
      relatedImageUrl: relatedImageUrl ?? this.relatedImageUrl,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}
