import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // To get the current patient's UID
import 'package:healthcare/services/firestore_service.dart'; // For fetching/updating data
import 'package:healthcare/models/ambulance_booking_model.dart'; // The data model

class BookedAmbulance extends StatefulWidget {
  const BookedAmbulance({super.key});

  @override
  State<BookedAmbulance> createState() => _BookedAmbulanceState();
}

class _BookedAmbulanceState extends State<BookedAmbulance> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _currentPatientUid = FirebaseAuth.instance.currentUser?.uid;

  // --- Firestore Cancellation Logic ---

  Future<void> _cancelBooking(String bookingId) async {
    try {
      // 1. Update the document's status in Firestore
      await _firestoreService.updateAmbulanceStatus(
        bookingId,
        'cancelled',
      );

      // 2. Show confirmation message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ambulance booking successfully cancelled."),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to cancel booking: $e")),
        );
      }
    }
  }

  // --- UI Helpers ---

  // 🧾 Confirmation dialog for cancelling ambulance
  void _showCancelConfirmation(BuildContext context, AmbulanceBookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Cancel Booking"),
        content: Text(
          "Are you sure you want to cancel the booking for ${booking.patientName} (${booking.typeId})?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("No"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              _cancelBooking(booking.bookingId!); // Call Firestore cancel logic
            },
            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 🩺 Card UI for Ambulance Booking (Now using model data)
  Widget _buildAmbulanceCard(AmbulanceBookingModel booking) {
    final bool isCancelled = booking.status == 'cancelled';
    final Color statusColor = isCancelled ? Colors.red : (booking.status == 'completed' ? Colors.blue : Colors.orange);
    final String statusText = isCancelled ? 'Cancelled' : booking.status.toUpperCase();
    
    // NOTE: Driver name/image is not in the booking model, using placeholders/generic data
    final driverName = 'Driver TBD'; 

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            
            // 🚑 Ambulance Icon + Title
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: statusColor.withOpacity(0.5),
                  child: const Icon(Icons.local_hospital, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.typeId, // Using typeId as the name
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Priority: ${booking.priority}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 👨‍⚕️ Patient Name
            Row(
              children: [
                const Icon(Icons.person, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  "Patient: ${booking.patientName}",
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 🚘 Driver Name
            Row(
              children: [
                const Icon(Icons.drive_eta, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  "Driver: $driverName",
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 📍 Pickup Point
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Pickup: ${booking.pickupLocation}",
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 🎯 Destination Point
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.flag, color: Colors.redAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Destination: ${booking.destination}",
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ❌ Cancel Button (Only show if not already cancelled or completed)
            if (!isCancelled && booking.status != 'completed')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showCancelConfirmation(context, booking),
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text(
                      "Cancel Booking",
                      style: TextStyle(color: Colors.red),
                    ),
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
      return const Center(child: Text("Please log in to view your bookings."));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Booked Ambulances"),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade100,
      
      // Use StreamBuilder to fetch live booking data
      body: StreamBuilder<List<AmbulanceBookingModel>>(
        stream: _firestoreService.getPatientAmbulanceBookings(_currentPatientUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading bookings: ${snapshot.error}'));
          }

          final bookings = snapshot.data;

          if (bookings == null || bookings.isEmpty) {
            return const Center(
              child: Text(
                "No Ambulances Booked",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return _buildAmbulanceCard(bookings[index]);
            },
          );
        },
      ),
    );
  }
}