import 'package:cloud_firestore/cloud_firestore.dart';

import '../orders/order.dart';


class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrder(Map<String, dynamic> orderData) async {
    await _firestore.collection('orders').add(orderData);
  }

  Stream<List<CustomerOrder>> getOrdersForAdmin() {
    return _firestore.collection('orders').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CustomerOrder.fromFirestore(doc)).toList();
    });
  }

  Stream<List<CustomerOrder>> getOrdersForClient(String clientId) {
    return _firestore
        .collection('orders')
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CustomerOrder.fromFirestore(doc)).toList();
    });
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({'status': status});
  }

  Future<Map<String, int>> getProductSales({DateTime? startDate, DateTime? endDate, String? status}) async {
    Query ordersQuery = _firestore.collection('orders');

    // Filtrar por fecha
    if (startDate != null && endDate != null) {
      ordersQuery = ordersQuery
          .where('orderDate', isGreaterThanOrEqualTo: startDate)
          .where('orderDate', isLessThanOrEqualTo: endDate);
    }

    if (status != null) {
      ordersQuery = ordersQuery.where('status', isEqualTo: status);
    }

    final ordersSnapshot = await ordersQuery.get();

    if (ordersSnapshot.docs.isEmpty) {
      print('No hay pedidos que coincidan con el filtro aplicado.');
      return {};
    }

    final Map<String, int> productSales = {};

    for (var doc in ordersSnapshot.docs) {
      try {
        List<Map<String, dynamic>> products = List<Map<String, dynamic>>.from(doc['products']);
        for (var product in products) {
          final productName = product['productName'];
          final quantity = (product['quantity'] as num).toInt();

          if (productSales.containsKey(productName)) {
            productSales[productName] = productSales[productName]! + quantity;
          } else {
            productSales[productName] = quantity;
          }
        }
      } catch (e) {
        print('Error al procesar el documento: ${doc.id}, Error: $e');
      }
    }
    return productSales;
  }
}
