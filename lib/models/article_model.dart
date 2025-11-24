import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleModel {
  final String id;
  final String title;
  final String imageUrl;
  final String bodyContent; // The main text containing symptoms, precautions, etc.
  final String category; // e.g., 'Infectious', 'Chronic', 'Preventive'
  final DateTime publishedDate;

  ArticleModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.bodyContent,
    required this.category,
    required this.publishedDate,
  });

  factory ArticleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return ArticleModel(
      id: doc.id,
      title: data?['title'] ?? 'No Title',
      imageUrl: data?['image_url'] ?? '',
      bodyContent: data?['body_content'] ?? 'No content available.',
      category: data?['category'] ?? 'General',
      publishedDate: (data?['published_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}