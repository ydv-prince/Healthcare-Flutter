import 'package:flutter/material.dart';

// Patient model class
class Patient {
  final String id;
  final String name;
  final String problem;
  final String doctorName;
  final DateTime appointmentDate;
  final String status;
  final String email; // Changed from phone to email

  Patient({
    required this.id,
    required this.name,
    required this.problem,
    required this.doctorName,
    required this.appointmentDate,
    required this.status,
    required this.email, // Changed from phone to email
  });

  Patient copyWith({
    String? id,
    String? name,
    String? problem,
    String? doctorName,
    DateTime? appointmentDate,
    String? status,
    String? email, // Changed from phone to email
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      problem: problem ?? this.problem,
      doctorName: doctorName ?? this.doctorName,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      status: status ?? this.status,
      email: email ?? this.email, // Changed from phone to email
    );
  }
}

class Adminpatient extends StatefulWidget {
  const Adminpatient({super.key});

  @override
  State<Adminpatient> createState() => _AdminpatientState();
}

class _AdminpatientState extends State<Adminpatient> {
  // Sample patient data
  final List<Patient> _patients = [
    Patient(
      id: 'PAT-001',
      name: 'John Doe',
      problem: 'Fever and Headache',
      doctorName: 'Dr. Sarah Wilson',
      appointmentDate: DateTime(2024, 1, 20, 10, 30),
      status: 'Confirmed',
      email: 'john.doe@example.com', // Changed to email
    ),
    Patient(
      id: 'PAT-002',
      name: 'Jane Smith',
      problem: 'Back Pain',
      doctorName: 'Dr. Mike Johnson',
      appointmentDate: DateTime(2024, 1, 21, 14, 15),
      status: 'Pending',
      email: 'jane.smith@example.com', // Changed to email
    ),
    Patient(
      id: 'PAT-003',
      name: 'Robert Brown',
      problem: 'Diabetes Checkup',
      doctorName: 'Dr. Emily Davis',
      appointmentDate: DateTime(2024, 1, 22, 9, 0),
      status: 'Completed',
      email: 'robert.brown@example.com', // Changed to email
    ),
    Patient(
      id: 'PAT-004',
      name: 'Lisa Anderson',
      problem: 'Skin Allergy',
      doctorName: 'Dr. Sarah Wilson',
      appointmentDate: DateTime(2024, 1, 23, 11, 45),
      status: 'Confirmed',
      email: 'lisa.anderson@example.com', // Changed to email
    ),
    Patient(
      id: 'PAT-005',
      name: 'David Miller',
      problem: 'Heart Checkup',
      doctorName: 'Dr. Mike Johnson',
      appointmentDate: DateTime(2024, 1, 24, 16, 30),
      status: 'Pending',
      email: 'david.miller@example.com', // Changed to email
    ),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Patient> get _filteredPatients {
    if (_searchQuery.isEmpty) {
      return _patients;
    }
    return _patients.where((patient) =>
    patient.name.toLowerCase().contains(_searchQuery) ||
        patient.problem.toLowerCase().contains(_searchQuery) ||
        patient.doctorName.toLowerCase().contains(_searchQuery) ||
        patient.status.toLowerCase().contains(_searchQuery) ||
        patient.email.toLowerCase().contains(_searchQuery)).toList(); // Added email to search
  }

  // Statistics getters
  int get totalPatientsCount => _patients.length;
  int get pendingPatientsCount => _patients.where((patient) => patient.status == 'Pending').length;
  int get confirmedPatientsCount => _patients.where((patient) => patient.status == 'Confirmed').length;
  int get completedPatientsCount => _patients.where((patient) => patient.status == 'Completed').length;

  void _editPatient(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => EditPatientDialog(
        patient: patient,
        onSave: (updatedPatient) {
          setState(() {
            final index = _patients.indexWhere((p) => p.id == updatedPatient.id);
            if (index != -1) {
              _patients[index] = updatedPatient;
            }
          });
        },
      ),
    );
  }

  void _updatePatientStatus(Patient patient, String newStatus) {
    setState(() {
      final index = _patients.indexWhere((p) => p.id == patient.id);
      if (index != -1) {
        _patients[index] = patient.copyWith(status: newStatus);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${patient.name} status updated to $newStatus'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showPatientDetails(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => PatientDetailsDialog(patient: patient),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Management'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Statistics Cards
          _buildStatisticsCards(),

          // Search Bar
          _buildSearchBar(),

          // Patients List
          Expanded(
            child: _buildPatientsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Patients',
              totalPatientsCount.toString(),
              Colors.purple,
              Icons.people,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Pending',
              pendingPatientsCount.toString(),
              Colors.orange,
              Icons.pending,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Confirmed',
              confirmedPatientsCount.toString(),
              Colors.blue,
              Icons.check_circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Completed',
              completedPatientsCount.toString(),
              Colors.green,
              Icons.done_all,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search patients by name, problem, doctor, or email...', // Updated hint text
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildPatientsList() {
    if (_filteredPatients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No patients found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredPatients.length,
      itemBuilder: (context, index) {
        final patient = _filteredPatients[index];
        return _buildPatientCard(patient);
      },
    );
  }

  Widget _buildPatientCard(Patient patient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(patient.status),
          child: Icon(
            _getStatusIcon(patient.status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          patient.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              patient.problem,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.medical_services, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  patient.doctorName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.email, size: 12, color: Colors.grey), // Email icon
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    patient.email, // Display email instead of phone
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(patient.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    patient.status,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${patient.appointmentDate.day}/${patient.appointmentDate.month}/${patient.appointmentDate.year}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editPatient(patient);
                break;
              case 'details':
                _showPatientDetails(patient);
                break;
              case 'pending':
                _updatePatientStatus(patient, 'Pending');
                break;
              case 'confirmed':
                _updatePatientStatus(patient, 'Confirmed');
                break;
              case 'completed':
                _updatePatientStatus(patient, 'Completed');
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'edit', child: Text('Edit Patient')),
            PopupMenuItem(value: 'details', child: Text('View Details')),
            PopupMenuDivider(),
            PopupMenuItem(value: 'pending', child: Text('Mark as Pending')),
            PopupMenuItem(value: 'confirmed', child: Text('Mark as Confirmed')),
            PopupMenuItem(value: 'completed', child: Text('Mark as Completed')),
          ],
        ),
        onTap: () => _showPatientDetails(patient),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'confirmed':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.done_all;
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.person;
    }
  }
}

// Edit Patient Dialog
class EditPatientDialog extends StatefulWidget {
  final Patient patient;
  final Function(Patient) onSave;

  const EditPatientDialog({
    super.key,
    required this.patient,
    required this.onSave,
  });

  @override
  State<EditPatientDialog> createState() => _EditPatientDialogState();
}

class _EditPatientDialogState extends State<EditPatientDialog> {
  late TextEditingController _nameController;
  late TextEditingController _problemController;
  late TextEditingController _doctorNameController;
  late TextEditingController _emailController; // Changed from phone to email
  late String _selectedStatus;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.patient.name);
    _problemController = TextEditingController(text: widget.patient.problem);
    _doctorNameController = TextEditingController(text: widget.patient.doctorName);
    _emailController = TextEditingController(text: widget.patient.email); // Changed to email
    _selectedStatus = widget.patient.status;
    _selectedDate = widget.patient.appointmentDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _problemController.dispose();
    _doctorNameController.dispose();
    _emailController.dispose(); // Changed to email
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Patient'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Patient Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _problemController,
              decoration: InputDecoration(
                labelText: 'Medical Problem',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _doctorNameController,
              decoration: InputDecoration(
                labelText: 'Doctor Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController, // Changed to email
              decoration: InputDecoration(
                labelText: 'Email Address', // Updated label
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress, // Email keyboard type
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: ['Pending', 'Confirmed', 'Completed']
                  .map((status) => DropdownMenuItem(
                value: status,
                child: Text(status),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Appointment Date',
                  border: OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                    Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedPatient = widget.patient.copyWith(
              name: _nameController.text,
              problem: _problemController.text,
              doctorName: _doctorNameController.text,
              email: _emailController.text, // Changed to email
              status: _selectedStatus,
              appointmentDate: _selectedDate,
            );
            widget.onSave(updatedPatient);
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

// Patient Details Dialog
class PatientDetailsDialog extends StatelessWidget {
  final Patient patient;

  const PatientDetailsDialog({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Patient Details'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: _getStatusColor(patient.status),
                child: Icon(
                  _getStatusIcon(patient.status),
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Patient ID', patient.id),
            _buildDetailRow('Name', patient.name),
            _buildDetailRow('Email', patient.email), // Changed from Phone to Email
            _buildDetailRow('Medical Problem', patient.problem),
            _buildDetailRow('Appointed Doctor', patient.doctorName),
            _buildDetailRow('Status', patient.status),
            _buildDetailRow('Appointment Date',
                '${patient.appointmentDate.day}/${patient.appointmentDate.month}/${patient.appointmentDate.year}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'confirmed':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.done_all;
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.person;
    }
  }
}