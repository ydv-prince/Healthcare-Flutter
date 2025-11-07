import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:healthcare/services/firestore_service.dart';
import 'package:healthcare/models/user_model.dart';
// Import all necessary pages for the menu
import 'package:healthcare/Notification/notification.dart'; 
import 'package:healthcare/Profile/appointment.dart'; 
import 'package:healthcare/Profile/booked_ambulance.dart'; 
import 'package:healthcare/Profile/order_history.dart'; 
import 'package:healthcare/Profile/profileSettings.dart'; 
import 'package:healthcare/Report/emargence.dart'; 
import 'package:healthcare/intropage.dart'; 
import 'package:healthcare/Profile/add_to_cart.dart'; // View Cart Page

class Profilepage1 extends StatefulWidget {
  const Profilepage1({super.key});

  @override
  State<Profilepage1> createState() => _Profilepage1State();
}

class _Profilepage1State extends State<Profilepage1> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  late Future<UserModel> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    if (_currentUserId != null) {
      // Assign the future method call to the state variable
      _userDataFuture = _firestoreService.getUserData(_currentUserId);
    }
  }
  
  Future<void> _logout() async {
    try {
      await _auth.signOut();
      if (mounted) {
        // ✅ CRITICAL FIX: Navigate to IntroPage and clear the stack completely
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Intropage()),
          (route) => false, 
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Center(child: Text("User not logged in.", style: TextStyle(color: Colors.red)));
    }

    return FutureBuilder<UserModel>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text('Error loading profile: ${snapshot.error ?? "No Data"}'));
        }

        final user = snapshot.data!;
        
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                // 🧍‍♂️ Profile Header
                _buildProfileHeader(context, user),

                // 🧭 Menu Items
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 1. PROFILE SETTINGS (Edit Profile)
                      _buildMenuItem(
                        icon: Icons.settings,
                        title: "Edit Profile",
                        onTap: () async {
                          final bool? didUpdate = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileSettings(
                                name: user.name,
                                email: user.email,
                                profileImage: user.uid, 
                              ),
                            ),
                          );
                          
                          // ⚠️ FIX: If the result is true, trigger reload.
                          if (didUpdate == true && mounted) {
                            setState(() {
                              _loadUserData(); // Force FutureBuilder refresh
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Profile updated successfully!")),
                            );
                          }
                        },
                      ),
                      _buildDivider(),
                      
                      // 2. APPOINTMENT HISTORY
                      _buildMenuItem(icon: Icons.calendar_today, title: "Appointments", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Appointment()))),
                      _buildDivider(),
                      
                      // 3. BOOKED AMBULANCE
                      _buildMenuItem(icon: Icons.local_hospital, title: "Booked Ambulance", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BookedAmbulance()))),
                      _buildDivider(),
                      
                      // 4. ORDER HISTORY (PHARMACY)
                      _buildMenuItem(icon: Icons.receipt, title: "Order History", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderHistory()))),
                      _buildDivider(),
                      
                      // 5. VIEW CART / ORDERS
                      _buildMenuItem(icon: Icons.shopping_cart, title: "View Cart / Orders", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddToCart()))),
                      _buildDivider(),
                      
                      // 6. LOGOUT
                      _buildMenuItem(icon: Icons.logout, title: "Logout", onTap: _logout, isLogout: true),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- HELPER WIDGETS ---
  
  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 50,
              // Check for presence of phone field for simple placeholder use
              backgroundImage: user.phone?.isNotEmpty == true ? null : const AssetImage('assets/user_placeholder.png'),
              backgroundColor: Colors.blueGrey, 
              child: user.name.isEmpty ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
            ),
          ),
          const SizedBox(height: 20),
          Text(user.name.isEmpty ? 'New User' : user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 10),
          Text(user.email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red : Colors.blue.shade700, size: 24),
      title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isLogout ? Colors.red : Colors.black87)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isLogout ? Colors.red : Colors.grey[500]),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey[200], indent: 16, endIndent: 16);
  }
}