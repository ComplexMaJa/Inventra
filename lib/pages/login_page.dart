import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'product_list_page.dart';

/// Halaman login untuk aplikasi Manajemen Produk Toko Online.
///
/// Menggunakan kredensial yang di-hardcode:
///   username: admin
///   password: 1234
///
/// Jika login berhasil, pengguna akan dinavigasi ke ProductListPage.
/// Jika gagal, ditampilkan SnackBar berisi pesan error.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller untuk mengambil input dari TextField
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Key untuk validasi form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Memproses login dengan mengecek kredensial yang diinputkan user.
  ///
  /// Kredensial yang valid:
  ///   username: admin
  ///   password: 1234
  Future<void> _login() async {
    // Validasi form terlebih dahulu
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // Cek kredensial hardcoded
    if (username == 'admin' && password == '1234') {
      // Simpan status login ke SharedPreferences agar tetap login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      // Login berhasil — navigasi ke halaman daftar produk
      // pushReplacement agar user tidak bisa kembali ke login dengan tombol back
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProductListPage()),
      );
    } else {
      // Login gagal — tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username atau password salah!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    // Bersihkan controller saat widget di-dispose untuk menghindari memory leak
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ikon dan judul aplikasi
                const Icon(
                  Icons.store,
                  size: 80,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Inventra',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),

                ),

                const Text(
                  'Aplikasi manajemen toko online',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                  ),

                ),
                const SizedBox(height: 32),

                // Input username
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Input password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true, // Sembunyikan teks password
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Tombol login
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
