import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../models/doctor_model.dart';
import '../models/appointment_model.dart';
import '../models/article_model.dart';
import '../models/drug_model.dart';
import '../models/ambulance_type_model.dart';
import '../models/ambulance_booking_model.dart';
import '../models/notification_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const String CLOUDINARY_CLOUD_NAME = 'dgjicomko';
  static const String CLOUDINARY_UPLOAD_PRESET = 'profile_picture';
  static const String CLOUDINARY_URL = 
    'https://api.cloudinary.com/v1_1/$CLOUDINARY_CLOUD_NAME/image/upload';

  // =================================================================
  // 1. USER & PROFILE OPERATIONS (FIXED ERRORS HERE)
  // =================================================================

  Future<UserModel> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw Exception("User data not found for UID: $uid");
    }
    return UserModel.fromFirestore(doc);
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> updateMap) async {
    await _db.collection('users').doc(uid).update(updateMap);
  }

  Future<String> uploadProfilePicture(String uid, File imageFile) async {
    try {
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // Define a clean, unique name for the image file
      // This name will be placed inside the "profileImages" folder by the preset.
      final publicId = 'profile_image_$uid'; 

      final body = {
        'file': 'data:image/jpeg;base64,$base64Image',
        'upload_preset': CLOUDINARY_UPLOAD_PRESET,
        'public_id': publicId,
      };

      final response = await http.post(
        Uri.parse(CLOUDINARY_URL),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.body);
        final String downloadUrl = result['secure_url'];

        await updateUserData(uid, {'profile_picture_url': downloadUrl});
        
        return downloadUrl;
      } else {
        final errorResponse = json.decode(response.body);
        // Use a more informative error message for the user
        throw Exception('Cloudinary upload failed: ${errorResponse['error']['message']}');
      }
    } catch (e) {
      print('Cloudinary upload error: $e');
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  // =================================================================
  // 2. DOCTOR & APPOINTMENT OPERATIONS (FIXED ERRORS HERE)
  // =================================================================
  
  // FIX 3: The method 'getDoctors'
  Stream<List<DoctorModel>> getDoctors() {
    return _db.collection('doctors').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => DoctorModel.fromFirestore(doc)).toList(),
        );
  }

  // FIX 10: The method 'bookAppointment'
  Future<void> bookAppointment(AppointmentModel appointment) async {
    await _db.collection('appointments').add(appointment.toFirestore());
  }

  // FIX 4: The method 'updateAppointmentStatus'
  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    await _db.collection('appointments').doc(appointmentId).update({'status': status});
  }

  // FIX 5: The method 'getPatientAppointments'
  Stream<List<AppointmentModel>> getPatientAppointments(String patientUid) {
    return _db
        .collection('appointments')
        .where('patient_uid', isEqualTo: patientUid)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) => AppointmentModel.fromFirestore(doc)).toList(),
        );
  }

  // =================================================================
  // 3. PHARMACY/ORDER OPERATIONS (Original Index 4, re-numbered)
  // =================================================================

  Stream<List<DrugModel>> getDrugs() {
    return _db.collection('pharmacy_drugs').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => DrugModel.fromFirestore(doc)).toList(),
        );
  }

  Future<void> placeOrder(Map<String, dynamic> orderData) async {
    await _db.collection('orders').add(orderData);
  }
  
  // =================================================================
  // 4. AMBULANCE OPERATIONS (Original Index 5, re-numbered)
  // =================================================================
  
  Stream<List<AmbulanceTypeModel>> getAmbulanceTypes() {
    return _db.collection('ambulance_types').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => AmbulanceTypeModel.fromFirestore(doc)).toList(),
        );
  }
  
  Future<void> bookAmbulance(AmbulanceBookingModel booking) async {
    await _db.collection('ambulance_bookings').add(booking.toFirestore());
  }

  Future<void> updateAmbulanceStatus(String bookingId, String status) async {
    await _db.collection('ambulance_bookings').doc(bookingId).update({'status': status});
  }

  Stream<List<AmbulanceBookingModel>> getPatientAmbulanceBookings(String patientUid) {
    return _db.collection('ambulance_bookings').where('patient_uid', isEqualTo: patientUid).orderBy('booking_time', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => AmbulanceBookingModel.fromFirestore(doc)).toList(),
        );
  }
  
  // =================================================================
  // 5. NOTIFICATION OPERATIONS (Original Index 6, re-numbered)
  // =================================================================
  
  Stream<List<NotificationModel>> getPatientNotifications(String patientUid) {
    return _db.collection('notifications').where('user_uid', isEqualTo: patientUid).orderBy('created_at', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => NotificationModel.fromFirestore(doc)).toList(),
        );
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({'is_read': true});
  }
  
  Future<void> deleteNotification(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).delete();
  }

  // =================================================================
  // 7. ARTICLE OPERATIONS
  // =================================================================

  Stream<List<ArticleModel>> getLatestArticles() {
    return _db
        .collection('articles')
        .orderBy('published_date', descending: true)
        .limit(5)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) => ArticleModel.fromFirestore(doc)).toList(),
        );
  }
}