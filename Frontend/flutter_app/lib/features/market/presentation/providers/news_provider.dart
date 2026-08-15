import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/news_repository.dart';
import '../../domain/news_model.dart';
import 'category_provider.dart';

final newsProvider = FutureProvider<List<NewsModel>>((ref) async {
  final category = ref.watch(categoryProvider);

  String query;

  switch (category) {
    case "Stocks":
      query = "stock market";
      break;

    case "Startup":
      query = "startup";
      break;

    case "Economy":
      query = "economy";
      break;

    case "RBI":
      query = "RBI";
      break;

    case "Crypto":
      query = "cryptocurrency";
      break;

    default:
      query = "business";
  }

  return NewsRepository().fetchNews(query);
});