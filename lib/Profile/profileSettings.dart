import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthcare/services/firestore_service.dart';
import 'package:image_picker/image_picker.dart'; 
import 'dart:io'; 

class ProfileSettings extends StatefulWidget {
  final String name;
  final String email;
  final String? profileImageUrl; // Holds the network URL

  const ProfileSettings({
    super.key,
    required this.name,
    required this.email,
    required this.profileImageUrl,
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
  late TextEditingController _phoneController = TextEditingController(); 

  bool _isLoading = false;
  File? _selectedImage; 

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _fetchPhoneData();
  }
  
  Future<void> _fetchPhoneData() async {
    if (_currentUserId == null) return; 
    try {
      // NOTE: This fetch should ideally be integrated with the main profile page's 
      // data fetching to ensure consistency.
      final user = await _firestoreService.getUserData(_currentUserId);
      if(mounted) {
        setState(() {
          _phoneController = TextEditingController(text: user.phone ?? '');
        });
      }
    } catch (e) {
      if(mounted) {
        _phoneController = TextEditingController(text: '');
        print("Error fetching phone data: $e");
      }
    }
  }
  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      // Use setState to update the local image preview
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _currentUserId == null) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;

      // 1. UPLOAD IMAGE if selected
      if (_selectedImage != null) {
        imageUrl = await _firestoreService.uploadProfilePicture(_currentUserId, _selectedImage!);
      }

      // 2. Prepare update map
      final updateMap = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        // IMPORTANT: Ensure this key matches what is stored in Firestore
        if (imageUrl != null) 'profile_picture_url': imageUrl, 
      };

      // 3. Update Firestore
      await _firestoreService.updateUserData(_currentUserId, updateMap);

      // 4. SUCCESS: Return true to the previous screen (Profilepage1) to trigger a reload.
      if (mounted) {
        // Pop the current screen and pass 'true' as a result flag
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // Helper method to determine the correct ImageProvider
  ImageProvider _getImageProvider() {
    // 1. If a local image is selected, use that (the preview)
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }
    
    // 2. If a network URL exists and is not empty, use that
    if (widget.profileImageUrl != null && widget.profileImageUrl!.isNotEmpty) {
      return NetworkImage(widget.profileImageUrl!);
    }
    
    // 3. Fallback to placeholder asset
    return const AssetImage('assets/user_placeholder.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
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
              // PROFILE PICTURE UPLOAD AREA
              GestureDetector(
                onTap: _pickImage, 
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blueGrey,
                  // Correctly uses the helper function to decide which image to show
                  backgroundImage: _getImageProvider(),
                  child: _selectedImage == null 
                      ? const Icon(Icons.camera_alt, color: Colors.white, size: 30)
                      : null,
                ),
              ),
              const SizedBox(height: 30),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                validator: (value) => value!.isEmpty ? 'Name cannot be empty' : null,
              ),
              const SizedBox(height: 16),

              // Email Field (Read-only)
              TextFormField(
                controller: _emailController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Email Address (Read Only)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
              ),
              const SizedBox(height: 16),

              // Phone Field
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
                validator: (value) => value!.isEmpty ? 'Phone cannot be empty' : null,
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: _isLoading 
                      ? const Text("Saving...")
                      : const Text("Update Profile", style: TextStyle(fontSize: 18)),
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