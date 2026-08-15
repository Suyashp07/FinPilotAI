import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/news_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/featured_news_card.dart';
import '../widgets/news_card.dart';
import '../widgets/search_bar.dart';

class MarketScreen extends ConsumerWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsProvider);
    final search = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Market Insights"),
        centerTitle: false,
      ),

      body: newsAsync.when(
        data: (news) {
          final filteredNews = news.where((item) {
            final query = search.toLowerCase();

            return item.title.toLowerCase().contains(query) ||
                item.description.toLowerCase().contains(query) ||
                item.source.toLowerCase().contains(query);
          }).toList();

          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },

            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(newsProvider);
                await ref.read(newsProvider.future);
              },

              child: ListView(
                padding: const EdgeInsets.all(16),

                children: [
                  const MarketSearchBar(),

                  const SizedBox(height: 15),

                  const SingleChildScrollView(
                    scrollDirection: Axis.horizontal,

                    child: Row(
                      children: [
                        CategoryChip(title: "All"),
                        CategoryChip(title: "Business"),
                        CategoryChip(title: "Stocks"),
                        CategoryChip(title: "Startup"),
                        CategoryChip(title: "Economy"),
                        CategoryChip(title: "RBI"),
                        CategoryChip(title: "Crypto"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (filteredNews.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),

                        child: Text(
                          "No news found",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    FeaturedNewsCard(
                      news: filteredNews.first,
                    ),

                    const SizedBox(height: 20),

                    ...filteredNews.skip(1).map(
                      (item) => NewsCard(
                        news: item,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },

        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),

        error: (error, stackTrace) => Center(
          child: Text(
            "Error: $error",
          ),
        ),
      ),
    );
  }
}