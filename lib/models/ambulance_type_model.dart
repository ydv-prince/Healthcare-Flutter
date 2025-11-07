import 'package:cloud_firestore/cloud_firestore.dart';

class AmbulanceTypeModel {
  final String typeId;
  final String name;
  final List<String> features;
  final double baseFare;

  AmbulanceTypeModel({
    required this.typeId,
    required this.name,
    required this.features,
    required this.baseFare,
  });

  factory AmbulanceTypeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return AmbulanceTypeModel(
      typeId: doc.id,
      name: data?['name'] ?? 'Unknown Type',
      baseFare: (data?['base_fare'] ?? 0.0).toDouble(),
      features: (data?['features'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}