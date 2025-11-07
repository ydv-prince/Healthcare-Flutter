import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Dummy AmbulanceDetail page
class AmbulanceDetail extends StatelessWidget {
  final Map<String, dynamic> ambulance;

  const AmbulanceDetail({super.key, required this.ambulance});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ambulance Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ambulance Name: ${ambulance['ambulanceName']}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Ambulance Type: ${ambulance['ambulanceType']}'),
            const SizedBox(height: 10),
            Text('Driver Name: ${ambulance['driverName']}'),
            const SizedBox(height: 10),
            Text('Driver Number: ${ambulance['driverNumber']}'),
          ],
        ),
      ),
    );
  }
}

class AddAmbulance extends StatefulWidget {
  const AddAmbulance({super.key});

  @override
  State<AddAmbulance> createState() => _AddAmbulanceState();
}

class _AddAmbulanceState extends State<AddAmbulance> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _ambulanceNameController = TextEditingController();
  final TextEditingController _ambulanceTypeController = TextEditingController();
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _driverNumberController = TextEditingController();

  final List<Map<String, dynamic>> _ambulances = [];
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

  void _addOrUpdateAmbulance() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        final ambulanceData = {
          'ambulanceName': _ambulanceNameController.text.trim(),
          'ambulanceType': _ambulanceTypeController.text.trim(),
          'driverName': _driverNameController.text.trim(),
          'driverNumber': _driverNumberController.text.trim(),
          'image': _pickedImage, // store selected image
        };

        if (_editingIndex == null) {
          _ambulances.add(ambulanceData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ambulance Added: ${_ambulanceNameController.text}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _ambulances[_editingIndex!] = ambulanceData;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ambulance Updated: ${_ambulanceNameController.text}'),
              backgroundColor: Colors.orange,
            ),
          );
          _editingIndex = null;
        }

        // Clear all fields
        _ambulanceNameController.clear();
        _ambulanceTypeController.clear();
        _driverNameController.clear();
        _driverNumberController.clear();
        _pickedImage = null;
      });
    }
  }

  void _editAmbulance(int index) {
    final ambulance = _ambulances[index];
    _ambulanceNameController.text = ambulance['ambulanceName'];
    _ambulanceTypeController.text = ambulance['ambulanceType'];
    _driverNameController.text = ambulance['driverName'];
    _driverNumberController.text = ambulance['driverNumber'];
    _pickedImage = ambulance['image'];
    setState(() {
      _editingIndex = index;
    });
  }

  void _deleteAmbulance(int index) {
    setState(() {
      _ambulances.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ambulance Deleted'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Ambulance')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Ambulance Details',
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
                          : const AssetImage('assets/ambulance_placeholder.png')
                      as ImageProvider,
                      child: _pickedImage == null
                          ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _ambulanceNameController,
                    decoration: const InputDecoration(
                      labelText: 'Ambulance Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_hospital),
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter ambulance name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _ambulanceTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Ambulance Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.airport_shuttle),
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter ambulance type' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _driverNameController,
                    decoration: const InputDecoration(
                      labelText: 'Driver Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter driver name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _driverNumberController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Driver Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter driver number';
                      if (value.length < 10) return 'Enter valid phone number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _addOrUpdateAmbulance,
                    icon: Icon(_editingIndex == null ? Icons.add : Icons.edit),
                    label: Text(_editingIndex == null ? 'Add Ambulance' : 'Update Ambulance'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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
              'Ambulances List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Vertical scrolling cards
            SizedBox(
              height: 300, // height for scroll area
              child: _ambulances.isEmpty
                  ? const Center(
                child: Text('No ambulances added yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              )
                  : ListView.builder(
                itemCount: _ambulances.length,
                itemBuilder: (context, index) {
                  final ambulance = _ambulances[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AmbulanceDetail(ambulance: ambulance),
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
                          backgroundImage: ambulance['image'] != null
                              ? FileImage(ambulance['image'])
                              : const AssetImage(
                              'assets/ambulance_placeholder.png')
                          as ImageProvider,
                        ),
                        title: Text(ambulance['ambulanceName'],
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Type: ${ambulance['ambulanceType']}'),
                            Text('Driver: ${ambulance['driverName']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _editAmbulance(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteAmbulance(index),
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