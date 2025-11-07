import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  final String doctorId;
  final String name;
  final String specialist;
  final String about;
  final Map<String, dynamic> availability;

  DoctorModel({
    required this.doctorId,
    required this.name,
    required this.specialist,
    required this.about,
    required this.availability,
  });

  factory DoctorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return DoctorModel(
      doctorId: doc.id,
      name: data?['name'] ?? 'N/A',
      specialist: data?['specialist'] ?? 'General',
      about: data?['about'] ?? 'No bio available.',
      availability: Map<String, dynamic>.from(data?['availability'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "specialist": specialist,
      "about": about,
      "availability": availability,
    };
  }
}