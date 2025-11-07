import 'package:flutter/material.dart';
// Use the centralized models
import 'package:healthcare/models/drug_model.dart';
import 'package:healthcare/models/cart_item_model.dart';

class AddToCartPage extends StatefulWidget {
  // Use DrugModel
  final DrugModel medicine;
  // Use CartItemModel
  final List<CartItemModel> cartItems;
  // Update the function signature
  final Function(CartItemModel) onCartUpdate;

  const AddToCartPage({
    super.key,
    required this.medicine,
    required this.cartItems,
    required this.onCartUpdate,
  });

  @override
  State<AddToCartPage> createState() => _AddToCartPageState();
}

class _AddToCartPageState extends State<AddToCartPage> {
  int quantity = 1;
  // Use CartItemModel
  late CartItemModel currentCartItem;

  @override
  void initState() {
    super.initState();
    
    // Check if medicine already exists in cart, matching by unique ID
    final existingItem = widget.cartItems.firstWhere(
      (item) => item.drug.drugId == widget.medicine.drugId, // Match by ID
      // Initialize with a temporary item if not found
      orElse: () => CartItemModel(drug: widget.medicine, quantity: 0),
    );

    // If it exists, set quantity to the current cart quantity
    quantity = existingItem.quantity > 0 ? existingItem.quantity : 1;
    currentCartItem = CartItemModel(drug: widget.medicine, quantity: quantity);
  }

  void _updateQuantity(int newQuantity) {
    setState(() {
      // Prevent quantity from going below 0, as 0 means removal
      if (newQuantity >= 0) {
        quantity = newQuantity;
        currentCartItem.quantity = quantity;
      } else {
        quantity = 0;
        currentCartItem.quantity = 0;
      }
    });
  }

  void _addToCart() {
    // 1. Check if the user is trying to add a quantity of 0
    if (quantity == 0) {
      // Call update to potentially remove the item if it was previously in the cart
       widget.onCartUpdate(currentCartItem);
       Navigator.pop(context);
       return;
    }
    
    // 2. Check for stock availability (Basic check)
    if (quantity > widget.medicine.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot add. Quantity exceeds available stock!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 3. Update cart via callback
    widget.onCartUpdate(currentCartItem);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.medicine.name} added to cart (Qty: $quantity)!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate back
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total price based on current quantity
    final totalPrice = widget.medicine.price * quantity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adjust Quantity'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.medication,
                      size: 60,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    // Use 'name' property
                    widget.medicine.name,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    // Use 'quantityLabel' property
                    widget.medicine.quantityLabel,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  // Display Stock Status
                  const SizedBox(height: 5),
                  Text(
                    'Stock: ${widget.medicine.stock} units left',
                    style: TextStyle(
                      fontSize: 14,
                      color: widget.medicine.stock > 10 ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Description (Updated property)
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              // Use 'description' property
              widget.medicine.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            // Price Information
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Price per unit:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    // Use 'price' property
                    'Rs. ${widget.medicine.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Quantity Selector
            const Text(
              'Quantity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Quantity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      // Decrease Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.remove),
                          // Only allow decrease if quantity > 0
                          onPressed: quantity > 0 ? () => _updateQuantity(quantity - 1) : null,
                          color: quantity > 0 ? Colors.black : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Quantity Display
                      SizedBox(
                        width: 50,
                        child: Text(
                          quantity.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Increase Button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.add),
                          // Only allow increase if quantity < stock
                          onPressed: quantity < widget.medicine.stock ? () => _updateQuantity(quantity + 1) : null,
                          color: quantity < widget.medicine.stock ? Colors.blue.shade700 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Total Price
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.blue.shade50, Colors.white],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Rs. ${totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24, // Made it slightly larger
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
                icon: const Icon(Icons.shopping_cart, color: Colors.white),
                label: const Text(
                  'Update Cart', // Changed to 'Update Cart' for clarity
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Continue Shopping Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  'Continue Shopping',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}