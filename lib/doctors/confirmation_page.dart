import 'package:flutter/material.dart';
// Import the actual main Home page (which holds the BottomNavigationBar)
import 'package:healthcare/index/home.dart'; 
// Import the correct model
import 'package:healthcare/models/doctor_model.dart'; 

class ConfirmationPage extends StatefulWidget {
  // Use the shared DoctorModel
  final DoctorModel doctor;
  final String appointmentDate;
  final String appointmentTime;

  const ConfirmationPage({
    super.key,
    required this.doctor,
    required this.appointmentDate,
    required this.appointmentTime,
  });

  @override
  State<ConfirmationPage> createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar is green to symbolize success
      appBar: AppBar(
        title: const Text("Appointment Confirmed"),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Prevent going back to booking page
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Message
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline, // Slightly updated icon
                    color: Colors.green.shade600,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Your request is submitted!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "The appointment for ${widget.doctor.name} has been sent. You will be notified when it is officially confirmed.",
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Details Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Doctor Section (Updated property and image handling)
                    _buildDetailSection(
                      title: "Doctor",
                      content: widget.doctor.name,
                      // Using the correct model property
                      subtitle: widget.doctor.specialist, 
                      // Using a placeholder icon as asset path is unreliable
                      image: 'placeholder', 
                    ),
                    const Divider(height: 30),

                    // Date Section
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      title: "Date",
                      value: widget.appointmentDate,
                    ),
                    const SizedBox(height: 20),

                    // Time Section
                    _buildDetailRow(
                      icon: Icons.access_time,
                      title: "Time",
                      value: widget.appointmentTime,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Go to Home Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the main Home page and clear all previous stack
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const Home()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Return to Home",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildDetailSection({
    required String title,
    required String content,
    required String subtitle,
    required String image, // Unused but kept for consistency
  }) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundColor: Colors.blueGrey,
          child: Icon(Icons.medical_services, color: Colors.white),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}