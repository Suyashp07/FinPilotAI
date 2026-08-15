import '../domain/news_model.dart';
import 'services/news_service.dart';

class NewsRepository {
  final NewsService service = NewsService();

  Future<List<NewsModel>> fetchNews(String query) async {
    final response = await service.getNews(query);

    final List articles = response.data["articles"];

    return articles
        .map((e) => NewsModel.fromJson(e))
        .toList();
  }
}