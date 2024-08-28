import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/article_model.dart';

final articlesProvider = FutureProvider<List<Article>>((ref) async {
  final firestore = FirebaseFirestore.instance;

  try {
    // Fetch articles from the 'articles' collection
    final querySnapshot = await firestore.collection('articles').get();

    //   Convert Firestore documents to Article models
    final articles = querySnapshot.docs.map((doc) {
      return Article.fromDocument(doc);
    }).toList();

    return articles;
  } catch (e) {
    throw Exception('Failed to load articles: $e');
  }
});
