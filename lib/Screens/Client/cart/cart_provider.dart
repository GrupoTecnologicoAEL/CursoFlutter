import 'package:flutter/material.dart';
import '../../../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();

  int get itemCount => _items.length;

  double get totalAmount {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      // Si el producto ya está en el carrito, incrementar la cantidad
      _items.update(
        product.id,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      // Si el producto no está en el carrito, agregarlo con cantidad 1
      _items.putIfAbsent(
        product.id,
        () => CartItem(product: product),
      );
    }
    notifyListeners();
  }

  void removeItem(Product product) {
    if (_items.containsKey(product.id)) {
      if (_items[product.id]!.quantity > 1) {
        // Si la cantidad es mayor a 1, decrementar la cantidad
        _items.update(
          product.id,
          (existingCartItem) => CartItem(
            product: existingCartItem.product,
            quantity: existingCartItem.quantity - 1,
          ),
        );
      } else {
        // Si la cantidad es 1, remover el producto del carrito
        _items.remove(product.id);
      }
    }
    notifyListeners();
  }

  void clearCart() {
    _items = {};
    notifyListeners();
  }
}
