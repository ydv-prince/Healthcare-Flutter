import 'package:cloud_firestore/cloud_firestore.dart';

class DrugModel {
  final String drugId;
  final String name;
  final double price;
  final String description;
  final String quantityLabel; // Corresponds to your original 'Quantity' field (e.g., "75ml", "600mg")
  final int stock;

  DrugModel({
    required this.drugId,
    required this.name,
    required this.price,
    required this.description,
    required this.quantityLabel,
    required this.stock,
  });

  factory DrugModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return DrugModel(
      drugId: doc.id,
      name: data?['name'] ?? 'Unknown Drug',
      price: (data?['price'] ?? 0.0).toDouble(),
      description: data?['description'] ?? 'No description.',
      stock: (data?['stock'] ?? 0) as int,
      quantityLabel: data?['quantity_label'] ?? '', // Assuming you add this to your Firestore data
    );
  }
}