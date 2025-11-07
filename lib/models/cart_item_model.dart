import 'drug_model.dart';

class CartItemModel {
  final DrugModel drug;
  int quantity;
  
  CartItemModel({
    required this.drug,
    required this.quantity,
  });

  double get totalPrice => drug.price * quantity;
}