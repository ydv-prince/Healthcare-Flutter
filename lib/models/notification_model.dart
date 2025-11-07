import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String notificationId;
  final String userUid;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.notificationId,
    required this.userUid,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    final timestamp = data?['created_at'] as Timestamp?;

    return NotificationModel(
      notificationId: doc.id,
      userUid: data?['user_uid'] ?? '',
      message: data?['message'] ?? 'No message content.',
      type: data?['type'] ?? 'general',
      isRead: data?['is_read'] ?? false,
      createdAt: timestamp?.toDate() ?? DateTime.now(),
    );
  }
}