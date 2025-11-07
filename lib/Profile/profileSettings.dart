import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthcare/services/firestore_service.dart';

class ProfileSettings extends StatefulWidget {
  // We receive the current user data to pre-fill the fields.
  final String name;
  final String email;
  final String profileImage; // User UID

  const ProfileSettings({
    super.key,
    required this.name,
    required this.email,
    required this.profileImage,
  });

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with received data
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);

    // We need to fetch the phone number since it's not passed directly from profilepage1.
    _fetchPhoneData();
  }

  Future<void> _fetchPhoneData() async {
    if (_currentUserId == null) return;
    try {
      final user = await _firestoreService.getUserData(_currentUserId);
      setState(() {
        _phoneController = TextEditingController(text: user.phone ?? '');
      });
    } catch (e) {
      _phoneController = TextEditingController(text: '');
      print("Error fetching phone data for settings: $e");
    }
  }

  // --- Update Logic ---
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _currentUserId == null) {
      return;
    }

    setState(() => _isLoading = true);

    final updateMap = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      // Email is usually handled by Firebase Auth separately, avoid updating here.
    };

    try {
      // 1. Update Firestore
      await _firestoreService.updateUserData(_currentUserId, updateMap);

      // 2. SUCCESS: Return true to the previous screen (Profilepage1) to trigger a reload.
      if (mounted) {
        Navigator.pop(context, true);
        // Snackbar is shown on Profilepage1 after the return flag is caught.
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }
  // --- End Update Logic ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture Placeholder
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueGrey,
                child: Icon(Icons.camera_alt, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 30),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Name cannot be empty' : null,
              ),
              const SizedBox(height: 16),

              // Email Field (Read-only as it's handled by Firebase Auth)
              TextFormField(
                controller: _emailController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Email Address (Read Only)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Phone cannot be empty' : null,
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: _isLoading
                      ? const Text("Saving...")
                      : const Text(
                          "Update Profile",
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
