import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healthcare/services/firestore_service.dart'; // REQUIRED Service
import 'package:intl/intl.dart'; // For date formatting

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? _currentPatientUid = FirebaseAuth.instance.currentUser?.uid;

  // We rely on the streaming method from the previous step. 
  // For clarity, here is the Stream definition:
  Stream<List<QueryDocumentSnapshot>> _getPatientOrdersStream() {
    if (_currentPatientUid == null) {
      return Stream.value([]);
    }
    // Assumes this method is defined in firestore_service.dart or defined locally for this page
    return FirebaseFirestore.instance.collection('orders')
        .where('patient_uid', isEqualTo: _currentPatientUid)
        .orderBy('date_placed', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  // Helper method to determine color based on status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return Colors.green;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // --- UI Builder using Firestore Document Snapshot ---
  Widget _buildOrderCard(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Extract key fields
    final Timestamp dateTimestamp = data['date_placed'] as Timestamp;
    final double totalAmount = (data['total_amount'] ?? 0.0).toDouble();
    final String status = data['status'] ?? 'pending';
    final List<dynamic> items = data['items'] ?? [];
    
    final Color statusColor = _getStatusColor(status);
    final String dateString = DateFormat('MMM d, y').format(dateTimestamp.toDate());
    
    // Get a brief summary of items for the title/subtitle
    final String itemSummary = items.isNotEmpty 
        ? '${items.first['name']}${items.length > 1 ? ' and ${items.length - 1} more items' : ''}'
        : 'Empty Order';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // Use ExpansionTile to show item details upon tap
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(Icons.receipt_long, color: statusColor, size: 30),
        title: Text('Order ID: ${doc.id.substring(0, 8)}...', 
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Items: $itemSummary'),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Rs. ${totalAmount.toStringAsFixed(2)}', 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(status.toUpperCase(), 
                style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        
        children: [
          const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order Placed: $dateString', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                const Text('Items Detail:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                // Detailed list of items
                ...items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('• ${item['name'] ?? 'Item'} (x${item['quantity'] ?? 1})', style: const TextStyle(fontSize: 14)),
                        Text('Rs. ${(item['item_total'] ?? 0.0).toStringAsFixed(2)}'),
                      ],
                    ),
                  );
                }),
                
                const Divider(height: 20),
                
                // Shipping Details Summary
                Text('Shipped to: ${data['shipping_details']['name'] ?? 'N/A'}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                Text('Address: ${data['shipping_details']['address'] ?? 'N/A'}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                Text('Payment Mode: ${data['payment_mode'] ?? 'N/A'}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPatientUid == null) {
      return const Center(child: Text("Please log in to view order history."));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History"),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey.shade100,
      
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: _getPatientOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading orders: ${snapshot.error}'));
          }

          final orders = snapshot.data;

          if (orders == null || orders.isEmpty) {
            return const Center(
              child: Text(
                "No Pharmacy Orders Found",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _buildOrderCard(context, orders[index]);
            },
          );
        },
      ),
    );
  }
}