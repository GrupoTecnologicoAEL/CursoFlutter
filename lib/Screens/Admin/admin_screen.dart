import 'package:flutter/material.dart';
import '../Loggin.dart';
import '../Admin/admin_list_product.dart';
class AdminHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pantalla Admin'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bienvenido, Admin!'),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminProductListScreen()),
                );
              },
              child: Text('Ver mis productos'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Logout!'),
            ),
          ],
        ),
      ),
    );
  }
}