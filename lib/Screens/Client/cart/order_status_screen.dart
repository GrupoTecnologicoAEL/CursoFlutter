import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Admin/orders/orders_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Admin/orders/order.dart';
import 'package:go_router/go_router.dart'; 
import '../../Client/client_screen.dart';

class ClientOrdersScreen extends StatelessWidget {
  final String clientId;

  ClientOrdersScreen({required this.clientId});

  @override
  Widget build(BuildContext context) {
    final orderService = Provider.of<OrderService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Pedidos'),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClientHomeScreen()),
              ); 
            },
          ),
        ],
      ),
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
            itemBuilder: (ctx, i) {
              final order = orders[i];
              final progress = _getProgressValue(order.status);

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pedido #${order.id}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('Estado: ${order.status}'),
                      SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey[300],
                        color: Colors.blue,
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  double _getProgressValue(String status) {
    switch (status) {
      case 'Pedido tomado':
        return 0.17; // 1/6
      case 'Preparando':
        return 0.33; // 2/6
      case 'Preparado':
        return 0.50; // 3/6
      case 'Listo para entregar':
        return 0.67; // 4/6
      case 'En camino':
        return 0.83; // 5/6
      case 'Entregado':
        return 1.0; // 6/6
      default:
        return 0.0;
    }
  }
}
