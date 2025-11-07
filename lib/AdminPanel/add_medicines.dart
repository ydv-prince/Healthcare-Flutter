import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Dummy MedicineDetail page
class MedicineDetail extends StatelessWidget {
  final Map<String, dynamic> medicine;

  const MedicineDetail({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medicine Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Medicine Name: ${medicine['name']}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Brand: ${medicine['brand']}'),
            const SizedBox(height: 10),
            Text('Price: \$${medicine['price']}'),
            const SizedBox(height: 10),
            Text('Quantity: ${medicine['quantity']}'),
            const SizedBox(height: 10),
            Text('Description: ${medicine['description']}'),
          ],
        ),
      ),
    );
  }
}

class AddMedicines extends StatefulWidget {
  const AddMedicines({super.key});

  @override
  State<AddMedicines> createState() => _AddMedicinesState();
}

class _AddMedicinesState extends State<AddMedicines> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<Map<String, dynamic>> _medicines = [];
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

  void _addOrUpdateMedicine() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        final medicineData = {
          'name': _nameController.text.trim(),
          'brand': _brandController.text.trim(),
          'price': _priceController.text.trim(),
          'quantity': _quantityController.text.trim(),
          'description': _descriptionController.text.trim(),
          'image': _pickedImage, // store selected image
        };

        if (_editingIndex == null) {
          _medicines.add(medicineData);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Medicine Added: ${_nameController.text}'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _medicines[_editingIndex!] = medicineData;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Medicine Updated: ${_nameController.text}'),
              backgroundColor: Colors.orange,
            ),
          );
          _editingIndex = null;
        }

        // Clear all fields
        _nameController.clear();
        _brandController.clear();
        _priceController.clear();
        _quantityController.clear();
        _descriptionController.clear();
        _pickedImage = null;
      });
    }
  }

  void _editMedicine(int index) {
    final medicine = _medicines[index];
    _nameController.text = medicine['name'];
    _brandController.text = medicine['brand'];
    _priceController.text = medicine['price'];
    _quantityController.text = medicine['quantity'];
    _descriptionController.text = medicine['description'];
    _pickedImage = medicine['image'];
    setState(() {
      _editingIndex = index;
    });
  }

  void _deleteMedicine(int index) {
    setState(() {
      _medicines.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medicine Deleted'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Medicine')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Medicine Details',
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
                          : const AssetImage('assets/medicine_placeholder.png')
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
                      labelText: 'Medicine Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.medication),
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter medicine name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _brandController,
                    decoration: const InputDecoration(
                      labelText: 'Brand',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                    validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter brand name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter price';
                      if (double.tryParse(value) == null) return 'Enter valid price';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter quantity';
                      if (int.tryParse(value) == null) return 'Enter valid quantity';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _addOrUpdateMedicine,
                    icon: Icon(_editingIndex == null ? Icons.add : Icons.edit),
                    label: Text(_editingIndex == null ? 'Add Medicine' : 'Update Medicine'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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
              'Medicines List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Vertical scrolling cards
            SizedBox(
              height: 300, // height for scroll area
              child: _medicines.isEmpty
                  ? const Center(
                child: Text('No medicines added yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              )
                  : ListView.builder(
                itemCount: _medicines.length,
                itemBuilder: (context, index) {
                  final medicine = _medicines[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MedicineDetail(medicine: medicine),
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
                          backgroundImage: medicine['image'] != null
                              ? FileImage(medicine['image'])
                              : const AssetImage(
                              'assets/medicine_placeholder.png')
                          as ImageProvider,
                        ),
                        title: Text(medicine['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Brand: ${medicine['brand']}'),
                            Text('Price: \$${medicine['price']}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _editMedicine(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteMedicine(index),
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