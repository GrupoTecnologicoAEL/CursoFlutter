import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'router/app_router.dart';  
import 'Screens/Client/cart/cart_provider.dart';  
import 'package:google_sign_in/google_sign_in.dart';
import 'Screens/Admin/orders/orders_provider.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAHyCu4HApXlmoU6cRqPTIzDjv4FDzD03I",
      authDomain: "licuados-a7264.firebaseapp.com",
      projectId: "licuados-a7264",
      storageBucket: "licuados-a7264.appspot.com",
      messagingSenderId: "220408518147",
      appId: "1:220408518147:web:a0c59227e1dca18b1aa036",
      measurementId: "G-Z9V97FKFT5",
    ),
  );

  // Inicialización de Google Sign-In con el Client ID
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '205605127098-9klk0h559u9g2pmkbm74hfh7uf1mgsq6.apps.googleusercontent.com',
  );

  runApp(
  MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => CartProvider()),
        Provider(create: (ctx) => OrderService()),  
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Tienda Licuados',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerDelegate: appRouter.routerDelegate,
      routeInformationParser: appRouter.routeInformationParser,
      routeInformationProvider: appRouter.routeInformationProvider,
    );
  }
}