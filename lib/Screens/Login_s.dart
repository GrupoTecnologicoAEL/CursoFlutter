import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Admin/admin_screen.dart';
import 'Client/client_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorMessage = '';

void _login() async {
  try {
    // Asegúrate de que los campos de correo electrónico y contraseña no están vacíos
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Please enter both email and password';
      });
      return;
    }

    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    User? user = userCredential.user;
    if (user != null) {
      print('User ID: ${user.uid}'); // Depuración

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
        print('User Data: $userData'); // Depuración
        String role = userData?['role'] ?? '';

        if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminHomeScreen()),
          );
        } if (role == 'client'){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ClientHomeScreen()),
          );

        } else {
          setState(() {
            errorMessage = 'User role not authorized';
          });
        }
      } else {
        setState(() {
          errorMessage = 'User document does not exist';
        });
      }
    } else {
      setState(() {
        errorMessage = 'User not found';
      });
    }
  } catch (e) {
    print('Login error: $e'); // Depuración
    setState(() {
      errorMessage = 'Login failed: ${e.toString()}';
    });
  }
}
void _register() async {
  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    User? user = userCredential.user;
    if (user != null) {
      // Crear un nuevo documento en Firestore para este usuario
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
        'email': user.email,
        'role': 'user', // Puedes ajustar esto según tu lógica de roles
      });

      // Navegar a la pantalla principal o mostrar un mensaje de éxito
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ClientHomeScreen()), // Reemplaza con la pantalla adecuada
      );
    }
  } catch (e) {
    setState(() {
      errorMessage = 'Failed to create account: ${e.toString()}';
    });
  }
}

void _navigateToRegister() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Create Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: _register,
            child: Text('Create'),
          ),
        ],
      );
    },
  );
}
void _resetPassword() async {
  if (_emailController.text.isEmpty) {
    setState(() {
      errorMessage = 'Please enter your email to reset password';
    });
    return;
  }

  try {
    await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
    setState(() {
      errorMessage = 'Password reset link sent to your email';
    });
  } catch (e) {
    setState(() {
      errorMessage = 'Failed to send password reset link: ${e.toString()}';
    });
  }
}


  @override
  Widget build(BuildContext context) {
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
              onPressed: _login,
              child: Text('Login'),
            ),
            TextButton(
            onPressed: _navigateToRegister,
            child: Text('Create Account'),
            ),
            TextButton(
            onPressed: _resetPassword,
            child: Text('Forgot Password?'),
            ),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}