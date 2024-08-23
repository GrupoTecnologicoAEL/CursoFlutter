import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Admin/orders/orders_provider.dart';
import '../cart/cart_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';


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
              onPressed: () async {
                await _orderService.createOrder({
                  'clientId': user!.uid,
                  'nameCustomer': _nameController.text,
                  'products': cartProvider.items.map((item) => {
                    'productId': item.id,
                    'productName': item.name,
                    'quantity': 1, // Puedes ajustar esto si manejas cantidades variables
                  }).toList(),
                  'status': 'Pedido tomado',
                  'totalPrice': cartProvider.totalAmount + 5.00,
                  'deliveryFee': 5.00, // Asegúrate de pasar el texto aquí
                  'deliveryAddress': _addressController.text,
                  'notes': _notesController.text
                });

                cartProvider.clearCart();

                // Navegar a la pantalla de estado del pedido
                context.push('/orders');
              },
              child: Text('Confirmar Pedido'),
            ),
          ],
        ),
      ),
    );
  }
}
