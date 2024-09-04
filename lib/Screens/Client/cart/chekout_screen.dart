import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Admin/orders/orders_provider.dart';
import '../cart/cart_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutScreen extends StatelessWidget {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _notesController = TextEditingController();

  final _orderService = OrderService();

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('Pagar')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre Completo'),
            ),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Dirección'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _contactController,
              decoration: InputDecoration(labelText: 'Contacto'),
            ),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(labelText: 'Notas (opcional)'),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _handleCheckout(context, cartProvider);
              },
              child: Text('Confirmar Pedido'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCheckout(BuildContext context, CartProvider cartProvider) async {
  final user = FirebaseAuth.instance.currentUser;

  final List<Map<String, dynamic>> products = cartProvider.items.map((item) {
  print('Producto: ${item.product.name}, Cantidad: ${item.quantity}');
  return {
    'productId': item.product.id,
    'productName': item.product.name,
    'quantity': item.quantity,
  };
}).toList();


  final newOrder = {
    'clientId': user!.uid,
    'nameCustomer': _nameController.text,
    'contact': _contactController.text,
    'products': products,
    'status': 'Pedido tomado',
    'totalPrice': cartProvider.totalAmount + 5.00,
    'deliveryFee': 5.00,
    'deliveryAddress': _addressController.text,
    'notes': _notesController.text,
    'orderDate': FieldValue.serverTimestamp(),
  };

  try {
    await _orderService.createOrder(newOrder);
    cartProvider.clearCart();
    context.pushReplacement('/orders');
  } catch (e) {
    print('Error al crear el pedido: $e');
  }
}

}
