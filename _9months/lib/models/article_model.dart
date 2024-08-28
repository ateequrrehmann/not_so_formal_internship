import 'package:cloud_firestore/cloud_firestore.dart';

class Subheading {
  final String title;
  final String details;
  final String imageUrl;
  Subheading({
    required this.title,
    required this.details,
    required this.imageUrl,
  });
}


class Article {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final List<Subheading> subheadings;

  Article({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.subheadings,
  });

  factory Article.fromDocument(DocumentSnapshot doc) {
    // Parse the subheadings array
    var subheadingList = (doc['subheadings'] as List).map((item) {
      return Subheading(
        title: item['title'],
        details: item['details'],
        imageUrl: item['imageUrl'],
      );
    }).toList();

    return Article(
      id: doc.id,
      title: doc['title'],
      description: doc['description'],
      imageUrl: doc['imageUrl'],
      subheadings: subheadingList,
    );
  }
}
