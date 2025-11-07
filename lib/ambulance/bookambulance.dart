import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For patient UID
import 'package:healthcare/services/firestore_service.dart'; // For saving booking
import 'package:healthcare/models/ambulance_type_model.dart'; // For passing ambulance info
import 'package:healthcare/models/ambulance_booking_model.dart'; // The booking model
import 'package:healthcare/index/home.dart'; // Navigation destination

class BookAmbulancePage extends StatefulWidget {
  // ⚠️ Use the shared AmbulanceTypeModel object as the parameter
  final AmbulanceTypeModel ambulanceType;

  const BookAmbulancePage({
    super.key,
    required this.ambulanceType,
  });

  @override
  State<BookAmbulancePage> createState() => _BookAmbulancePageState();
}

class _BookAmbulancePageState extends State<BookAmbulancePage> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final String? _currentPatientUid = FirebaseAuth.instance.currentUser?.uid;

  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _emergencyDetailsController = TextEditingController();

  String _selectedPriority = 'High'; // Default to high priority for ambulance
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // OPTIONAL: Fetch and pre-fill patient name and phone from UserModel
  }

  // --- Booking Logic ---

  Future<void> _bookAmbulance() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_currentPatientUid == null) {
      _showSnackbar('Authentication error. Please log in again.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newBooking = AmbulanceBookingModel(
        patientUid: _currentPatientUid,
        typeId: widget.ambulanceType.typeId,
        patientName: _patientNameController.text.trim(),
        phone: _contactNumberController.text.trim(),
        pickupLocation: _pickupController.text.trim(),
        destination: _destinationController.text.trim(),
        priority: _selectedPriority,
        emergencyDetails: _emergencyDetailsController.text.trim(),
        bookingTime: DateTime.now(),
      );

      // Save the booking to Firestore
      await _firestoreService.bookAmbulance(newBooking);

      _showSnackbar('Booking confirmed! Ambulance is on its way.', isError: false);
      
      // Navigate back to the main Home page and clear the stack for urgency
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
          (route) => false,
        );
      }
      
    } catch (e) {
      _showSnackbar('Booking failed. Please try again or call emergency contacts.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- UI Helpers ---

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, bool isRequired = true, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'This field is required.';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.ambulanceType.name}'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ambulance Info Card
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.medical_services, color: Colors.red, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.ambulanceType.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Base Fee: ₹${widget.ambulanceType.baseFare.toStringAsFixed(0)}', // Display base fare
                              style: TextStyle(color: Colors.green.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Booking Form
              const Text(
                'Patient & Location Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _buildTextField('Patient Name', _patientNameController),
              const SizedBox(height: 12),
              _buildTextField('Contact Number', _contactNumberController, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildTextField('Pickup Location (Full Address)', _pickupController),
              const SizedBox(height: 12),
              _buildTextField('Destination (Hospital/Address)', _destinationController),
              const SizedBox(height: 16),

              // Emergency Priority
              const Text(
                'Emergency Priority',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedPriority,
                items: ['Low', 'Medium', 'High', 'Critical']
                    .map((priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value!;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
              ),

              const SizedBox(height: 16),
              _buildTextField('Emergency Details (e.g., condition, history)', _emergencyDetailsController, maxLines: 3, isRequired: false),

              const SizedBox(height: 30),

              // Book Now Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _bookAmbulance, // Disable while loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 4,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'CONFIRM BOOKING',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _contactNumberController.dispose();
    _pickupController.dispose();
    _destinationController.dispose();
    _emergencyDetailsController.dispose();
    super.dispose();
  }
}