import 'package:flutter/material.dart';

// Order model class
class Order {
  final String id;
  final String customerName;
  final String customerEmail;
  final String product;
  final int quantity;
  final double totalAmount;
  final DateTime orderDate;
  final String status;
  final String paymentMethod;

  Order({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.product,
    required this.quantity,
    required this.totalAmount,
    required this.orderDate,
    required this.status,
    required this.paymentMethod,
  });

  Order copyWith({
    String? id,
    String? customerName,
    String? customerEmail,
    String? product,
    int? quantity,
    double? totalAmount,
    DateTime? orderDate,
    String? status,
    String? paymentMethod,
  }) {
    return Order(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      totalAmount: totalAmount ?? this.totalAmount,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

class Adminorder extends StatefulWidget {
  const Adminorder({super.key});

  @override
  State<Adminorder> createState() => _AdminorderState();
}

class _AdminorderState extends State<Adminorder> {
  // Sample order data
  final List<Order> _orders = [
    Order(
      id: 'ORD-001',
      customerName: 'John Doe',
      customerEmail: 'john.doe@example.com',
      product: 'iPhone 14 Pro',
      quantity: 1,
      totalAmount: 999.99,
      orderDate: DateTime(2024, 1, 15, 14, 30),
      status: 'Completed',
      paymentMethod: 'Credit Card',
    ),
    Order(
      id: 'ORD-002',
      customerName: 'Jane Smith',
      customerEmail: 'jane.smith@example.com',
      product: 'MacBook Air',
      quantity: 1,
      totalAmount: 1299.99,
      orderDate: DateTime(2024, 1, 16, 10, 15),
      status: 'Confirmed',
      paymentMethod: 'PayPal',
    ),
    Order(
      id: 'ORD-003',
      customerName: 'Mike Johnson',
      customerEmail: 'mike.j@example.com',
      product: 'AirPods Pro',
      quantity: 2,
      totalAmount: 499.98,
      orderDate: DateTime(2024, 1, 17, 16, 45),
      status: 'Confirmed',
      paymentMethod: 'Credit Card',
    ),
    Order(
      id: 'ORD-004',
      customerName: 'Sarah Wilson',
      customerEmail: 'sarah.w@example.com',
      product: 'iPad Air',
      quantity: 1,
      totalAmount: 599.99,
      orderDate: DateTime(2024, 1, 18, 9, 20),
      status: 'Pending',
      paymentMethod: 'Debit Card',
    ),
    Order(
      id: 'ORD-005',
      customerName: 'David Brown',
      customerEmail: 'david.b@example.com',
      product: 'Apple Watch',
      quantity: 1,
      totalAmount: 399.99,
      orderDate: DateTime(2024, 1, 19, 11, 30),
      status: 'Pending',
      paymentMethod: 'Credit Card',
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

  List<Order> get _filteredOrders {
    if (_searchQuery.isEmpty) {
      return _orders;
    }
    return _orders.where((order) =>
    order.customerName.toLowerCase().contains(_searchQuery) ||
        order.customerEmail.toLowerCase().contains(_searchQuery) ||
        order.product.toLowerCase().contains(_searchQuery) ||
        order.id.toLowerCase().contains(_searchQuery) ||
        order.status.toLowerCase().contains(_searchQuery)).toList();
  }

  // Statistics getters
  int get totalOrdersCount => _orders.length;
  int get pendingOrdersCount => _orders.where((order) => order.status == 'Pending').length;
  int get confirmedOrdersCount => _orders.where((order) => order.status == 'Confirmed').length;
  int get completedOrdersCount => _orders.where((order) => order.status == 'Completed').length;

  void _editOrder(Order order) {
    showDialog(
      context: context,
      builder: (context) => EditOrderDialog(
        order: order,
        onSave: (updatedOrder) {
          setState(() {
            final index = _orders.indexWhere((o) => o.id == updatedOrder.id);
            if (index != -1) {
              _orders[index] = updatedOrder;
            }
          });
        },
      ),
    );
  }

  void _updateOrderStatus(Order order, String newStatus) {
    setState(() {
      final index = _orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        _orders[index] = order.copyWith(status: newStatus);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order ${order.id} status updated to $newStatus'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) => OrderDetailsDialog(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Statistics Cards
          _buildStatisticsCards(),

          // Search Bar
          _buildSearchBar(),

          // Orders List
          Expanded(
            child: _buildOrdersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total Orders',
              totalOrdersCount.toString(),
              Colors.blue,
              Icons.shopping_cart,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Pending',
              pendingOrdersCount.toString(),
              Colors.orange,
              Icons.pending,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Confirmed',
              confirmedOrdersCount.toString(),
              Colors.blue,
              Icons.check_circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Completed',
              completedOrdersCount.toString(),
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
          hintText: 'Search orders by customer, product, or status...',
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

  Widget _buildOrdersList() {
    if (_filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredOrders.length,
      itemBuilder: (context, index) {
        final order = _filteredOrders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(order.status),
          child: Icon(
            _getStatusIcon(order.status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          order.product,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${order.customerName} • ${order.customerEmail}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.paymentMethod,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Qty: ${order.quantity} • \$${order.totalAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editOrder(order);
                break;
              case 'details':
                _showOrderDetails(order);
                break;
              case 'pending':
                _updateOrderStatus(order, 'Pending');
                break;
              case 'confirmed':
                _updateOrderStatus(order, 'Confirmed');
                break;
              case 'completed':
                _updateOrderStatus(order, 'Completed');
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'edit', child: Text('Edit Order')),
            PopupMenuItem(value: 'details', child: Text('View Details')),
            PopupMenuDivider(),
            PopupMenuItem(value: 'pending', child: Text('Mark as Pending')),
            PopupMenuItem(value: 'confirmed', child: Text('Mark as Confirmed')),
            PopupMenuItem(value: 'completed', child: Text('Mark as Completed')),
          ],
        ),
        onTap: () => _showOrderDetails(order),
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
        return Icons.shopping_cart;
    }
  }
}

// Edit Order Dialog
class EditOrderDialog extends StatefulWidget {
  final Order order;
  final Function(Order) onSave;

  const EditOrderDialog({
    super.key,
    required this.order,
    required this.onSave,
  });

  @override
  State<EditOrderDialog> createState() => _EditOrderDialogState();
}

class _EditOrderDialogState extends State<EditOrderDialog> {
  late TextEditingController _customerNameController;
  late TextEditingController _customerEmailController;
  late TextEditingController _productController;
  late TextEditingController _quantityController;
  late TextEditingController _totalAmountController;
  late String _selectedStatus;
  late String _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _customerNameController = TextEditingController(text: widget.order.customerName);
    _customerEmailController = TextEditingController(text: widget.order.customerEmail);
    _productController = TextEditingController(text: widget.order.product);
    _quantityController = TextEditingController(text: widget.order.quantity.toString());
    _totalAmountController = TextEditingController(text: widget.order.totalAmount.toStringAsFixed(2));
    _selectedStatus = widget.order.status;
    _selectedPaymentMethod = widget.order.paymentMethod;
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerEmailController.dispose();
    _productController.dispose();
    _quantityController.dispose();
    _totalAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Order'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _customerNameController,
              decoration: InputDecoration(
                labelText: 'Customer Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _customerEmailController,
              decoration: InputDecoration(
                labelText: 'Customer Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _productController,
              decoration: InputDecoration(
                labelText: 'Product',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _totalAmountController,
              decoration: InputDecoration(
                labelText: 'Total Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
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
            DropdownButtonFormField<String>(
              initialValue: _selectedPaymentMethod,
              decoration: InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
              ),
              items: ['Credit Card', 'Debit Card', 'PayPal', 'Bank Transfer', 'Cash']
                  .map((method) => DropdownMenuItem(
                value: method,
                child: Text(method),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
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
            final updatedOrder = widget.order.copyWith(
              customerName: _customerNameController.text,
              customerEmail: _customerEmailController.text,
              product: _productController.text,
              quantity: int.tryParse(_quantityController.text) ?? widget.order.quantity,
              totalAmount: double.tryParse(_totalAmountController.text) ?? widget.order.totalAmount,
              status: _selectedStatus,
              paymentMethod: _selectedPaymentMethod,
            );
            widget.onSave(updatedOrder);
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

// Order Details Dialog
class OrderDetailsDialog extends StatelessWidget {
  final Order order;

  const OrderDetailsDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Order Details'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: _getStatusColor(order.status),
                child: Icon(
                  _getStatusIcon(order.status),
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Order ID', order.id),
            _buildDetailRow('Customer Name', order.customerName),
            _buildDetailRow('Customer Email', order.customerEmail),
            _buildDetailRow('Product', order.product),
            _buildDetailRow('Quantity', order.quantity.toString()),
            _buildDetailRow('Total Amount', '\$${order.totalAmount.toStringAsFixed(2)}'),
            _buildDetailRow('Status', order.status),
            _buildDetailRow('Payment Method', order.paymentMethod),
            _buildDetailRow('Order Date',
                '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year} ${order.orderDate.hour}:${order.orderDate.minute.toString().padLeft(2, '0')}'),
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
        return Icons.shopping_cart;
    }
  }
}