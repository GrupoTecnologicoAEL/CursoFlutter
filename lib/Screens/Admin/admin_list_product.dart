import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:licuados/Screens/Admin/crud_product.dart';
import 'dart:convert';
import '../../models/product.dart';
import '../../services/api_service.dart';

class AdminProductListScreen extends StatefulWidget {
  @override
  _AdminProductListScreenState createState() => _AdminProductListScreenState();
}

class _AdminProductListScreenState extends State<AdminProductListScreen> {
  late Future<List<Product>> futureProducts;
  final ApiService apiService = ApiService();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    futureProducts = apiService.getProduct();
  }

  Future<List<Product>> _searchProducts(String query) async {
    final allProducts = await apiService.getProduct();
    if (query.isEmpty) {
      return allProducts;
    } else {
      return allProducts
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void _updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery;
      futureProducts = _searchProducts(_searchQuery);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administrar Productos'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => _updateSearchQuery(value),
              decoration: InputDecoration(
                labelText: 'Buscar Producto',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: futureProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No se encontraron productos'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final product = snapshot.data![index];
                      return ListTile(
                        leading: product.imageUrl.isNotEmpty
                            ? Image.network(
                                product.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Icon(Icons.error),
                              )
                            : Icon(Icons.image_not_supported),
                        title: Text(product.name),
                        subtitle: Text(product.description),
                        trailing: Text('\Q${product.price.toString()}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddEditProductScreen(productId: product.id),
                            ),
                          ).then((_) {
                            setState(() {
                              futureProducts = apiService.getProduct();
                            });
                          });
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditProductScreen(),
            ),
          ).then((_) {
            setState(() {
              futureProducts = apiService.getProduct();
            });
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
