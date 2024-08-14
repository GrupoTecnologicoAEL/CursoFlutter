import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Screens/Login_s.dart';

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
      measurementId: "G-Z9V97FKFT5"
    ),
  );
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tienda Licuados',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}

