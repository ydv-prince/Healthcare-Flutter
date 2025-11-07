import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // To get current user UID
import 'package:healthcare/services/firestore_service.dart'; // For saving the order
import 'package:healthcare/models/cart_item_model.dart'; // Required for cart data structure
// Required for pre-filling details
import 'package:healthcare/Pharmacy/pharmacy1.dart'; // Navigation destination

class BuyNowPage extends StatefulWidget {
  final List<CartItemModel> cartItems;
  final double totalAmount;

  const BuyNowPage({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<BuyNowPage> createState() => _BuyNowPageState();
}

class _BuyNowPageState extends State<BuyNowPage> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final String? _currentPatientUid = FirebaseAuth.instance.currentUser?.uid;

  String? _selectedPayment = "Cash on Delivery"; // Changed default to COD
  bool _isLoading = false;
  bool _isDataLoading = true;

  // Text controllers
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAndPrefillUserData();
  }
  
  // --- Data Fetching and Prefilling ---
  Future<void> _fetchAndPrefillUserData() async {
    if (_currentPatientUid == null) {
      if (mounted) setState(() => _isDataLoading = false);
      return;
    }
    
    try {
      final user = await _firestoreService.getUserData(_currentPatientUid);
      if (mounted) {
        _nameController.text = user.name;
        _emailController.text = user.email;
        _numberController.text = user.phone ?? '';
        // Note: Address must be fetched from a dedicated 'delivery_address' field in a real app
      }
    } catch (e) {
      print("Error pre-filling user data: $e");
    } finally {
      if (mounted) setState(() => _isDataLoading = false);
    }
  }

  // --- Order Submission Logic ---
  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate() || _selectedPayment == null) {
      _showSnackbar("Please fill all fields and select a payment method.", isError: true);
      return;
    }

    if (widget.cartItems.isEmpty) {
      _showSnackbar("Cart is empty. Cannot place order.", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Prepare items for Firestore (Map structure)
      final List<Map<String, dynamic>> itemsList = widget.cartItems.map((item) {
        return {
          'drug_id': item.drug.drugId,
          'name': item.drug.name,
          'quantity': item.quantity,
          'unit_price': item.drug.price,
          'item_total': item.totalPrice,
        };
      }).toList();

      // 2. Prepare order data for the 'orders' collection
      final orderData = {
        'patient_uid': _currentPatientUid,
        'total_amount': widget.totalAmount,
        'date_placed': DateTime.now(),
        'status': 'processing', // Initial status
        'payment_mode': _selectedPayment,
        'shipping_details': {
          'name': _nameController.text.trim(),
          'phone': _numberController.text.trim(),
          'email': _emailController.text.trim(),
          'address': _addressController.text.trim(),
        },
        'items': itemsList,
      };

      // 3. Save to Firestore (Assuming you add a placeOrder method to FirestoreService)
      // Since we didn't define `placeOrder`, we'll use a direct collection reference:
      await _firestoreService.placeOrder(orderData);


      _showSnackbar('Order placed successfully!', isError: false);

      // 4. Navigate back to Pharmacy homepage and clear the stack
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Pharmacy1()),
          (route) => route.isFirst, // Clear all pages above the main navigation page (Pharmacy1)
        );
      }

    } catch (e) {
      _showSnackbar('Order failed: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- Building the UI ---
  @override
  Widget build(BuildContext context) {
    if (_isDataLoading) {
      return const Scaffold(
        appBar: null,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Place Order"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Delivery Information",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) => value!.isEmpty ? "Please enter your name" : null,
                ),
                const SizedBox(height: 16),

                // Number
                TextFormField(
                  controller: _numberController,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.isEmpty ? "Please enter your phone number" : null,
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email Address",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value!.isEmpty ? "Please enter your email" : null,
                ),
                const SizedBox(height: 16),

                // Address
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: "Delivery Address",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.home),
                  ),
                  maxLines: 3,
                  validator: (value) => value!.isEmpty ? "Please enter your address" : null,
                ),
                const SizedBox(height: 24),

                const Text(
                  "Select Payment Method",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),

                // Payment Options
                Column(
                  children: [
                    // UPI
                    RadioListTile<String>(
                      title: const Text("UPI / Online Payment"),
                      value: "UPI/Online Payment",
                      groupValue: _selectedPayment,
                      onChanged: (value) => setState(() => _selectedPayment = value),
                    ),
                    // Cash on Delivery
                    RadioListTile<String>(
                      title: const Text("Cash on Delivery (COD)"),
                      value: "Cash on Delivery",
                      groupValue: _selectedPayment,
                      onChanged: (value) => setState(() => _selectedPayment = value),
                    ),
                    // Placeholder for Card/Razorpay
                    RadioListTile<String>(
                      title: const Text("Card (Unavailable in Demo)"),
                      value: "Card",
                      groupValue: _selectedPayment,
                      onChanged: null, // Disable this option
                    ),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Display Final Total
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Grand Total: Rs. ${widget.totalAmount.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                  ),
                ),
                const SizedBox(height: 10),

                // Place Order Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _placeOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            "Place Order",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }
  
}