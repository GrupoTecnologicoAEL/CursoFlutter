import 'package:flutter/material.dart';
import '../Client/product_list_screen.dart';
import '../Loggin.dart' as supAuth;
import 'package:go_router/go_router.dart';

class ClientHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pantalla Cliente'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bienvenido, Cliente!'),
            SizedBox(height: 20), // Espacio entre el texto y el botón
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductListScreen()),
                );
              },
              child: Text('Quiero un licuado!'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                final authProvider = supAuth.AuthProvider();
                await authProvider.signOut();
                GoRouter.of(context).go('/login');
              },
              child: Text('Logout!'),
            ),
          ],
        ),
      ),
    );
  }
}
