import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  final String apiUrl = 'http://localhost:5001/api/products';

  Future<List<Product>> getProduct() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      List<Product> products =
          body.map((dynamic item) => Product.fromJson(item)).toList();
      return products;
    } else {
      throw Exception('Fail to load products');
    }
  }
}
