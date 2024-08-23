import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';
import 'package:go_router/go_router.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final double deliveryCost = 5.0;
    final double totalWithDelivery = cart.totalAmount + deliveryCost;

    return Scaffold(
      appBar: AppBar(
        title: Text('Carrito'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) => ListTile(
                leading: Image.network(cart.items[i].imageUrl),
                title: Text(cart.items[i].name),
                subtitle: Text('Cantidad: 1'),
                trailing: IconButton(
                  icon: Icon(Icons.remove_circle),
                  onPressed: () {
                    cart.removeItem(cart.items[i]);
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Costo de Envío: Q$deliveryCost',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total con Envío: Q${totalWithDelivery.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    context.push('/checkout');
                  },
                  child: Text('Proceder al Pago'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
