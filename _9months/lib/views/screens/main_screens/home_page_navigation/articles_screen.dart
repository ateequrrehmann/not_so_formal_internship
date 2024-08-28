import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/future_provider/article_provider.dart';
import 'article_detail_screen.dart';

class ArticlesPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Size size = MediaQuery.of(context).size; // Get screen size
    final articlesAsyncValue = ref.watch(articlesProvider);

    return Scaffold(
      backgroundColor: Color(0xFFE9EBEB),
      appBar: AppBar(
        title: Text('Articles'),
        backgroundColor: Color(0xFFE9EBEB),
        elevation: 0, // Optional: Remove shadow for a flat look
      ),
      body: articlesAsyncValue.when(
        data: (articles) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return GestureDetector(
                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticleDetailPage(article: article),
                      ),
                    );
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0), // Add spacing between cards
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        Container(
                          width: double.infinity,
                          height: size.width * 0.4, // Set height to 40% of screen width
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                            image: DecorationImage(
                              image: NetworkImage(article.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Title and Description
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                article.title,
                                style: Theme.of(context).textTheme.titleLarge,
                                overflow: TextOverflow.visible, // Ensure title is fully visible
                              ),
                              SizedBox(height: 4.0),
                              // Description
                              Text(
                                article.description,
                                style: Theme.of(context).textTheme.titleMedium,
                                maxLines: 3, // Limit number of lines for description
                                overflow: TextOverflow.ellipsis, // Handle overflow gracefully
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
