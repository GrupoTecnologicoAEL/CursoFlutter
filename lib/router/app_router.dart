import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Importaciones de las pantallas necesarias para la navegación
import '../Screens/Admin/admin_screen.dart';
import '../Screens/Client/client_screen.dart';
import '../Screens/Loggin.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (BuildContext context, GoRouterState state) {
    final bool isLoggingIn = state.uri.toString() == '/login';
    final bool isLoggedIn = _auth.currentUser != null;

    // Si el usuario está intentando acceder al login pero ya está autenticado
    if (isLoggingIn && isLoggedIn) {
      return '/client'; // redirige al cliente si ya está autenticado
    }

    // Si el usuario no está autenticado y trata de acceder a rutas que requieren autenticación
    if (!isLoggedIn && state.uri.toString() != '/login') {
      return '/login';
    }

    // Si no hay condiciones de redirección, retornar null
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => AdminHomeScreen(),
    ),
    GoRoute(
      path: '/client',
      builder: (context, state) => ClientHomeScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'Tienda Licuados',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
