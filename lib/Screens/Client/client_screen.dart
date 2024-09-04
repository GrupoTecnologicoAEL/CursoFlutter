import 'package:flutter/material.dart';
import '../Client/product_list_screen.dart';
import '../Loggin.dart' as supAuth;
import 'package:go_router/go_router.dart';
import '../Client/drawer.dart';
import '../Client/blog.dart';

class ClientHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pantalla Cliente'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final authProvider = supAuth.AuthProvider();
              await authProvider.signOut();
              GoRouter.of(context).go('/login');
            },
          ),
        ],
      ),
      drawer: ClientDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;

          return Column(
            children: [
              SizedBox(height: 20),
              Text('Bienvenido', style: TextStyle(fontSize: 24)),
              SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  padding: EdgeInsets.all(16),
                  children: [
                    _buildGridItem(
                      context,
                      icon: Icons.store,
                      label: 'Tienda',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProductListScreen()),
                        );
                      },
                    ),
                    _buildGridItem(
                      context,
                      icon: Icons.library_books,
                      label: 'Blog',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BlogScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.blue),
            SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
