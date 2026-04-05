import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/product.dart';
import '../services/database_service.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  String? _selectedCategory;
  final List<String> _categories = [
    'Electronics',
    'Fashion',
    'Home & Living',
    'Beauty',
    'Sports',
    'Books',
    'Food & Beverage',
    'Toys',
    'Automotive',
    'Other'
  ];

  final DatabaseService _dbService = DatabaseService();
  bool get _isEditing => widget.product != null;

  String? _imagePath;
  String? _imageBase64;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.product!.name;
      _selectedCategory = _categories.contains(widget.product!.category) 
          ? widget.product!.category 
          : 'Other';
      _priceController.text = widget.product!.price.toStringAsFixed(0);
      _stockController.text = widget.product!.stock.toString();
      _descriptionController.text = widget.product!.description ?? '';
      _imagePath = widget.product!.imagePath;
      _imageBase64 = widget.product!.imageBase64;
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);
      setState(() {
        _imagePath = image.path;
        _imageBase64 = base64String;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final product = Product(
      id: _isEditing
          ? widget.product!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      category: _selectedCategory!,
      price: double.parse(_priceController.text.trim()),
      stock: int.parse(_stockController.text.trim()),
      description: _descriptionController.text.trim(),
      imagePath: _imagePath,
      imageBase64: _imageBase64,
    );

    if (_isEditing) {
      await _dbService.updateProduct(product);
    } else {
      await _dbService.insertProduct(product);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Produk berhasil diperbarui'
                : 'Produk berhasil ditambahkan',
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Product' : 'Add Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ======== Image Picker ======
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        width: 2,
                      ),
                      image: _imageBase64 != null
                          ? DecorationImage(
                              image: MemoryImage(base64Decode(_imageBase64!)),
                              fit: BoxFit.cover,
                            )
                          : (_imagePath != null
                              ? DecorationImage(
                                  image: kIsWeb 
                                      ? NetworkImage(_imagePath!) as ImageProvider
                                      : FileImage(File(_imagePath!)),
                                  fit: BoxFit.cover,
                                )
                              : null),
                    ),
                    child: (_imagePath == null && _imageBase64 == null)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text('Add Image',
                                  style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary)),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ====== Field Nama Produk ======
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Product name cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ====== Dropdown Kategori ======
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Category cannot be empty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ====== Field Harga ======
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price (Rp)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Price cannot be empty';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'Price must be a number';
                  }
                  if (double.parse(value.trim()) < 0) {
                    return 'Price cannot be negative';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ====== Field Stok ======
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stock',
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Stock cannot be empty';
                  }
                  if (int.tryParse(value.trim()) == null) {
                    return 'Stock must be a whole number';
                  }
                  if (int.parse(value.trim()) < 0) {
                    return 'Stock cannot be negative';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ====== Field Deskripsi ======
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 60.0), // Align icon with top roughly
                    child: Icon(Icons.description),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ====== Tombol Aksi ======
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Theme.of(context).colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProduct,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Save Product',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
