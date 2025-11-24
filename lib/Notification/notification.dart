import '../index/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthcare/services/firestore_service.dart';
import 'package:healthcare/models/notification_model.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _currentPatientUid = FirebaseAuth.instance.currentUser?.uid; 

  Future<void> _deleteNotification(String notificationId, int index) async {
    try {
      await _firestoreService.deleteNotification(notificationId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Notification removed."), duration: Duration(seconds: 1)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete notification: $e")),
        );
      }
    }
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMM d, h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPatientUid == null) {
      return const Center(child: Text("Please log in to view notifications."));
    }

    return Scaffold(
      // ❌ FIX: No AppBar here. The title is provided by the outer Home Scaffold.
      body: StreamBuilder<List<NotificationModel>>(
        stream: _firestoreService.getPatientNotifications(_currentPatientUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading notifications: ${snapshot.error}'));
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("No notifications yet.", style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                color: notification.isRead ? Colors.white : Colors.blue.shade50,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  onTap: () {
                    if (!notification.isRead) {
                      _firestoreService.markNotificationAsRead(notification.notificationId);
                    }
                  },
                  leading: Icon(
                    notification.type == 'appointment' ? Icons.calendar_today : 
                    notification.type == 'order' ? Icons.local_pharmacy :
                    Icons.notifications,
                    color: Colors.blue.shade700, size: 40,
                  ),
                  title: Text(notification.message, style: TextStyle(fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold, fontSize: 16)),
                  subtitle: Text(_formatDate(notification.createdAt)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteNotification(notification.notificationId, index),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}