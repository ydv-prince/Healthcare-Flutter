import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String? phone;
  // Note: We use Map<String, dynamic> for safety when reading from Firestore
  final List<Map<String, dynamic>> emergencyContacts; 

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.emergencyContacts = const [], // Initialize with an empty list for safety
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    
    // Default Map to handle null safety more cleanly
    final safeData = data ?? {}; 

    // Safely cast complex array fields
    final List<dynamic> rawContacts = safeData['emergency_contacts'] ?? [];

    return UserModel(
      uid: doc.id,
      name: safeData['name'] ?? 'Guest User',
      email: safeData['email'] ?? '',
      role: safeData['role'] ?? 'patient',
      phone: safeData['phone'] as String?,
      
      emergencyContacts: rawContacts
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }
}