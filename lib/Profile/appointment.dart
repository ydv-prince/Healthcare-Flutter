import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // To get the current patient's UID
import 'package:healthcare/services/firestore_service.dart'; // For fetching/updating data
import 'package:healthcare/models/appointment_model.dart'; // The data model
import 'package:intl/intl.dart'; // For consistent date formatting

class Appointment extends StatefulWidget {
  const Appointment({super.key});

  @override
  State<Appointment> createState() => _AppointmentState();
}

class _AppointmentState extends State<Appointment> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _currentPatientUid = FirebaseAuth.instance.currentUser?.uid;

  // --- Firestore Cancellation Logic ---

  Future<void> _cancelAppointment(String appointmentId) async {
    try {
      // 1. Update the document's status in Firestore
      await _firestoreService.updateAppointmentStatus(
        appointmentId,
        'cancelled',
      );

      // 2. Show confirmation message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Appointment successfully cancelled."),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to cancel: $e")),
        );
      }
    }
  }

  // --- UI Helpers ---

  // 🧾 Confirmation Dialog for Cancel
  void _showCancelConfirmation(BuildContext context, AppointmentModel appt) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text("Cancel Appointment"),
          content: Text("Are you sure you want to cancel the appointment with ${appt.patientName} on ${DateFormat('MMM d, y').format(appt.date)}?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("No"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                _cancelAppointment(appt.appointmentId!); // Call Firestore cancel logic
              },
              child: const Text("Yes, Cancel", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // --- Widget Builders ---
  
  Widget _buildAppointmentCard(BuildContext context, AppointmentModel appt) {
    final bool isCancelled = appt.status == 'cancelled';
    final bool isConfirmed = appt.status == 'confirmed';
    final Color statusColor = isCancelled ? Colors.red : (isConfirmed ? Colors.green : Colors.orange);
    final String statusText = isCancelled ? 'Cancelled' : (isConfirmed ? 'Confirmed' : 'Pending');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withOpacity(0.5), width: 1.5)
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Tag
            Align(
              alignment: Alignment.topRight,
              child: Chip(
                label: Text(statusText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                backgroundColor: statusColor,
              ),
            ),
            
            // 🧑‍⚕️ Doctor Info
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blueGrey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // Assuming patientName here is actually DoctorName in the model, 
                        // or that we should fetch doctor data. Using patientName for now.
                        appt.patientName, 
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Doctor ID: ${appt.doctorId}', // Use doctorId until we fetch DoctorModel
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 💊 Problem
            Row(
              children: [
                const Icon(Icons.medical_information, color: Colors.redAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Problem: ${appt.problem}",
                    style: const TextStyle(fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 📅 Date & Time
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  "${DateFormat('MMM d, y').format(appt.date)}  •  ${appt.time}",
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ❌ Cancel Button (Only show if status is pending/confirmed)
            if (!isCancelled)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showCancelConfirmation(context, appt),
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text("Cancel Appointment", style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPatientUid == null) {
      return const Center(child: Text("Please log in to view appointments."));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Appointments"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade100,
      
      // Use StreamBuilder to fetch live appointment data
      body: StreamBuilder<List<AppointmentModel>>(
        stream: _firestoreService.getPatientAppointments(_currentPatientUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading appointments: ${snapshot.error}'));
          }

          final appointments = snapshot.data;

          if (appointments == null || appointments.isEmpty) {
            return const Center(
              child: Text(
                "No Appointments Found",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              return _buildAppointmentCard(context, appointments[index]);
            },
          );
        },
      ),
    );
  }
}