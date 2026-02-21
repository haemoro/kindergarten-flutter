class CenterReview {
  final String title;
  final String link;
  final String snippet;
  final String source;
  final DateTime? postDate;

  const CenterReview({
    required this.title,
    required this.link,
    required this.snippet,
    required this.source,
    this.postDate,
  });

  factory CenterReview.fromJson(Map<String, dynamic> json) {
    return CenterReview(
      title: json['title'] ?? '',
      link: json['link'] ?? '',
      snippet: json['snippet'] ?? '',
      source: json['source'] ?? '',
      postDate: json['postDate'] != null
          ? DateTime.tryParse(json['postDate'])
          : null,
    );
  }

  bool get isBlog => source == 'blog';
  bool get isCafe => source == 'cafe';
}
