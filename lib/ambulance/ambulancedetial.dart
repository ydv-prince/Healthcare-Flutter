import 'package:flutter/material.dart';
// Import the actual model used
import 'package:healthcare/models/ambulance_type_model.dart';
import 'bookambulance.dart'; // Import the booking page

class Ambulancedetail extends StatelessWidget {
  // ⚠️ Use the shared AmbulanceTypeModel object as the parameter
  final AmbulanceTypeModel ambulanceType;

  const Ambulancedetail({super.key, required this.ambulanceType});

  // Helper for dummy data not present in the base model (Base location, rating, driver, etc. 
  // In a full app, these would come from another Firestore collection like 'AmbulanceVehicles').
  Map<String, dynamic> getDummyDetails() {
    return {
      'typeDetail': ambulanceType.features.join(', '),
      'vehicleNumber': 'MH-01-AB-1234',
      'driverName': 'Rajesh Kumar',
      'driverExperience': '8 years',
      'contactNumber': '+91-9876543210',
      'availability': '24/7 Available',
      'rating': 4.5,
      'responseTime': '10-15 minutes',
      'baseLocation': 'City Hospital, Downtown',
      'charges': '₹${ambulanceType.baseFare.toStringAsFixed(0)} base fee',
    };
  }

  @override
  Widget build(BuildContext context) {
    final dummyDetails = getDummyDetails();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          // Use model's name
          ambulanceType.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.red.shade700,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header with ambulance icon
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade700, Colors.red.shade500],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.medical_services,
                  size: 50,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  // Use a detailed description based on features
                  dummyDetails['typeDetail'], 
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ambulance Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.local_hospital,
                                color: Colors.red,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                ambulanceType.name, // Use model name
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow('Vehicle Number', dummyDetails['vehicleNumber']),
                          _buildDetailRow('Driver', dummyDetails['driverName']),
                          _buildDetailRow('Experience', dummyDetails['driverExperience']),
                          _buildDetailRow('Contact', dummyDetails['contactNumber']),
                          _buildDetailRow('Response Time', dummyDetails['responseTime']),
                          _buildDetailRow('Base Location', dummyDetails['baseLocation']),
                          _buildDetailRow('Base Charge', dummyDetails['charges']), // Updated charges label
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Facilities Card (Now using model data)
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.medical_services,
                                color: Colors.green,
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Facilities Available',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            // Use facilities array from the model
                            children: ambulanceType.features.map<Widget>((facility) {
                              return Chip(
                                label: Text(
                                  facility,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.green[50],
                                visualDensity: VisualDensity.compact,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Availability & Rating Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatusItem(
                            Icons.access_time,
                            'Availability',
                            dummyDetails['availability'],
                            Colors.blue,
                          ),
                          _buildStatusItem(
                            Icons.star,
                            'Rating',
                            '${dummyDetails['rating']}/5',
                            Colors.amber,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Book Button
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Pass the AmbulanceTypeModel object to the booking page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookAmbulancePage(
                        ambulanceType: ambulanceType,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'BOOK AMBULANCE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$title:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(IconData icon, String title, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}