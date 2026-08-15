import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NewsService {
  final Dio dio = Dio();

  final String apiKey = dotenv.env["GNEWS_API_KEY"]!;

  Future<Response> getNews(String query) async {
    return await dio.get(
      "https://gnews.io/api/v4/search",
      queryParameters: {
        "q": query,
        "lang": "en",
        "country": "in",
        "max": 10,
        "apikey": apiKey,
      },
    );
  }
}