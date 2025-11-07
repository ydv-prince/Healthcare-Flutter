import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Emargence extends StatefulWidget {
  const Emargence({super.key});

  @override
  State<Emargence> createState() => _EmargenceState();
}

class _EmargenceState extends State<Emargence> {
  final List<EmergencyContact> emergencyContacts = [
    EmergencyContact(
      name: 'Police',
      number: '100',
      icon: Icons.local_police,
      color: Colors.blue,
    ),
    EmergencyContact(
      name: 'Ambulance',
      number: '108',
      icon: Icons.medical_services,
      color: Colors.red,
    ),
    EmergencyContact(
      name: 'Fire Brigade',
      number: '101',
      icon: Icons.fire_truck,
      color: Colors.orange,
    ),
    EmergencyContact(
      name: 'Women Helpline',
      number: '1091',
      icon: Icons.woman,
      color: Colors.purple,
    ),
    EmergencyContact(
      name: 'Child Helpline',
      number: '1098',
      icon: Icons.child_care,
      color: Colors.pink,
    ),
    EmergencyContact(
      name: 'Emergency Disaster',
      number: '108',
      icon: Icons.warning,
      color: Colors.red,
    ),
    EmergencyContact(
      name: 'Road Accident',
      number: '1073',
      icon: Icons.car_crash,
      color: Colors.amber,
    ),
    EmergencyContact(
      name: 'COVID Helpline',
      number: '1075',
      icon: Icons.medical_information,
      color: Colors.green,
    ),
  ];

  // --- Phone Call Functionality ---
  Future<void> _launchCaller(String number) async {
    final Uri uri = Uri.parse('tel:$number');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch dialer for $number.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🛑 Emergency Banner & Instructions Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.red.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Important Instructions:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Stay calm and speak clearly\n'
                    '• Provide your exact location\n'
                    '• Describe the emergency briefly\n'
                    '• Follow instructions from the operator',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Contacts List (Now ListView is inside a Column, so it needs shrinkWrap)
            ListView.builder(
              physics:
                  const NeverScrollableScrollPhysics(), // Disable internal scrolling
              shrinkWrap:
                  true, // Allow ListView to take only the size needed for its children
              padding: const EdgeInsets.all(16),
              itemCount: emergencyContacts.length,
              itemBuilder: (context, index) {
                final contact = emergencyContacts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    onTap: () => _launchCaller(contact.number),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: contact.color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(contact.icon, color: contact.color, size: 24),
                    ),
                    title: Text(
                      contact.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      contact.number,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.phone,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class EmergencyContact {
  final String name;
  final String number;
  final IconData icon;
  final Color color;

  EmergencyContact({
    required this.name,
    required this.number,
    required this.icon,
    required this.color,
  });
}
