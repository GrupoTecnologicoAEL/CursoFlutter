import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Client/client_screen.dart';
import '../Client/cart/cart_screen.dart';
import '../Client/cart/order_status_screen.dart';
import '../Client/blog.dart';
import '../Loggin.dart' as supAuth;
import 'package:go_router/go_router.dart';

class ClientDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menú del Cliente',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Inicio'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClientHomeScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Carrito'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('Mis Pedidos'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClientOrdersScreen(clientId: FirebaseAuth.instance.currentUser!.uid)),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.library_books),
            title: Text('Mi Guía Nutricional'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BlogScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Cerrar Sesión'),
            onTap: () async {
              final authProvider = supAuth.AuthProvider();
              await authProvider.signOut();
              GoRouter.of(context).go('/login');
            },
          ),
        ],
      ),
    );
  }
}
