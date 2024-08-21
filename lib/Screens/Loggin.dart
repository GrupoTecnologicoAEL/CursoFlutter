import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Screens/Admin/admin_screen.dart';
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
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );
        final UserCredential authResult =
            await _auth.signInWithCredential(credential);
        final User? user = authResult.user;
        final AdditionalUserInfo? additionalUserInfo =
            authResult.additionalUserInfo;

        if (user != null) {
          final role = await _getUserRole(user);
          if (additionalUserInfo?.isNewUser == true) {
            context.go('/client');
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
  Future<void> signUp(
      BuildContext context, String email, String password) async {
    try {
      final UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
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
  Future<String> signIn(
      BuildContext context, String email, String password) async {
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
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found') {
        return "No se encontró un usuario con ese correo electrónico";
      } else if (error.code == 'wrong-password') {
        return "Contraseña incorrecta";
      } else {
        return "Error en el inicio de sesión";
      }
    } catch (error) {
      print("Error en el inicio de sesión");
      return "Error desconocido, inténtelo de nuevo más tarde";
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

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  void _handleSignIn(AuthProvider authProvider) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, complete todos los campos';
      });
      return;
    }

    final result = await authProvider.signIn(context, email, password);
    if (result != "Inicio de sesión exitoso") {
      setState(() {
        _errorMessage = result;
      });
    }
  }

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
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
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
              onPressed: () => _handleSignIn(authProvider),
              child: Text('Iniciar sesión'),
            ),
            TextButton(
              onPressed: () => authProvider.signInWithGoogle(context),
              child: Text('Iniciar Sesión con Google'),
            ),
            TextButton(
              onPressed: () => authProvider.signUp(
                context,
                _emailController.text,
                _passwordController.text,
              ),
              child: Text('Crear Cuenta'),
            ),
            TextButton(
              onPressed: () => authProvider.signOut(),
              child: Text('Olvidé mi contraseña'),
            ),
          ],
        ),
      ),
    );
  }
}
