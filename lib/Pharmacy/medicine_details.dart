import 'package:flutter/material.dart';
// Use the centralized models
import 'package:healthcare/models/drug_model.dart';
import 'package:healthcare/models/cart_item_model.dart'; 
import 'addToCart.dart';

class MedicineDetailsPage extends StatefulWidget {
  // Use DrugModel
  final DrugModel medicine;
  // Use CartItemModel
  final List<CartItemModel> cartItems;
  final Function(CartItemModel) onCartUpdate;

  const MedicineDetailsPage({
    super.key,
    required this.medicine,
    required this.cartItems,
    required this.onCartUpdate,
  });

  @override
  State<MedicineDetailsPage> createState() => _MedicineDetailsPageState();
}

class _MedicineDetailsPageState extends State<MedicineDetailsPage> {
  // Removed local quantity state as adjustment happens on AddToCartPage
  
  // Direct Add to Cart function (sends a default quantity of 1)
  void _addToCartDirect() {
    // Check stock before adding
    if (widget.medicine.stock < 1) {
      _showSnackbar('Out of stock!', isError: true);
      return;
    }
    
    // Create new CartItemModel with default quantity 1
    final cartItem = CartItemModel(drug: widget.medicine, quantity: 1);
    
    // Check if item is already in cart, if so, navigate to adjustment page
    final existingItem = widget.cartItems.firstWhere(
      (item) => item.drug.drugId == widget.medicine.drugId,
      orElse: () => cartItem, // Use the new item as a placeholder if not found
    );
    
    if (existingItem.quantity > 0) {
      // If already in cart, let user adjust quantity on the dedicated page
      _navigateToAddToCartPage();
    } else {
      // If not in cart, add 1 directly and show success
      widget.onCartUpdate(cartItem);
      _showSnackbar('${widget.medicine.name} added to cart!', isError: false);
    }
  }

  // Navigate to the quantity adjustment page
  void _navigateToAddToCartPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddToCartPage(
          medicine: widget.medicine,
          cartItems: widget.cartItems,
          onCartUpdate: widget.onCartUpdate,
        ),
      ),
    );
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Details'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medicine Header (Updated properties)
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.medication,
                      size: 60,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.medicine.name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.medicine.quantityLabel,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Description Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.medicine.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _showFullDescription,
                    child: Text(
                      'Read full details...',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Medicine Information (Detail Box)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medicine Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Name', widget.medicine.name),
                  _buildInfoRow('Dosage', widget.medicine.quantityLabel),
                  _buildInfoRow('Unit Price', 'Rs. ${widget.medicine.price.toStringAsFixed(2)}'),
                  _buildInfoRow('Stock', '${widget.medicine.stock} units'),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      
      // Bottom Bar with Add to Cart button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            // Link to the quantity adjustment page
            onPressed: widget.medicine.stock > 0 ? _navigateToAddToCartPage : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.medicine.stock > 0 ? Colors.green.shade600 : Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            icon: const Icon(Icons.shopping_cart),
            label: Text(
              widget.medicine.stock > 0 ? 'Proceed to Cart' : 'Out of Stock',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullDescription() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Full Description'),
        content: SingleChildScrollView(
          child: Text(
            // Use the correct property
            widget.medicine.description,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}