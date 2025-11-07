import 'package:cloud_firestore/cloud_firestore.dart';

class AmbulanceBookingModel {
  final String? bookingId;
  final String patientUid;
  final String typeId;
  final String patientName;
  final String phone;
  final String pickupLocation;
  final String destination;
  final String priority;
  final String emergencyDetails;
  final String status;
  final DateTime bookingTime;

  AmbulanceBookingModel({
    this.bookingId,
    required this.patientUid,
    required this.typeId,
    required this.patientName,
    required this.phone,
    required this.pickupLocation,
    required this.destination,
    required this.priority,
    this.emergencyDetails = '',
    this.status = 'searching', // Default status
    required this.bookingTime,
  });

  // ⚠️ NEW FACTORY CONSTRUCTOR REQUIRED TO FIX THE ERROR
  factory AmbulanceBookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    // Safely cast Timestamp to DateTime
    final bookingTimestamp = data?['booking_time'] as Timestamp?;

    return AmbulanceBookingModel(
      bookingId: doc.id,
      patientUid: data?['patient_uid'] ?? '',
      typeId: data?['type_id'] ?? 'N/A',
      patientName: data?['patient_name'] ?? 'Unknown',
      phone: data?['phone'] ?? '',
      pickupLocation: data?['pickup_location'] ?? 'N/A',
      destination: data?['destination'] ?? 'N/A',
      priority: data?['priority'] ?? 'Medium',
      emergencyDetails: data?['emergency_details'] ?? '',
      status: data?['status'] ?? 'pending',
      bookingTime: bookingTimestamp?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "patient_uid": patientUid,
      "type_id": typeId,
      "patient_name": patientName,
      "phone": phone,
      "pickup_location": pickupLocation,
      "destination": destination,
      "priority": priority,
      "emergency_details": emergencyDetails,
      "booking_time": Timestamp.fromDate(bookingTime),
      "status": status,
    };
  }
}