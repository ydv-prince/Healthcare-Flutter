import 'package:flutter/material.dart';

// Ambulance model class
class AmbulanceRequest {
  final String id;
  final String userName;
  final String userPhone;
  final String startPoint;
  final String destination;
  final String ambulanceName;
  final String ambulanceType;
  final String driverName;
  final String status;
  final DateTime requestTime;

  AmbulanceRequest({
    required this.id,
    required this.userName,
    required this.userPhone,
    required this.startPoint,
    required this.destination,
    required this.ambulanceName,
    required this.ambulanceType,
    required this.driverName,
    required this.status,
    required this.requestTime,
  });

  AmbulanceRequest copyWith({
    String? id,
    String? userName,
    String? userPhone,
    String? startPoint,
    String? destination,
    String? ambulanceName,
    String? ambulanceType,
    String? driverName,
    String? status,
    DateTime? requestTime,
  }) {
    return AmbulanceRequest(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      startPoint: startPoint ?? this.startPoint,
      destination: destination ?? this.destination,
      ambulanceName: ambulanceName ?? this.ambulanceName,
      ambulanceType: ambulanceType ?? this.ambulanceType,
      driverName: driverName ?? this.driverName,
      status: status ?? this.status,
      requestTime: requestTime ?? this.requestTime,
    );
  }
}

class Adminambulence extends StatefulWidget {
  const Adminambulence({super.key});

  @override
  State<Adminambulence> createState() => _AdminambulenceState();
}

class _AdminambulenceState extends State<Adminambulence> {
  // Sample ambulance request data
  final List<AmbulanceRequest> _ambulanceRequests = [
    AmbulanceRequest(
      id: 'AMB-001',
      userName: 'John Doe',
      userPhone: '+1 234-567-8900',
      startPoint: '123 Main Street, City Center',
      destination: 'City General Hospital',
      ambulanceName: 'LifeSaver-01',
      ambulanceType: 'Basic Life Support',
      driverName: 'Mike Johnson',
      status: 'Assigned',
      requestTime: DateTime(2024, 1, 20, 10, 30),
    ),
    AmbulanceRequest(
      id: 'AMB-002',
      userName: 'Jane Smith',
      userPhone: '+1 234-567-8901',
      startPoint: '456 Oak Avenue, Downtown',
      destination: 'Emergency Care Center',
      ambulanceName: 'MediRescue-02',
      ambulanceType: 'Advanced Life Support',
      driverName: 'Sarah Wilson',
      status: 'In Progress',
      requestTime: DateTime(2024, 1, 20, 11, 15),
    ),
    AmbulanceRequest(
      id: 'AMB-003',
      userName: 'Robert Brown',
      userPhone: '+1 234-567-8902',
      startPoint: '789 Pine Road, Suburb',
      destination: 'Children Medical Hospital',
      ambulanceName: 'PediatricCare-01',
      ambulanceType: 'Pediatric Ambulance',
      driverName: 'David Lee',
      status: 'Completed',
      requestTime: DateTime(2024, 1, 20, 9, 45),
    ),
    AmbulanceRequest(
      id: 'AMB-004',
      userName: 'Lisa Anderson',
      userPhone: '+1 234-567-8903',
      startPoint: '321 Elm Street, Northside',
      destination: 'Heart Institute',
      ambulanceName: 'CardioRescue-01',
      ambulanceType: 'Cardiac Ambulance',
      driverName: 'James Miller',
      status: 'Pending',
      requestTime: DateTime(2024, 1, 20, 12, 0),
    ),
    AmbulanceRequest(
      id: 'AMB-005',
      userName: 'David Wilson',
      userPhone: '+1 234-567-8904',
      startPoint: '654 Maple Drive, Westend',
      destination: 'Trauma Center',
      ambulanceName: 'TraumaCare-01',
      ambulanceType: 'Mobile ICU',
      driverName: 'Emily Davis',
      status: 'Cancelled',
      requestTime: DateTime(2024, 1, 20, 8, 30),
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

  List<AmbulanceRequest> get _filteredRequests {
    if (_searchQuery.isEmpty) {
      return _ambulanceRequests;
    }
    return _ambulanceRequests.where((request) =>
    request.userName.toLowerCase().contains(_searchQuery) ||
        request.userPhone.toLowerCase().contains(_searchQuery) ||
        request.startPoint.toLowerCase().contains(_searchQuery) ||
        request.destination.toLowerCase().contains(_searchQuery) ||
        request.ambulanceName.toLowerCase().contains(_searchQuery) ||
        request.driverName.toLowerCase().contains(_searchQuery) ||
        request.status.toLowerCase().contains(_searchQuery)).toList();
  }

  // Statistics getters
  int get totalRequestsCount => _ambulanceRequests.length;
  int get pendingRequestsCount => _ambulanceRequests.where((request) => request.status == 'Pending').length;
  int get assignedRequestsCount => _ambulanceRequests.where((request) => request.status == 'Assigned').length;
  int get inProgressRequestsCount => _ambulanceRequests.where((request) => request.status == 'In Progress').length;
  int get completedRequestsCount => _ambulanceRequests.where((request) => request.status == 'Completed').length;

  void _editRequest(AmbulanceRequest request) {
    showDialog(
      context: context,
      builder: (context) => EditAmbulanceRequestDialog(
        request: request,
        onSave: (updatedRequest) {
          setState(() {
            final index = _ambulanceRequests.indexWhere((r) => r.id == updatedRequest.id);
            if (index != -1) {
              _ambulanceRequests[index] = updatedRequest;
            }
          });
        },
      ),
    );
  }

  void _updateRequestStatus(AmbulanceRequest request, String newStatus) {
    setState(() {
      final index = _ambulanceRequests.indexWhere((r) => r.id == request.id);
      if (index != -1) {
        _ambulanceRequests[index] = request.copyWith(status: newStatus);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ambulance request ${request.id} status updated to $newStatus'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showRequestDetails(AmbulanceRequest request) {
    showDialog(
      context: context,
      builder: (context) => AmbulanceRequestDetailsDialog(request: request),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambulance Management'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Statistics Cards
          _buildStatisticsCards(),

          // Search Bar
          _buildSearchBar(),

          // Requests List
          Expanded(
            child: _buildRequestsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total',
              totalRequestsCount.toString(),
              Colors.red,
              Icons.emergency,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Pending',
              pendingRequestsCount.toString(),
              Colors.orange,
              Icons.pending,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Assigned',
              assignedRequestsCount.toString(),
              Colors.blue,
              Icons.assignment,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'In Progress',
              inProgressRequestsCount.toString(),
              Colors.purple,
              Icons.directions_car,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              'Completed',
              completedRequestsCount.toString(),
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
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
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
          hintText: 'Search by user name, phone, location, ambulance, or driver...',
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

  Widget _buildRequestsList() {
    if (_filteredRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No ambulance requests found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredRequests.length,
      itemBuilder: (context, index) {
        final request = _filteredRequests[index];
        return _buildRequestCard(request);
      },
    );
  }

  Widget _buildRequestCard(AmbulanceRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(request.status),
          child: Icon(
            _getStatusIcon(request.status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          request.userName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.phone, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  request.userPhone,
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
                Icon(Icons.location_on, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${request.startPoint} → ${request.destination}',
                    style: TextStyle(
                      fontSize: 11,
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
                Icon(Icons.local_shipping, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${request.ambulanceName} (${request.ambulanceType})',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
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
                    color: _getStatusColor(request.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.status,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.person, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  request.driverName,
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
                _editRequest(request);
                break;
              case 'details':
                _showRequestDetails(request);
                break;
              case 'pending':
                _updateRequestStatus(request, 'Pending');
                break;
              case 'assigned':
                _updateRequestStatus(request, 'Assigned');
                break;
              case 'in_progress':
                _updateRequestStatus(request, 'In Progress');
                break;
              case 'completed':
                _updateRequestStatus(request, 'Completed');
                break;
              case 'cancelled':
                _updateRequestStatus(request, 'Cancelled');
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'edit', child: Text('Edit Request')),
            PopupMenuItem(value: 'details', child: Text('View Details')),
            PopupMenuDivider(),
            PopupMenuItem(value: 'pending', child: Text('Mark as Pending')),
            PopupMenuItem(value: 'assigned', child: Text('Mark as Assigned')),
            PopupMenuItem(value: 'in_progress', child: Text('Mark as In Progress')),
            PopupMenuItem(value: 'completed', child: Text('Mark as Completed')),
            PopupMenuItem(value: 'cancelled', child: Text('Mark as Cancelled')),
          ],
        ),
        onTap: () => _showRequestDetails(request),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.blue;
      case 'assigned':
        return Colors.purple;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.done_all;
      case 'in progress':
        return Icons.directions_car;
      case 'assigned':
        return Icons.assignment;
      case 'pending':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.emergency;
    }
  }
}

// Edit Ambulance Request Dialog
class EditAmbulanceRequestDialog extends StatefulWidget {
  final AmbulanceRequest request;
  final Function(AmbulanceRequest) onSave;

  const EditAmbulanceRequestDialog({
    super.key,
    required this.request,
    required this.onSave,
  });

  @override
  State<EditAmbulanceRequestDialog> createState() => _EditAmbulanceRequestDialogState();
}

class _EditAmbulanceRequestDialogState extends State<EditAmbulanceRequestDialog> {
  late TextEditingController _userNameController;
  late TextEditingController _userPhoneController;
  late TextEditingController _startPointController;
  late TextEditingController _destinationController;
  late TextEditingController _ambulanceNameController;
  late TextEditingController _ambulanceTypeController;
  late TextEditingController _driverNameController;
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController(text: widget.request.userName);
    _userPhoneController = TextEditingController(text: widget.request.userPhone);
    _startPointController = TextEditingController(text: widget.request.startPoint);
    _destinationController = TextEditingController(text: widget.request.destination);
    _ambulanceNameController = TextEditingController(text: widget.request.ambulanceName);
    _ambulanceTypeController = TextEditingController(text: widget.request.ambulanceType);
    _driverNameController = TextEditingController(text: widget.request.driverName);
    _selectedStatus = widget.request.status;
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _userPhoneController.dispose();
    _startPointController.dispose();
    _destinationController.dispose();
    _ambulanceNameController.dispose();
    _ambulanceTypeController.dispose();
    _driverNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Ambulance Request'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _userNameController,
              decoration: InputDecoration(
                labelText: 'User Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _userPhoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _startPointController,
              decoration: InputDecoration(
                labelText: 'Starting Point',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _destinationController,
              decoration: InputDecoration(
                labelText: 'Destination',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ambulanceNameController,
              decoration: InputDecoration(
                labelText: 'Ambulance Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ambulanceTypeController,
              decoration: InputDecoration(
                labelText: 'Ambulance Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _driverNameController,
              decoration: InputDecoration(
                labelText: 'Driver Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: ['Pending', 'Assigned', 'In Progress', 'Completed', 'Cancelled']
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
            final updatedRequest = widget.request.copyWith(
              userName: _userNameController.text,
              userPhone: _userPhoneController.text,
              startPoint: _startPointController.text,
              destination: _destinationController.text,
              ambulanceName: _ambulanceNameController.text,
              ambulanceType: _ambulanceTypeController.text,
              driverName: _driverNameController.text,
              status: _selectedStatus,
            );
            widget.onSave(updatedRequest);
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

// Ambulance Request Details Dialog
class AmbulanceRequestDetailsDialog extends StatelessWidget {
  final AmbulanceRequest request;

  const AmbulanceRequestDetailsDialog({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ambulance Request Details'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: _getStatusColor(request.status),
                child: Icon(
                  _getStatusIcon(request.status),
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Request ID', request.id),
            _buildDetailRow('User Name', request.userName),
            _buildDetailRow('Phone Number', request.userPhone),
            _buildDetailRow('Starting Point', request.startPoint),
            _buildDetailRow('Destination', request.destination),
            _buildDetailRow('Ambulance Name', request.ambulanceName),
            _buildDetailRow('Ambulance Type', request.ambulanceType),
            _buildDetailRow('Driver Name', request.driverName),
            _buildDetailRow('Status', request.status),
            _buildDetailRow('Request Time',
                '${request.requestTime.day}/${request.requestTime.month}/${request.requestTime.year} ${request.requestTime.hour}:${request.requestTime.minute}'),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
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
              style: TextStyle(fontSize: 14),
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
      case 'in progress':
        return Colors.blue;
      case 'assigned':
        return Colors.purple;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.done_all;
      case 'in progress':
        return Icons.directions_car;
      case 'assigned':
        return Icons.assignment;
      case 'pending':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.emergency;
    }
  }
}