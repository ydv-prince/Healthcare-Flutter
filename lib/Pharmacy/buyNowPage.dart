import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // To get current user UID
import 'package:healthcare/services/firestore_service.dart'; // For saving the order
import 'package:healthcare/models/cart_item_model.dart'; // Required for cart data structure
import 'package:healthcare/Pharmacy/pharmacy1.dart'; // Navigation destination
import 'package:razorpay_flutter/razorpay_flutter.dart'; // 1. IMPORT RAZORPAY

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

  String? _selectedPayment = "Cash on Delivery"; // Default to COD
  bool _isLoading = false;
  bool _isDataLoading = true;

  // Razorpay setup
  late Razorpay _razorpay;
  // NOTE: REPLACE WITH YOUR ACTUAL RAZORPAY KEY
  static const String razorKeyId = 'rzp_test_Rjg8fOCcrmMHWC'; 
  
  // Text controllers
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAndPrefillUserData();
    
    // 2. INITIALIZE RAZORPAY
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  
  // --- Data Fetching and Prefilling ---
  Future<void> _fetchAndPrefillUserData() async {
    if (_currentPatientUid == null) {
      if (mounted) setState(() => _isDataLoading = false);
      return;
    }
    
    try {
      final user = await _firestoreService.getUserData(_currentPatientUid!);
      if (mounted) {
        _nameController.text = user.name;
        _emailController.text = user.email;
        _numberController.text = user.phone ?? '';
      }
    } catch (e) {
      print("Error pre-filling user data: $e");
    } finally {
      if (mounted) setState(() => _isDataLoading = false);
    }
  }

  // --- Order Submission and Navigation Logic (Common for COD/UPI Success) ---
  Future<void> _placeOrderAndNavigate({String? razorpayPaymentId}) async {
    if (_currentPatientUid == null) {
       _showSnackbar('Authentication error. Please log in again.', isError: true);
       return;
    }

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
        // Include payment ID if available (for UPI/Online)
        'payment_id': razorpayPaymentId, 
        'shipping_details': {
          'name': _nameController.text.trim(),
          'phone': _numberController.text.trim(),
          'email': _emailController.text.trim(),
          'address': _addressController.text.trim(),
        },
        'items': itemsList,
      };

      // 3. Save to Firestore
      await _firestoreService.placeOrder(orderData);

      _showSnackbar('Order placed successfully!', isError: false);

      // 4. Navigate back to Pharmacy homepage and clear the stack
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Pharmacy1()),
          (route) => route.isFirst, 
        );
      }
    } catch (e) {
      _showSnackbar('Order failed: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Main Order Submission Logic ---
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
    
    if (_selectedPayment == "Cash on Delivery") {
      // Handle COD directly
      await _placeOrderAndNavigate();
    } else if (_selectedPayment == "UPI/Online Payment") {
      // Handle UPI/Online via Razorpay
      _handleRazorpayPayment();
    } else {
       // Should not happen if radio buttons are set up correctly
       _showSnackbar("Invalid payment method selected.", isError: true);
       setState(() => _isLoading = false);
    }
  }
  
  // --- Razorpay Payment Handler ---
  void _handleRazorpayPayment() {
    // Razorpay amount is in the smallest currency unit (e.g., paise for INR)
    final amountInPaise = (widget.totalAmount * 100).round();

    var options = {
      'key': razorKeyId,
      'amount': amountInPaise, 
      'name': 'HealthCare Pharma', 
      'description': 'Medicine Order #${DateTime.now().millisecondsSinceEpoch}',
      'timeout': 300, // in seconds
      'prefill': {
        'contact': _numberController.text.trim(),
        'email': _emailController.text.trim(),
      },
      // Ensure the UPI payment method is explicitly requested
      'method': {
        'upi': true,
        'card': true,
        'netbanking': true,
        'wallet': true
      },
      'theme': {
        'color': '#1976D2' // Blue theme color
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      _showSnackbar("Error initializing Razorpay: $e", isError: true);
      setState(() => _isLoading = false);
    }
  }

  // --- Razorpay Success Listener ---
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("Razorpay Success: ${response.paymentId}");
    _showSnackbar('Payment Successful! ID: ${response.paymentId}', isError: false);
    
    // Save order with payment ID
    _placeOrderAndNavigate(razorpayPaymentId: response.paymentId);
    // Note: _isLoading is set to false in _placeOrderAndNavigate finally block
  }

  // --- Razorpay Error Listener ---
  void _handlePaymentError(PaymentFailureResponse response) {
    print("Razorpay Error: ${response.code} - ${response.message}");
    _showSnackbar('Payment Failed: ${response.code} - ${response.message}', isError: true);
    setState(() => _isLoading = false);
  }

  // --- Razorpay External Wallet Listener (Optional) ---
  void _handleExternalWallet(ExternalWalletResponse response) {
    print("Razorpay External Wallet: ${response.walletName}");
    _showSnackbar('Payment initiated with External Wallet: ${response.walletName}', isError: false);
    // You might want to handle this case, but typically it behaves like a success/error flow.
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
                    // UPI / Online
                    RadioListTile<String>(
                      title: const Text("UPI / Online Payment (Razorpay)"),
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
                      title: const Text("Card (Included in Online Option)"),
                      value: "Card (Disabled)", // Changed value to a unique disabled one
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
    _razorpay.clear(); 
    _nameController.dispose();
    _numberController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}