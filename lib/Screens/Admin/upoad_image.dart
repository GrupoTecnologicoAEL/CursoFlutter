import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UploadImageScreen extends StatefulWidget {
  @override
  _UploadImageScreenState createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  html.File? _imageFile;
  String? _imageUrl;

  Future<void> _pickImage() async {
    final picker = html.FileUploadInputElement();
    picker.accept = 'image/*';
    picker.click();

    picker.onChange.listen((event) {
      final files = picker.files;
      if (files!.isEmpty) return;
      setState(() {
        _imageFile = files[0];
        _imageUrl = html.Url.createObjectUrl(_imageFile);
      });
    });
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    // Crear una referencia a Firebase Storage
    String fileName = _imageFile!.name;
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('uploads/$fileName');

    // Subir la imagen
    UploadTask uploadTask = firebaseStorageRef.putBlob(_imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;

    // Obtener la URL de descarga de la imagen subida
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    print('Image URL: $downloadUrl');

    // Enviar los datos del producto al backend
    final response = await http.post(
      Uri.parse('http://localhost:5000/api/products'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'name': 'Nombre del Producto',
        'description': 'Descripción del Producto',
        'price': 99.99,
        'imageUrl': downloadUrl
      }),
    );

    if (response.statusCode == 201) {
      print('Producto creado exitosamente');
    } else {
      print('Error al crear el producto');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            if (_imageUrl != null) Image.network(_imageUrl!),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}
