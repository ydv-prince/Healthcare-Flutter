import 'package:healthcare/Pharmacy/pharmacy_model.dart';

class CartItem {
  final Pharmacy medicine;
  int quantity;

  CartItem({
    required this.medicine,
    this.quantity = 1,
  });

  double get totalPrice => medicine.priceValue * quantity;
}