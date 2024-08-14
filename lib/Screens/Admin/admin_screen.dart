import 'package:flutter/material.dart';


class AdminHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Text('Pantalla Administrador'),
      ),
      body: Center(
        child: Text('Bienvenido, Admin!'),
      ),
    );
  }
}

