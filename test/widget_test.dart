import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/Screens/Client/blog.dart'; 

void main() {
  testWidgets('BlogScreen renders with all blog posts', (WidgetTester tester) async {

    await tester.pumpWidget(MaterialApp(home: BlogScreen()));


    debugDumpApp();  

    expect(find.text('Bienvenido a tu Blog Nutricional'), findsOneWidget);

    debugPrint('Verificando los posts del blog...');
    expect(find.text('La importancia de los macronutrientes'), findsOneWidget);
    expect(find.text('Los micronutrientes y su papel en la salud'), findsOneWidget);

    debugPrint('Prueba de BlogScreen completada.');
  });
}


