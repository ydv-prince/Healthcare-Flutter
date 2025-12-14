import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:healthcare/Notification/notification.dart';
import 'package:healthcare/Report/emargence.dart';
import '../Profile/profilepage1.dart';
import 'package:healthcare/Pharmacy/pharmacy1.dart'; 
import 'package:healthcare/ambulance/ambulancehome.dart';
import 'package:healthcare/doctors/topDoctor.dart';
import '../services/firestore_service.dart'; 
import '../models/user_model.dart'; 
import '../articles/health_articles_list.dart'; // NEW IMPORT

// --- Home Content Widget (Index 0: Main Dashboard UI) ---
class HomeContent extends StatelessWidget {
  final UserModel? user; 
  const HomeContent({super.key, required this.user});
  
  @override
  Widget build(BuildContext context) {
    final userName = user?.name ?? 'User'; 
    
    // Logic to determine the image source
    final ImageProvider imageProvider = (user?.profilePictureUrl?.isNotEmpty == true)
        ? NetworkImage(user!.profilePictureUrl!) as ImageProvider
        : const AssetImage('assets/user_placeholder.png') as ImageProvider;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Top Section: Welcome Header
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
                      const Text(
                        "Welcome!",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        userName, // Display the user's fetched name
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
                  // User Profile Image (Replaced hardcoded URL)
                  Container(
                    width: 140, 
                    height: 140,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        // FIX: Use dynamic imageProvider based on user data
                        image: imageProvider, 
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    // Optional: Fallback text/icon if no image is available
                    child: (user?.profilePictureUrl?.isEmpty ?? true)
                        ? const Center(child: Icon(Icons.person, size: 60, color: Colors.white70))
                        : null,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),

          // Main Scrollable Content (Categories, Search, Articles, etc.)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar (Placeholder)
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
                
                // Navigation Links (These push new screens onto the stack)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Example Navigation Link
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Topdoctor())),
                      child: const Column(children: [Icon(Icons.people, size: 40, color: Colors.blue), Text('Doctors')]),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Pharmacy1())),
                      child: const Column(children: [Icon(Icons.local_pharmacy, size: 40, color: Colors.green), Text('Pharmacy')]),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Ambulancehome())),
                      child: const Column(children: [Icon(Icons.local_hospital, size: 40, color: Colors.red), Text('Ambulance')]),
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // HEALTH ARTICLES SECTION (Made clickable)
                GestureDetector(
                  onTap: () {
                    // Navigate to the full list of articles
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const HealthArticlesList()));
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Health Articles", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Preview of the first four articles
                ...mockArticles.take(4).map((article) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleDetailsScreen(article: article)));
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(article.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article.title,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                article.subtitle,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
                
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

  int _selectedIndex = 0; // Tracks the current tab index
  UserModel? _userModel;
  
  late List<Widget> _pages; // List of widgets for the bottom navigation bar

  @override
  void initState() {
    super.initState();
    _loadUserData();
    // Initialize pages immediately
    _pages = [
        HomeContent(user: _userModel), // Pass null initially
        const NotificationPage(),      
        const Emargence(),             
        const Profilepage1(),          
    ];
  }

  void _loadUserData() {
    if (currentUserId != null) {
      _userModel = null; // Reset model while loading
      _firestoreService.getUserData(currentUserId!).then((user) {
        if (mounted) {
          setState(() {
            _userModel = user;
            // Update the HomeContent page with the fetched user data
            _pages[0] = HomeContent(user: _userModel); 
          });
        }
      }).catchError((e) {
        print("Error fetching user data in Home: $e");
        // Handle error, maybe navigate to login or show error state
      });
    }
  }

  // ⚠️ Tab tapping must ONLY update the index, which updates the body.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return const Scaffold(body: Center(child: Text("User ID missing. Please log in.")));
    }
    
    // We use a simple check on _userModel status instead of a full FutureBuilder here
    // as the data is handled in initState/loader method.
    if (_userModel == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.blue)));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0 ? "Home Page" : 
          _selectedIndex == 1 ? "Notifications" : 
          _selectedIndex == 2 ? "Emergency" : 
          "Profile",
          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false, 
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        // The back button should only appear if we push a screen from a tab 
        // (like TopDoctor or DoctorDetails), not here.
      ),

      backgroundColor: Colors.white,

      // FIX: The body displays the page corresponding to the selected index
      body: _pages[_selectedIndex], 

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Calls the index switcher above
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed, 
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
          BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: "Emergency"), 
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}