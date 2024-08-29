import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Admin/orders/orders_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Admin/orders/order.dart';

class ClientOrdersScreen extends StatelessWidget {
  final String clientId;

  ClientOrdersScreen({required this.clientId});

  @override
  Widget build(BuildContext context) {
    final orderService = Provider.of<OrderService>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Mis Pedidos')),
      body: StreamBuilder<List<CustomerOrder>>(
        stream: orderService.getOrdersForClient(clientId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!;

          if (orders.isEmpty) {
            return Center(child: Text('No tienes pedidos aún'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (ctx, i) => ListTile(
              title: Text('Pedido #${orders[i].id}'),
              subtitle: Text('Estado: ${orders[i].status}'),
            ),
          );
        },
      ),
    );
  }
}
