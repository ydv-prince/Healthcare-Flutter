import 'package:flutter/material.dart';
// Updated import to use the centralized model file
import 'package:healthcare/models/doctor_model.dart'; 
import 'apointment.dart'; // Next file to review

class DoctorDetails extends StatelessWidget {
  // Use the shared DoctorModel class
  final DoctorModel doctor;

  const DoctorDetails({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor Details"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white, // Ensure icon/text color is white
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Info Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Profile Picture (Using placeholder as model has no image field)
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blueGrey,
                      child: Icon(Icons.medical_services, size: 40, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    // Doctor Info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Using 'specialist' property from DoctorModel
                        Text(
                          doctor.specialist, 
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Availability Section (NEW - Displaying data from Firestore)
            const Text(
              "Availability",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // Check if availability data exists before displaying
            if (doctor.availability.isEmpty)
              const Text('No schedule posted.', style: TextStyle(fontSize: 16, color: Colors.red))
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: doctor.availability.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),

            // About Section (Using 'about' property from DoctorModel)
            const Text(
              "About",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              // Using 'about' property from DoctorModel
              doctor.about, 
              style: const TextStyle(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 80), // Space for button padding
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // Slightly rounded for modern look
            ),
          ),
          onPressed: () {
            // Navigate to the appointment booking page, passing the DoctorModel
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Appointment(doctor: doctor)),
            );
          },
          child: const Text(
            "Book Appointment",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}