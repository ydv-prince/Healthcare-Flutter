import 'package:flutter/material.dart';
import 'package:healthcare/AdminPanel/AdminAmbulence.dart';
import 'package:healthcare/AdminPanel/AdminOrder.dart';
import 'package:healthcare/AdminPanel/adminPatient.dart';
import '../intropage.dart';
import 'add_ambulance.dart';
import 'add_doctor.dart';
import 'add_medicines.dart';
import 'adminuser.dart';

class Adminpage extends StatefulWidget {
  const Adminpage({super.key});

  @override
  State<Adminpage> createState() => _AdminpageState();
}

class _AdminpageState extends State<Adminpage> {
  int totalUsers = 1200;
  int totalOrders = 350;
  int totalPatients = 150;
  int totalAmbulanceBookings = 45;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Healthcare Admin Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            InkWell(onTap: (){
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Intropage()),
                    (route) => false, // Remove all previous routes
              );
            },child: const DrawerHeader(child: Text('Logout'))),
            ListTile(title: Text('Dashboard'),
            onTap:(){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>const Adminpage()));
            }),
            ListTile(
              title: const Text('Add Doctors'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddDoctor()),
                );
              },
            ),
            ListTile(
              title: Text('Add Medicines'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddMedicines()),
                );
              },

            ),
            ListTile(
              title: Text('Add Ambulance'),
              onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder:(context)=> const AddAmbulance()),);
              }
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overview',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                InkWell(onTap:(){
                  Navigator.push(context, MaterialPageRoute(builder:(context) => const Adminuser()));
                },
                  child: _buildDashboardCard(
                    icon: Icons.people,
                    label: 'Users',
                    count: totalUsers,
                    color: Colors.blueAccent,
                  ),
                ),
                InkWell(
                  onTap:(){
                    Navigator.push(context, MaterialPageRoute(builder:(context)=> const Adminorder()));
                  },
                  child: _buildDashboardCard(
                    icon: Icons.shopping_cart,
                    label: 'Orders',
                    count: totalOrders,
                    color: Colors.green,
                  ),
                ),
                InkWell(
                  onTap:(){
                    Navigator.push(context, MaterialPageRoute(builder:(context)=>const Adminpatient()));
                  },
                  child: _buildDashboardCard(
                    icon: Icons.local_hospital,
                    label: 'Patients',
                    count: totalPatients,
                    color: Colors.redAccent,
                  ),
                ),
                InkWell(
                  onTap:(){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const Adminambulence()));
                  },
                  child: _buildDashboardCard(
                    icon: Icons.emergency,
                    label: 'Ambulance',
                    count: totalAmbulanceBookings,
                    color: Colors.orangeAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 5),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
