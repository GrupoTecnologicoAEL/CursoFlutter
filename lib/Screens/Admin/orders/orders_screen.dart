import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order.dart';
import 'orders_provider.dart';
import '../orders/ordersearch.dart';

class AdminOrdersScreen extends StatefulWidget {
  @override
  _AdminOrdersScreenState createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final _orderService = OrderService();
  String _selectedStatus = 'Todos';
  String _searchQuery = '';
  String _sortCriteria = 'Fecha';
  bool _isAscending = true;
  Map<String, String> _clientContacts = {};
  DateTime? _startDate;
  DateTime? _endDate;

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

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Pedidos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final List<CustomerOrder> orders = await _orderService.getOrdersForAdmin().first;
              final result = await showSearch(
                context: context,
                delegate: OrderSearchDelegate(orders),
              );
              if (result != null) {
                print('Pedido seleccionado: ${result.id}');
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              _selectDateRange(context);
            },
          ),
          IconButton(
            icon: Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () {
              setState(() {
                _isAscending = !_isAscending;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
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
                        child: Text(value, style: TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (String? newStatus) {
                      setState(() {
                        _selectedStatus = newStatus!;
                      });
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _sortCriteria,
                    items: <String>['Fecha', 'Cliente', 'Estado']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text('Ordenar por $value', style: TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (String? newCriteria) {
                      setState(() {
                        _sortCriteria = newCriteria!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<CustomerOrder>>(
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

                var orders = snapshot.data!
                    .where((order) {
                      if (_selectedStatus != 'Todos' && order.status != _selectedStatus) {
                        return false;
                      }
                      if (_searchQuery.isNotEmpty) {
                        return order.nameCustomer.toLowerCase().contains(_searchQuery) ||
                            order.id.toLowerCase().contains(_searchQuery) ||
                            order.status.toLowerCase().contains(_searchQuery);
                      }
                      if (_startDate != null && _endDate != null) {
                        return order.orderDate != null &&
                            order.orderDate!.isAfter(_startDate!) &&
                            order.orderDate!.isBefore(_endDate!.add(Duration(days: 1)));
                      }
                      return true;
                    })
                    .toList();

                orders.sort((a, b) {
                  int compare;
                  switch (_sortCriteria) {
                    case 'Cliente':
                      compare = a.nameCustomer.compareTo(b.nameCustomer);
                      break;
                    case 'Estado':
                      compare = a.status.compareTo(b.status);
                      break;
                    case 'Fecha':
                    default:
                      compare = a.orderDate?.compareTo(b.orderDate ?? DateTime.now()) ?? 0;
                      break;
                  }
                  return _isAscending ? compare : -compare;
                });

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (ctx, i) {
                    final order = orders[i];
                    final contact = order.contact.isNotEmpty
                        ? order.contact
                        : (_clientContacts[order.clientId] ?? 'Sin contacto');

                    final isUrgent = order.status == 'Preparando' || order.status == 'Listo para entregar';

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                      elevation: 5,
                      color: isUrgent ? Colors.orange[100] : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ExpansionTile(
                        title: Text('Pedido #${order.id} - Cliente: ${order.nameCustomer}', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Estado: ${order.status}', style: TextStyle(color: Colors.grey[600])),
                        children: [
                          Divider(),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Dirección: ${order.deliveryAddress}', style: TextStyle(fontSize: 14)),
                                Text('Contacto: $contact', style: TextStyle(fontSize: 14)),
                                Text('Fecha del Pedido: ${order.orderDate != null ? order.orderDate!.toLocal() : 'Fecha no disponible'}', style: TextStyle(fontSize: 14)),
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
                                      title: Text('Producto: ${entry.key}', style: TextStyle(fontSize: 14)),
                                      subtitle: Text('Cantidad: ${entry.value}', style: TextStyle(fontSize: 14)),
                                    );
                                  }).toList(),
                                ),
                                SizedBox(height: 10),
                                Text('Notas: ${order.notes.isNotEmpty ? order.notes : 'No hay notas'}', style: TextStyle(fontSize: 14)),
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
          ),
        ],
      ),
    );
  }
}
