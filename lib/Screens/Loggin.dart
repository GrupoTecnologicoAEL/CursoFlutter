import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'Admin/admin_screen.dart';
import 'Client/client_screen.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<String> _getUserRole(User user) async {
    final doc = await _firestore.collection('Users').doc(user.uid).get();
    return doc.data()?['role'] ?? 'client'; // Asume 'client' si no hay rol.
  }

  // Función para iniciar sesión con Google
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );
        final UserCredential authResult = await _auth.signInWithCredential(credential);
        final User? user = authResult.user;
        final AdditionalUserInfo? additionalUserInfo = authResult.additionalUserInfo;

        if (user != null) {
          final role = await _getUserRole(user);
          if (additionalUserInfo?.isNewUser == true) {
            context.go('/register');
          } else {
            context.go(role == 'admin' ? '/admin' : '/client');
          }
          notifyListeners();
        }
      }
    } catch (error) {
      print("Error en Google Sign-In: $error");
    }
  }

  // Función para registrarse con email y contraseña
  Future<void> signUp(BuildContext context, String email, String password) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = credential.user;

      if (user != null) {
        context.go('/register');
        notifyListeners();
      }
    } catch (error) {
      print("Error en el registro: $error");
    }
  }

  // Función para iniciar sesión con email y contraseña
  Future<String> signIn(BuildContext context, String email, String password) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = credential.user;

      if (user != null) {
        final role = await _getUserRole(user);
        context.go(role == 'admin' ? '/admin' : '/client');
        notifyListeners();
        return "Inicio de sesión exitoso";
      } else {
        return "El usuario no existe, debe registrarse";
      }
    } catch (error) {
      print("Error en el inicio de sesión: $error");
      return "Correo o contraseña incorrectos";
    }
  }

  // Función para cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await googleSignIn.signOut();
      notifyListeners();
    } catch (error) {
      print("Error al cerrar sesión: $error");
    }
  }
}

// Implementación de GoRouter con la lógica de redirección según el rol

final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (BuildContext context, GoRouterState state) async {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    
    if (isLoggedIn) {
      final user = FirebaseAuth.instance.currentUser!;
      final role = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get()
          .then((doc) => doc.data()?['role'] ?? 'client');

      if (state.uri.toString() == '/login') {
        return role == 'admin' ? '/admin' : '/client';
      }
    } else if (state.uri.toString() != '/login') {
      return '/login';
    }

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

// Pantalla de inicio de sesión

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = AuthProvider();

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => authProvider.signIn(
                context,
                _emailController.text,
                _passwordController.text,
              ),
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () => authProvider.signInWithGoogle(context),
              child: Text('Login with Google'),
            ),
            TextButton(
              onPressed: () => authProvider.signUp(
                context,
                _emailController.text,
                _passwordController.text,
              ),
              child: Text('Create Account'),
            ),
            TextButton(
              onPressed: () => authProvider.signOut(),
              child: Text('Forgot Password?'),
            ),
          ],
        ),
      ),
    );
  }
}
