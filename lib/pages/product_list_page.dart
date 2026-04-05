import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../services/database_service.dart';
import '../widgets/product_card.dart';
import 'product_form_page.dart';
import 'login_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final DatabaseService _dbService = DatabaseService();
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final products = await _dbService.getAllProducts();

    setState(() {
      _products = products;
      _isLoading = false;
      _listKey = GlobalKey<AnimatedListState>(); // Recreate key to force list rebuild
    });
  }

  Future<void> _deleteProduct(Product product, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmation'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _dbService.deleteProduct(product.id);

      final removedProduct = _products.removeAt(index);

      if (_listKey.currentState != null) {
        _listKey.currentState!.removeItem(
          index,
          (context, animation) => _buildAnimatedItem(removedProduct, animation, index),
          duration: const Duration(milliseconds: 300),
        );
      } else {
        setState(() {}); // Fallback
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product "${product.name}" successfully deleted'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    }
  }

  Future<void> _navigateToForm({Product? product}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormPage(product: product),
      ),
    );
    // Reload items to catch any inserts/updates
    _loadProducts();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  Widget _buildAnimatedItem(Product product, Animation<double> animation, int index) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: ProductCard(
          product: product,
          onEdit: () => _navigateToForm(product: product),
          onDelete: () => _deleteProduct(product, index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(
                  child: Text(
                    'No products available.\nTap + to add.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : AnimatedList(
                  key: _listKey,
                  initialItemCount: _products.length,
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemBuilder: (context, index, animation) {
                    return _buildAnimatedItem(_products[index], animation, index);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: () => _navigateToForm(),
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
    );
  }
}
