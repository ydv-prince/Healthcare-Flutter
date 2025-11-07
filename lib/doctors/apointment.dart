import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // To get the patient's UID
import 'package:intl/intl.dart'; // For date/time formatting (Add to pubspec.yaml)
import 'package:healthcare/services/firestore_service.dart'; // For booking logic
import 'package:healthcare/models/doctor_model.dart'; // The doctor being booked
import 'package:healthcare/models/appointment_model.dart'; // The data model for the booking
import 'confirmation_page.dart'; // Next page

class Appointment extends StatefulWidget {
  final DoctorModel doctor;

  const Appointment({super.key, required this.doctor});

  @override
  State<Appointment> createState() => _AppointmentState();
}

class _AppointmentState extends State<Appointment> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final String? _currentPatientUid = FirebaseAuth.instance.currentUser?.uid;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1)); // Default to tomorrow
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill patient name if available (assuming you fetch UserModel elsewhere)
    // For now, leave empty or add logic to pre-fetch via FirestoreService
  }

  // --- Utility Methods ---

  void _showSnackbar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  // --- Date/Time Pickers ---

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(), // Cannot book appointments in the past
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // --- Booking Logic ---

  Future<void> _bookAppointment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_currentPatientUid == null) {
      _showSnackbar('Authentication error. Please log in again.', isError: true);
      return;
    }
    
    // Final check for date being in the past (in case the user is too slow)
    if (_selectedDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
       _showSnackbar('Please select a future date.', isError: true);
       return;
    }

    setState(() => _isLoading = true);

    // Combine selected date and time into a single DateTime object
    final finalDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final newAppointment = AppointmentModel(
      patientUid: _currentPatientUid,
      doctorId: widget.doctor.doctorId,
      patientName: _nameController.text.trim(),
      problem: _problemController.text.trim(),
      date: finalDateTime,
      time: _selectedTime.format(context),
      status: 'pending',
    );

    try {
      // Save the new appointment to the 'appointments' collection
      await _firestoreService.bookAppointment(newAppointment);

      _showSnackbar('Appointment successfully requested!', isError: false);

      // Navigate to confirmation page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmationPage(
              doctor: widget.doctor,
              appointmentDate: DateFormat('EEEE, MMMM d, y').format(finalDateTime),
              appointmentTime: _selectedTime.format(context),
            ),
          ),
        );
      }
    } catch (e) {
      _showSnackbar('Failed to book appointment. Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Appointment"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Info Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.blueGrey,
                        child: Icon(Icons.medical_services, color: Colors.white),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.doctor.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          // Using 'specialist' property
                          Text(
                            widget.doctor.specialist, 
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
              
              const Text("Patient Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // Patient Name Field
              TextFormField(
                controller: _nameController,
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
                decoration: InputDecoration(
                  hintText: "Enter your full name",
                  prefixIcon: const Icon(Icons.person),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 15),

              // Problem Description Field
              TextFormField(
                controller: _problemController,
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Please describe your problem' : null,
                decoration: InputDecoration(
                  hintText: "Describe Your Problem (e.g., severe headache)",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              
              const SizedBox(height: 30),

              const Text("Select Date & Time", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // Date Picker
              InkWell(
                onTap: _isLoading ? null : () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Appointment Date',
                    prefixIcon: const Icon(Icons.calendar_today),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  child: Text(
                    DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 15),

              // Time Picker
              InkWell(
                onTap: _isLoading ? null : () => _selectTime(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Appointment Time',
                    prefixIcon: const Icon(Icons.access_time),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  child: Text(
                    _selectedTime.format(context),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Confirm Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _bookAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          "Confirm Appointment",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    _problemController.dispose();
    super.dispose();
  }
}