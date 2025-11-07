import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Dummy AdminDoctorDetail page
class AdminDoctorDetail extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const AdminDoctorDetail({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${doctor['name']}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Specialization: ${doctor['specialization']}'),
            const SizedBox(height: 10),
            Text('Phone: ${doctor['phone']}'),
            const SizedBox(height: 10),
            Text('Email: ${doctor['email']}'),
            const SizedBox(height: 10),
            Text('Other Details: ${doctor['otherDetails']}'),
          ],
        ),
      ),
    );
  }
}

class AddDoctor extends StatefulWidget {
  const AddDoctor({super.key});

  @override
  State<AddDoctor> createState() => _AddDoctorState();
}

class _AddDoctorState extends State<AddDoctor> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otherDetailsController = TextEditingController();

  final List<Map<String, dynamic>> _doctors = [];
  int? _editingIndex;
  File? _pickedImage;

  // Pick image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  void _addOrUpdateDoctor() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        final doctorData = {
          'name': _nameController.text.trim(),
          'specialization': _specializationController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'otherDetails': _otherDetailsController.text.trim(),
          'image': _pickedImage, // store selected image
        };

        if (_editingIndex == null) {
          _doctors.add(doctorData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Doctor Added: ${_nameController.text}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _doctors[_editingIndex!] = doctorData;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Doctor Updated: ${_nameController.text}'),
              backgroundColor: Colors.orange,
            ),
          );
          _editingIndex = null;
        }

        // Clear all fields
        _nameController.clear();
        _specializationController.clear();
        _phoneController.clear();
        _emailController.clear();
        _otherDetailsController.clear();
        _pickedImage = null;
      });
    }
  }

  void _editDoctor(int index) {
    final doctor = _doctors[index];
    _nameController.text = doctor['name'];
    _specializationController.text = doctor['specialization'];
    _phoneController.text = doctor['phone'];
    _emailController.text = doctor['email'];
    _otherDetailsController.text = doctor['otherDetails'];
    _pickedImage = doctor['image'];
    setState(() {
      _editingIndex = index;
    });
  }

  void _deleteDoctor(int index) {
    setState(() {
      _doctors.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Doctor Deleted'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Doctor')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Doctor Details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Image picker
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!)
                          : const AssetImage('assets/doctor_placeholder.png')
                      as ImageProvider,
                      child: _pickedImage == null
                          ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter doctor name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _specializationController,
                    decoration: const InputDecoration(
                      labelText: 'Specialization',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.medical_services),
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter specialization' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter phone number';
                      if (value.length < 10) return 'Enter valid phone number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter email address';
                      if (!value.contains('@')) return 'Enter valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _otherDetailsController,
                    decoration: const InputDecoration(
                      labelText: 'Other Details',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.info_outline),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _addOrUpdateDoctor,
                    icon: Icon(_editingIndex == null ? Icons.add : Icons.edit),
                    label: Text(_editingIndex == null ? 'Add Doctor' : 'Update Doctor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Divider(thickness: 2),
            const SizedBox(height: 10),
            const Text(
              'Doctors List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Vertical scrolling cards
            SizedBox(
              height: 300, // height for scroll area
              child: _doctors.isEmpty
                  ? const Center(
                child: Text('No doctors added yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              )
                  : ListView.builder(
                itemCount: _doctors.length,
                itemBuilder: (context, index) {
                  final doctor = _doctors[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AdminDoctorDetail(doctor: doctor),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: doctor['image'] != null
                              ? FileImage(doctor['image'])
                              : const AssetImage(
                              'assets/doctor_placeholder.png')
                          as ImageProvider,
                        ),
                        title: Text(doctor['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(doctor['specialization']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _editDoctor(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteDoctor(index),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}