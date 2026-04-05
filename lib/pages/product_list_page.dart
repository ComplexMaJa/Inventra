import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../services/database_service.dart';
import '../widgets/product_card.dart';
import '../widgets/overview_cards.dart';
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
  
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = true;

  int get _totalProducts => _filteredProducts.length;
  int get _lowStockCount => _filteredProducts.where((p) => p.stock < 5).length;
  double get _totalValue => _filteredProducts.fold(0.0, (sum, p) => sum + (p.price * p.stock));

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    final products = await _dbService.getAllProducts();

    setState(() {
      _allProducts = products;
      _filteredProducts = products;
      _isLoading = false;
      _listKey = GlobalKey<AnimatedListState>(); 
    });
  }

  void _filterProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredProducts = List.from(_allProducts);
        _listKey = GlobalKey<AnimatedListState>();
      });
    } else {
      final lowerQuery = query.toLowerCase();
      setState(() {
        _filteredProducts = _allProducts.where((p) {
          return p.name.toLowerCase().contains(lowerQuery) || 
                 p.category.toLowerCase().contains(lowerQuery);
        }).toList();
        _listKey = GlobalKey<AnimatedListState>();
      });
    }
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
      
      _allProducts.removeWhere((p) => p.id == product.id);
      final removedProduct = _filteredProducts.removeAt(index);

      if (_listKey.currentState != null) {
        _listKey.currentState!.removeItem(
          index,
          (context, animation) => _buildAnimatedItem(removedProduct, animation, index),
          duration: const Duration(milliseconds: 250),
        );
      } else {
        setState(() {}); 
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product "${product.name}" deleted'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _navigateToForm({Product? product}) async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ProductFormPage(product: product),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
    // Reload items to catch any inserts/updates
    _loadProducts();
    _searchController.clear();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: _filterProducts,
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          filled: true,
          fillColor: Theme.of(context).cardColor, 
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none, 
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_searchController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://media.tenor.com/Bw9ZKZyrig8AAAAj/confused-anime.gif',
              width: 150,
              height: 150,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            const Text(
              '404 Not found UnU, try searching again??',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[700]),
          const SizedBox(height: 16),
          const Text(
            'No products yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first product',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedItem(Product product, Animation<double> animation, int index) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart)),
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
        title: const Text(
          'Inventra Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
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
          : Column(
              children: [
                if (_allProducts.isNotEmpty || _searchController.text.isNotEmpty) ...[
                  _buildSearchBar(),
                  OverviewCards(
                    totalProducts: _totalProducts,
                    lowStockCount: _lowStockCount,
                    totalValue: _totalValue,
                  ),
                ],
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? _buildEmptyState()
                      : AnimatedList(
                          key: _listKey,
                          initialItemCount: _filteredProducts.length,
                          padding: const EdgeInsets.only(top: 8, bottom: 88),
                          itemBuilder: (context, index, animation) {
                            return _buildAnimatedItem(_filteredProducts[index], animation, index);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7C4DFF),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _navigateToForm(),
        tooltip: 'Add Product',
        child: const Icon(Icons.add),
      ),
    );
  }
}
