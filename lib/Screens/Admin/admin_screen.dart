import 'package:flutter/material.dart';
import '../Admin/admin_list_product.dart';
import '../Admin/orders/orders_screen.dart';
import '../Admin/singUpAdmin.dart';  
import '../Loggin.dart' as supAuth;
import 'package:go_router/go_router.dart';
import '../Admin/orders/sales_chart_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Admin Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              leading: Icon(Icons.store),
              title: Text('Ver Productos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminProductListScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Ver Pedidos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminOrdersScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person_add),
              title: Text('Crear Usuario Admin'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminCreateUserScreen()),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          children: <Widget>[
            _buildDashboardCard(
              context,
              title: 'Productos',
              count: 'Ver',
              icon: Icons.store,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminProductListScreen()),
                );
              },
            ),
            _buildDashboardCard(
              context,
              title: 'Pedidos',
              count: 'Ver',
              icon: Icons.shopping_cart,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminOrdersScreen()),
                );
              },
            ),
              _buildDashboardCard(
              context,
              title: 'Reportes',
              count: 'Ver',
              icon: Icons.bar_chart,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SalesChartScreen()),
                );
              },
            ),
            _buildDashboardCard(
              context,
              title: 'Usuarios Admin',
              count: 'Crear',
              icon: Icons.person_add,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminCreateUserScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {required String title, required String count, required IconData icon, required VoidCallback onTap}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 60.0, color: Colors.blue),
              SizedBox(height: 10),
              Text(title, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Text(count, style: TextStyle(fontSize: 16.0, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
