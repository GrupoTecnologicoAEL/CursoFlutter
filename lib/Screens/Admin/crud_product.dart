import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddEditProductScreen extends StatefulWidget {
  final String? productId;

  AddEditProductScreen({this.productId});

  @override
  _AddEditProductScreenState createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  html.File? _imageFile;
  bool _isLoading = false;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _loadProductData();
    }
  }

  Future<void> _loadProductData() async {
    final response = await http.get(Uri.parse('http://localhost:5001/api/products/${widget.productId}'));

    if (response.statusCode == 200) {
      final productData = json.decode(response.body);
      setState(() {
        _nameController.text = productData['name'];
        _descriptionController.text = productData['description'];
        _priceController.text = productData['price'].toString();
        _imageUrl = productData['imageUrl'];
      });
    } else {
      throw Exception('Failed to load product');
    }
  }

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

  Future<String> _uploadImage() async {
    if (_imageFile == null) return '';

    String fileName = _imageFile!.name;
    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');

    UploadTask uploadTask = firebaseStorageRef.putBlob(_imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;

    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String name = _nameController.text.trim();
        String description = _descriptionController.text.trim();
        double price = double.parse(_priceController.text.trim());
        String? imageUrl = _imageUrl;

        if (_imageFile != null) {
          imageUrl = await _uploadImage();
        }

        final Map<String, dynamic> productData = {
          'name': name,
          'description': description,
          'price': price,
          'imageUrl': imageUrl,
        };

        if (widget.productId == null) {
          final response = await http.post(
            Uri.parse('http://localhost:5001/api/products'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(productData),
          );

          if (response.statusCode != 201) {
            throw Exception('Failed to create product');
          }
        } else {
          final response = await http.put(
            Uri.parse('http://localhost:5001/api/products/${widget.productId}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(productData),
          );

          if (response.statusCode != 200) {
            throw Exception('Failed to update product');
          }
        }

        Navigator.pop(context); // Regresa a la pantalla anterior después de guardar
      } catch (e) {
        print(e);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteProduct() async {
    if (widget.productId != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.delete(
          Uri.parse('http://localhost:5001/api/products/${widget.productId}'),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to delete product');
        }

        Navigator.pop(context); // Regresa a la pantalla anterior después de eliminar
      } catch (e) {
        print(e);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId == null ? 'Add Product' : 'Edit Product'),
        actions: widget.productId != null
            ? [
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: _deleteProduct,
                ),
              ]
            : null,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Product Name'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter the product name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter the product description';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter the product price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    _imageFile == null && _imageUrl == null
                        ? Text('No image selected.')
                        : _imageFile != null
                            ? Image.network(
                                _imageUrl!,
                                height: 150,
                              )
                            : Image.network(
                                _imageUrl!,
                                height: 150,
                              ),
                    TextButton(
                      onPressed: _pickImage,
                      child: Text('Pick Image'),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveProduct,
                      child: Text('Save Product'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
