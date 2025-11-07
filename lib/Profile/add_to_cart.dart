import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Medicine {
  final String name;
  final String description;
  final double price;
  final String image;
  int quantity;

  Medicine({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.quantity = 1,
  });
}

class AddToCart extends StatefulWidget {
  const AddToCart({super.key});

  @override
  State<AddToCart> createState() => _AddToCartState();
}

class _AddToCartState extends State<AddToCart> {
  final NumberFormat currencyFormat =
  NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  List<Medicine> cartItems = [
    Medicine(
      name: "Paracetamol 500mg",
      description: "Pain reliever and fever reducer",
      price: 45.50,
      image: "assets/paracetamol.png",
      quantity: 2,
    ),
    Medicine(
      name: "Vitamin C Tablets",
      description: "Boosts immunity and overall wellness",
      price: 120.00,
      image: "assets/pantop.png",
      quantity: 1,
    ),
    Medicine(
      name: "Aspirin 100mg",
      description: "Pain reliever and anti-inflammatory",
      price: 80.00,
      image: "assets/combiflem.png",
      quantity: 1,
    ),
  ];

  void _increaseQuantity(int index) {
    setState(() {
      cartItems[index].quantity++;
    });
  }

  void _decreaseQuantity(int index) {
    setState(() {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Item removed from cart"),
        backgroundColor: Colors.red,
      ),
    );
  }

  double get subtotal =>
      cartItems.fold(0, (total, item) => total + (item.price * item.quantity));
  double get shipping => 50.00;
  double get tax => subtotal * 0.05;
  double get total => subtotal + shipping + tax;

  void _placeOrder() {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your cart is empty"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Order"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Subtotal: ${currencyFormat.format(subtotal)}"),
            Text("Shipping: ${currencyFormat.format(shipping)}"),
            Text("Tax (5%): ${currencyFormat.format(tax)}"),
            const Divider(),
            Text(
              "Total: ${currencyFormat.format(total)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                cartItems.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Order placed successfully! 🎉"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("Confirm Order"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final padding = width < 600 ? 16.0 : 32.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(padding),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final medicine = cartItems[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            medicine.image,
                            width: width * 0.18,
                            height: width * 0.18,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                medicine.name,
                                style: TextStyle(
                                  fontSize: width < 400 ? 14 : 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                medicine.description,
                                style: TextStyle(
                                  fontSize: width < 400 ? 11 : 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currencyFormat.format(medicine.price),
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => _decreaseQuantity(index),
                                ),
                                Text(
                                  medicine.quantity.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => _increaseQuantity(index),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () => _removeItem(index),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _buildOrderSummary(width, padding),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(double width, double padding) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow("Subtotal", currencyFormat.format(subtotal)),
          _buildSummaryRow("Shipping", currencyFormat.format(shipping)),
          _buildSummaryRow("Tax (5%)", currencyFormat.format(tax)),
          const Divider(),
          _buildSummaryRow("Total", currencyFormat.format(total), isTotal: true),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _placeOrder,
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text("Place Order"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(
                    vertical: width < 400 ? 12 : 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              "Your cart is empty!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("Add some medicines to proceed."),
          ],
        ),
      ),
    );
  }
}
