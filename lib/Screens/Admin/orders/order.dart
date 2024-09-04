import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerOrder {
  final String id;
  final String clientId;
  final List<Map<String, dynamic>> products;
  final String status;
  final double totalPrice;
  final String nameCustomer; 
  final String deliveryAddress;
  final String notes;
  final String contact;
  final DateTime? orderDate;

  CustomerOrder({
    required this.id,
    required this.clientId,
    required this.products,
    required this.status,
    required this.totalPrice,
    required this.nameCustomer,
    required this.deliveryAddress,
    required this.notes,
    required this.contact,
    this.orderDate,
  });

  factory CustomerOrder.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CustomerOrder(
      id: doc.id,
      clientId: data['clientId'],
      products: List<Map<String, dynamic>>.from(data['products'].map((product) => {
        'productName': product['productName'] ?? 'Producto desconocido',
        'quantity': product['quantity'] ?? 1,
      })),
      status: data['status'],
      totalPrice: data['totalPrice'].toDouble(),
      nameCustomer: data['nameCustomer'],
      deliveryAddress: data['deliveryAddress'],
      notes: data['notes'] ?? '',
      contact: data['contact'] ?? 'Sin contacto',
      orderDate: (data['orderDate'] as Timestamp?)?.toDate(),
    );
  }
}