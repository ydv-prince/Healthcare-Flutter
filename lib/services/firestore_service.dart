import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart'; 
import '../models/drug_model.dart';
import '../models/doctor_model.dart';
import '../models/appointment_model.dart';
import '../models/ambulance_type_model.dart';
import '../models/ambulance_booking_model.dart';
import '../models/notification_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =================================================================
  // 1. USER PROFILE OPERATIONS (Collection: 'users')
  // =================================================================

  /// Retrieves a user's profile data from Firestore using their UID.
  Future<UserModel> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();

    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    } else {
      throw Exception('User profile not found in Firestore for UID: $uid');
    }
  }

  /// Updates a specific field in the user's profile (e.g., phone, emergency contacts).
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // =================================================================
  // 2. DOCTOR OPERATIONS (Collection: 'doctors')
  // =================================================================

  /// Retrieves a real-time stream of all available doctors.
  Stream<List<DoctorModel>> getDoctors() {
    return _db
        .collection('doctors')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => DoctorModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Retrieves a specific doctor by ID.
  Future<DoctorModel> getDoctorById(String doctorId) async {
    final doc = await _db.collection('doctors').doc(doctorId).get();
    if (doc.exists) {
      return DoctorModel.fromFirestore(doc);
    } else {
      throw Exception('Doctor not found with ID: $doctorId');
    }
  }

  // =================================================================
  // 3. APPOINTMENT OPERATIONS (Collection: 'appointments')
  // =================================================================

  /// Books a new appointment. Uses add() to let Firestore generate the ID.
  Future<void> bookAppointment(AppointmentModel appointment) async {
    await _db.collection('appointments').add(appointment.toFirestore());
  }

  /// Updates the status of a specific appointment.
  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    await _db.collection('appointments').doc(appointmentId).update({
      'status': status,
    });
  }

  /// Retrieves a stream of appointments for a specific user (patient history).
  Stream<List<AppointmentModel>> getPatientAppointments(String patientUid) {
    return _db
        .collection('appointments')
        .where('patient_uid', isEqualTo: patientUid)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AppointmentModel.fromFirestore(doc))
              .toList(),
        );
  }

  // =================================================================
  // 4. PHARMACY/ORDER OPERATIONS (Collections: 'pharmacy_drugs', 'orders')
  // =================================================================

  /// Retrieves a real-time stream of all available drugs.
  Stream<List<DrugModel>> getDrugs() {
    return _db
        .collection('pharmacy_drugs')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => DrugModel.fromFirestore(doc)).toList(),
        );
  }

  /// Places a new order in the 'orders' collection.
  // ⚠️ THIS WAS THE MISSING METHOD REQUIRED BY buyNowPage.dart
  Future<void> placeOrder(Map<String, dynamic> orderData) async {
    await _db.collection('orders').add(orderData);
  }

  // =================================================================
  // 5. AMBULANCE OPERATIONS (Collection: 'ambulance_bookings')
  // =================================================================
  
  /// Retrieves a real-time stream of all available ambulance types.
  Stream<List<AmbulanceTypeModel>> getAmbulanceTypes() {
    return _db.collection('ambulance_types')
        .snapshots()
        .map((snapshot) => 
          snapshot.docs.map((doc) => AmbulanceTypeModel.fromFirestore(doc)).toList()
        );
  }
  
  /// Places a new ambulance booking.
  Future<void> bookAmbulance(AmbulanceBookingModel booking) async {
    await _db.collection('ambulance_bookings').add(booking.toFirestore());
  }

  /// Retrieves a stream of ambulance bookings for a specific user.
Stream<List<AmbulanceBookingModel>> getPatientAmbulanceBookings(String patientUid) {
  return _db
      .collection('ambulance_bookings')
      .where('patient_uid', isEqualTo: patientUid)
      .orderBy('booking_time', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => AmbulanceBookingModel.fromFirestore(doc))
            .toList(),
      );
}

/// Updates the status of a specific ambulance booking.
Future<void> updateAmbulanceStatus(String bookingId, String status) async {
  await _db.collection('ambulance_bookings').doc(bookingId).update({
    'status': status,
  });
}

// =================================================================
  // 6. NOTIFICATION OPERATIONS (Collection: 'notifications')
  // =================================================================

  /// Retrieves a stream of notifications for a specific user, sorted by date.
  Stream<List<NotificationModel>> getPatientNotifications(String patientUid) {
    return _db.collection('notifications')
        .where('user_uid', isEqualTo: patientUid)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Marks a specific notification as read.
  Future<void> markNotificationAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({
      'is_read': true,
    });
  }
  
  /// Deletes a specific notification.
  Future<void> deleteNotification(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).delete();
  }
}
