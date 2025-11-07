import 'package:flutter/material.dart';
import 'package:healthcare/services/firestore_service.dart';
import 'package:healthcare/models/drug_model.dart';
import 'package:healthcare/models/cart_item_model.dart';
import 'buyNowPage.dart';
import 'addToCart.dart';
import 'medicine_details.dart';

class Pharmacy1 extends StatefulWidget {
  const Pharmacy1({super.key});

  @override
  State<Pharmacy1> createState() => _Pharmacy1State();
}

class _Pharmacy1State extends State<Pharmacy1> {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<CartItemModel> cartItems = [];
  TextEditingController searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // The listener simply calls setState to trigger a rebuild when the search query changes.
    searchController.addListener(() => setState(() {})); 
  }

  // --- Navigation Methods ---

  void _navigateToMedicineDetails(DrugModel drug) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => MedicineDetailsPage(medicine: drug, cartItems: cartItems, onCartUpdate: _updateCart)));
  }

  void _navigateToAddToCart(DrugModel drug) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => AddToCartPage(medicine: drug, cartItems: cartItems, onCartUpdate: _updateCart)));
  }

  void _navigateToCheckout(double total) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => BuyNowPage(cartItems: cartItems, totalAmount: total)));
  }
  
  // --- Cart Management ---

  void _updateCart(CartItemModel newItem) {
    setState(() {
      final existingItemIndex = cartItems.indexWhere((item) => item.drug.drugId == newItem.drug.drugId);

      if (existingItemIndex >= 0) {
        cartItems[existingItemIndex].quantity = newItem.quantity;
      } else {
        cartItems.add(newItem);
      }
      
      cartItems.removeWhere((item) => item.quantity <= 0); 
    });
    _showSnackbar('Cart updated! Item: ${newItem.drug.name} (Qty: ${newItem.quantity})', isError: false);
  }

  // --- UI Helpers ---

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green));
  }

  Widget _buildCartItem(CartItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(Icons.medication, color: Colors.blue.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.drug.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Qty: ${item.quantity}'),
              ],
            ),
          ),
          Text('Rs. ${item.totalPrice.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  // ⚠️ START OF MISSING WIDGETS
  Widget _buildPaymentDetails({required double subtotal, required double taxes, required double total}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          _buildPaymentRow('Subtotal', subtotal),
          _buildPaymentRow('Taxes (5%)', taxes),
          const Divider(),
          _buildPaymentRow('Total', total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text('Rs. ${amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? Colors.green : Colors.black)),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton({required double total}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _navigateToCheckout(total),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Checkout - Rs. ${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
  
  // ⚠️ THE CRITICAL MISSING METHOD
  void _showCartDialog() {
    double subtotal = cartItems.fold(0, (total, item) => total + item.totalPrice);
    double taxes = subtotal * 0.05;
    double total = subtotal + taxes;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('My Cart', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              if (cartItems.isEmpty)
                const Padding(padding: EdgeInsets.all(20), child: Text('Your cart is empty'))
              else
                Flexible( 
                  child: ListView(
                    shrinkWrap: true,
                    children: cartItems.map((item) => _buildCartItem(item)).toList(),
                  ),
                ),
                
              if (cartItems.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildPaymentDetails(subtotal: subtotal, taxes: taxes, total: total),
                const SizedBox(height: 20),
                _buildCheckoutButton(total: total),
              ],
            ],
          ),
        ),
      ),
    );
  }
  // ⚠️ END OF MISSING WIDGETS


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pharmacy Store"),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: _showCartDialog, // ⚠️ Now correctly defined
              ),
              if (cartItems.isNotEmpty)
                Positioned(
                  right: 8, top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(cartItems.length.toString(), style: const TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search medicines...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
          
          // --- StreamBuilder for Live Data (Safe Filtering) ---
          Expanded(
            child: StreamBuilder<List<DrugModel>>(
              stream: _firestoreService.getDrugs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final allDrugs = snapshot.data ?? [];
                final currentQuery = searchController.text.toLowerCase();
                
                // SAFE FILTERING LOGIC: Runs synchronously inside the builder 
                final List<DrugModel> filteredList = currentQuery.isEmpty
                    ? allDrugs
                    : allDrugs.where((drug) => drug.name.toLowerCase().contains(currentQuery)).toList();
                
                if (filteredList.isEmpty && currentQuery.isNotEmpty) {
                  return const Center(child: Text("No products match your search."));
                }
                if (filteredList.isEmpty && currentQuery.isEmpty && snapshot.connectionState != ConnectionState.waiting) {
                   return const Center(child: Text("No products available."));
                }
                
                return ListView.builder(
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final drug = filteredList[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                            child: Icon(Icons.medication, color: Colors.blue.shade700),
                          ),
                          title: Text(drug.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(drug.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text('Rs. ${drug.price.toStringAsFixed(2)} / ${drug.quantityLabel}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _navigateToAddToCart(drug),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
                            child: const Text('Add to Cart'),
                          ),
                          onTap: () => _navigateToMedicineDetails(drug),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Correct disposal of listener
    searchController.removeListener(() => setState(() {})); 
    searchController.dispose();
    super.dispose();
  }
}