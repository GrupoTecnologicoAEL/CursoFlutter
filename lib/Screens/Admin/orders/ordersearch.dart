import 'package:flutter/material.dart';
import 'order.dart'; 

class OrderSearchDelegate extends SearchDelegate<CustomerOrder?> {
  final List<CustomerOrder> orders;

  OrderSearchDelegate(this.orders);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<CustomerOrder> results = orders.where((order) {
      return order.nameCustomer.toLowerCase().contains(query.toLowerCase()) ||
            order.id.toLowerCase().contains(query.toLowerCase()) ||
            order.status.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final order = results[index];
        return ListTile(
          title: Text('Pedido #${order.id}'),
          subtitle: Text('Cliente: ${order.nameCustomer}\nEstado: ${order.status}'),
          onTap: () {
            close(context, order);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<CustomerOrder> suggestions = orders.where((order) {
      return order.nameCustomer.toLowerCase().contains(query.toLowerCase()) ||
            order.id.toLowerCase().contains(query.toLowerCase()) ||
            order.status.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final order = suggestions[index];
        return ListTile(
          title: Text('Pedido #${order.id}'),
          subtitle: Text('Cliente: ${order.nameCustomer}\nEstado: ${order.status}'),
          onTap: () {
            query = order.nameCustomer;
            showResults(context);
          },
        );
      },
    );
  }
}
