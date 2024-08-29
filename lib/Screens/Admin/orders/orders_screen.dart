import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'orders_provider.dart';
import 'order.dart';

class AdminOrdersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _orderService = OrderService();

    return Scaffold(
      appBar: AppBar(title: Text('Pedidos')),
      body: StreamBuilder<List<CustomerOrder>>(
        stream: _orderService.getOrdersForAdmin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar los pedidos: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay pedidos aún'));
          }

          final orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
  itemBuilder: (ctx, i) {
    final order = orders[i];
    return ExpansionTile(
      title: Text('Pedido #${order.id} - Cliente: ${order.nameCustomer}'),
      subtitle: Text('Estado: ${order.status}'),
      children: [
        ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: order.products.length,
            itemBuilder: (ctx, j) {
            final product = order.products[j];
            return ListTile(
            title: Text('Producto: ${product['productName']}'),
            subtitle: Text('Cantidad: ${product['quantity']}'),
    );
  },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Notas: ${order.notes.isNotEmpty ? order.notes : 'No hay notas'}'),
        ),
        DropdownButton<String>(
          value: order.status,
          items: <String>[
            'Pedido tomado',
            'Preparando',
            'Preparado',
            'Listo para entregar',
            'En camino',
            'Entregado'
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newStatus) {
            _orderService.updateOrderStatus(order.id, newStatus!);
          },
        ),
      ],
    );
  },
          );
        },
      ),
    );
  }
}
