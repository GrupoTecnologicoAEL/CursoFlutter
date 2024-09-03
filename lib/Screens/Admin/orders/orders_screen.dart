import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'orders_provider.dart';
import 'order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersScreen extends StatefulWidget {
  @override
  _AdminOrdersScreenState createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final _orderService = OrderService();
  String _selectedStatus = 'Todos';
  Map<String, String> _clientContacts = {};
  String _searchQuery = ''; 

  @override
  void initState() {
    super.initState();
    _fetchClientContacts();
  }

  void _fetchClientContacts() async {
    final usersSnapshot = await FirebaseFirestore.instance.collection('Users').get();
    final Map<String, String> contacts = {};
    for (var user in usersSnapshot.docs) {
      contacts[user.id] = user['contact'] ?? 'Sin contacto';
    }
    setState(() {
      _clientContacts = contacts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por cliente, estado...',
                      border: InputBorder.none,
                    ),
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query;
                      });
                    },
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedStatus,
                  items: <String>[
                    'Todos',
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
                    setState(() {
                      _selectedStatus = newStatus!;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
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

          var orders = snapshot.data!.where((order) {
            if (_selectedStatus != 'Todos' && order.status != _selectedStatus) {
              return false;
            }
            if (_searchQuery.isNotEmpty) {
              return order.nameCustomer.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    order.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    order.status.toLowerCase().contains(_searchQuery.toLowerCase());
            }
            return true;
          }).toList();

          
          orders.sort((a, b) => b.id.compareTo(a.id));

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (ctx, i) {
              final order = orders[i];
              final contact = order.contact.isNotEmpty
                ? order.contact
                : (_clientContacts[order.clientId] ?? 'Sin contacto');
              
              final isUrgent = order.status == 'Preparando' || order.status == 'Listo para entregar';

              return Card(
                margin: EdgeInsets.all(8.0),
                elevation: 4,
                color: isUrgent ? Colors.orange[100] : null, 
                child: ExpansionTile(
                  title: Text('Pedido #${order.id} - Cliente: ${order.nameCustomer}'),
                  subtitle: Text('Estado: ${order.status}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dirección: ${order.deliveryAddress}'),
                          Text('Contacto: $contact'),
                          SizedBox(height: 10),
                          
                          Column(
                            children: order.products.fold<Map<String, int>>({}, (map, product) {
                              final productName = product['productName'];
                              final quantity = (product['quantity'] as num).toInt();

                              if (map.containsKey(productName)) {
                                map[productName] = map[productName]! + quantity;
                              } else {
                                map[productName] = quantity;
                              }
                              return map;
                            }).entries.map((entry) {
                              return ListTile(
                                title: Text('Producto: ${entry.key}'),
                                subtitle: Text('Cantidad: ${entry.value}'),
                              );
                            }).toList(),
                          ),
                          Text('Notas: ${order.notes.isNotEmpty ? order.notes : 'No hay notas'}'),
                          SizedBox(height: 10),
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
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
