import 'package:flutter/material.dart';
import 'package:healthcare/services/firestore_service.dart'; 
import 'package:healthcare/models/doctor_model.dart'; 
import 'doctor_details.dart';

class Topdoctor extends StatefulWidget {
  const Topdoctor({super.key});

  @override
  State<Topdoctor> createState() => _TopdoctorState();
}

class _TopdoctorState extends State<Topdoctor> {
  // Instantiate the service to fetch data
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Top Doctors"),
        centerTitle: true,
        // Use Navigator.pop for the back button, or let the default handle it.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Correct way to navigate back to the previous screen (Home)
            Navigator.pop(context); 
          },
        ),
      ),
      
      // Use StreamBuilder to listen for real-time doctor updates
      body: StreamBuilder<List<DoctorModel>>(
        stream: _firestoreService.getDoctors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print("Firestore Error: ${snapshot.error}");
            return Center(child: Text('Error loading doctors: ${snapshot.error}'));
          }
          
          final doctors = snapshot.data;
          
          if (doctors == null || doctors.isEmpty) {
            return const Center(
              child: Text(
                "No doctors found. Please check database connection.",
                textAlign: TextAlign.center,
              ),
            );
          }
          
          // Display the list of doctors from Firestore
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    // Use a placeholder or a network image if your model had a URL
                    child: const Icon(Icons.person_pin, size: 60, color: Colors.blue), 
                  ),
                  title: Text(
                    doctor.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  // Use the specialization field from the DoctorModel
                  subtitle: Text(doctor.specialist), 
                  onTap: () {
                    // Navigate to DoctorDetails, passing the DoctorModel object
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // NOTE: You must update DoctorDetails to accept DoctorModel, not the local Doctor
                        builder: (context) => DoctorDetails(doctor: doctor),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
// Removed the redundant local main() function.