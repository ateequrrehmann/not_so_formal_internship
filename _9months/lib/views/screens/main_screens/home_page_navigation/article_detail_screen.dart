import 'package:flutter/material.dart';
import '../../../../models/article_model.dart';
class ArticleDetailPage extends StatelessWidget {
  final Article article;

  ArticleDetailPage({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(article.title)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Image.network(article.imageUrl),
            SizedBox(height: 8.0),
            Text(article.title, style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 8.0),
            Text(article.description, style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 16.0),
            // Display subheadings
            ...article.subheadings.map((subheading) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subheading.title, style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 8.0),
                  Text(subheading.details),
                  SizedBox(height: 8.0),
                  Center(child: Image.network(subheading.imageUrl)),
                  SizedBox(height: 8.0),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
