import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String? appointmentId; // Null for new bookings
  final String patientUid;
  final String doctorId;
  final String patientName;
  final String problem;
  final DateTime date;
  final String time;
  final String status;

  AppointmentModel({
    this.appointmentId,
    required this.patientUid,
    required this.doctorId,
    required this.patientName,
    required this.problem,
    required this.date,
    required this.time,
    required this.status,
  });

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return AppointmentModel(
      appointmentId: doc.id,
      patientUid: data?['patient_uid'] ?? '',
      doctorId: data?['doctor_id'] ?? '',
      patientName: data?['patient_name'] ?? 'Unknown',
      problem: data?['problem'] ?? '',
      date: (data?['date'] as Timestamp).toDate(),
      time: data?['time'] ?? '',
      status: data?['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "patient_uid": patientUid,
      "doctor_id": doctorId,
      "patient_name": patientName,
      "problem": problem,
      "date": Timestamp.fromDate(date), // Convert DateTime to Firestore Timestamp
      "time": time,
      "status": status,
    };
  }
}