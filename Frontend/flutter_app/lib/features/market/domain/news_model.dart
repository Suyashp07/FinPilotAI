class NewsModel {
  final String title;
  final String description;
  final String imageUrl;
  final String source;
  final String publishedAt;
  final String url;

  NewsModel({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.source,
    required this.publishedAt,
    required this.url,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      imageUrl: json["image"] ?? "",
      source: json["source"]["name"] ?? "",
      publishedAt: json["publishedAt"] ?? "",
      url: json["url"] ?? "",
    );
  }
}