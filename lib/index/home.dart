import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthcare/Notification/notification.dart';
import 'package:healthcare/Report/emargence.dart';
import '../Profile/profilepage1.dart';
import 'package:healthcare/Pharmacy/pharmacy1.dart';
import 'package:healthcare/ambulance/ambulancehome.dart';
import 'package:healthcare/doctors/topDoctor.dart';
import '../services/firestore_service.dart'; // REQUIRED
import '../models/user_model.dart'; // REQUIRED

// --- Dummy Widget for the actual Home content (as a separate body page) ---
class HomeContent extends StatelessWidget {
  final UserModel? user;
  final FirestoreService _firestoreService = FirestoreService();

  HomeContent({super.key, required this.user});

  Widget _buildCategory(BuildContext context,
      {required IconData icon, required String label, required Widget page}) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => page));
          },
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue.shade600,
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = user?.name ?? 'User'; 
    
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const CircleAvatar(
                      //   radius: 30,
                      //   backgroundImage: AssetImage('assets/user_placeholder.png'), 
                      // ),
                      //const SizedBox(height: 12),
                      const Text(
                        "Welcome!",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        userName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "How is it going today?",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/user_placeholder.png'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),

          // Main Scrollable Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.grey.shade300)
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: "Search doctor, drugs, articles...",
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Category icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCategory(context,
                        icon: Icons.people, label: "Top Doctors", page: const Topdoctor()),
                    _buildCategory(context,
                        icon: Icons.local_pharmacy, label: "Pharmacy", page: const Pharmacy1()),
                    _buildCategory(context,
                        icon: Icons.local_hospital, label: "Ambulance", page: const Ambulancehome()),
                    // Add fourth category if needed, e.g., Lab Tests
                  ],
                ),

                const SizedBox(height: 30),

                // Health articles
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Health Articles",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "See all",
                      style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // List of Articles (Static for now)
                Column(
                  children: List.generate(
                    3,
                    (index) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 1,
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image(
                            image: NetworkImage("https://picsum.photos/100/100?random=$index"),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text("Health article ${index + 1}"),
                        subtitle: const Text("5 min read"),
                        trailing: const Icon(Icons.bookmark_border, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50), // Extra space for scrolling
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Main Home Widget (Handles Navigation and Data Fetching) ---
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  int _selectedIndex = 0;
  UserModel? _userModel;

  // List of body widgets corresponding to the BottomNavigationBar items
  late final List<Widget> _pages = [
    HomeContent(user: _userModel), // 0. Home
    const NotificationPage(),      // 1. Notifications
    const Emargence(),             // 2. Important/Emergency
    const Profilepage1(),          // 3. Profile
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    if (currentUserId != null) {
      try {
        final user = await _firestoreService.getUserData(currentUserId!);
        setState(() {
          _userModel = user;
          // Re-initialize the pages list with the fetched user model
          _pages[0] = HomeContent(user: _userModel); 
        });
      } catch (e) {
        // Handle error, e.g., log or show a temporary message
        print('Error fetching user data: $e');
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // The body automatically switches based on _selectedIndex, no Navigator.push needed.
  }

  @override
  Widget build(BuildContext context) {
    // If user data is still loading, show a loading screen or keep the placeholder
    if (_userModel == null && currentUserId != null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? "Home Page" : 
          _selectedIndex == 1 ? "Notifications" : 
          _selectedIndex == 2 ? "Emergency & Contacts" : 
          "Profile",
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, 
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),

      backgroundColor: Colors.white,

      // Display the current page based on the selected index
      body: _pages[_selectedIndex], 

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed, // Use fixed type
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
          BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: "Emergency"), // Changed label
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}