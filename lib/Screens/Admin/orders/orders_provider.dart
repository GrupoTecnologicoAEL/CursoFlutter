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
}
