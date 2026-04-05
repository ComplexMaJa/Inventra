import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:sqflite/sqflite.dart';
import 'pages/login_page.dart';
import 'pages/product_list_page.dart';
import 'theme/app_theme.dart';

/// Entry point aplikasi Manajemen Produk Toko Online.
///
/// Aplikasi ini merupakan sistem CRUD sederhana untuk mengelola produk
/// toko online. Fitur utama:
/// - Login dengan kredensial hardcoded (admin / 1234)
/// - Login persisten (tetap login setelah restart)
/// - Tambah, lihat, edit, dan hapus produk
/// - Data disimpan secara lokal menggunakan SQLite (sqflite)
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi database factory untuk web agar sqflite bisa berjalan
  // di platform web (menggunakan sql.js / IndexedDB di belakang layar)
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  runApp(const MyApp());
}

/// Root widget aplikasi.
///
/// Menggunakan MaterialApp dengan tema dasar. Halaman awal ditentukan
/// berdasarkan status login yang tersimpan di SharedPreferences.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Manajemen Produk Toko Online',
      debugShowCheckedModeBanner: false, // Sembunyikan banner debug
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Otomatis ikuti tema sistem
      // Gunakan FutureBuilder untuk mengecek status login yang tersimpan
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          // Tampilkan loading saat mengecek status login
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Jika sudah pernah login → langsung ke ProductListPage
          // Jika belum → tampilkan LoginPage
          final isLoggedIn = snapshot.data ?? false;
          return isLoggedIn ? const ProductListPage() : const LoginPage();
        },
      ),
    );
  }

  /// Mengecek apakah user sudah login sebelumnya.
  ///
  /// Membaca status login dari SharedPreferences.
  /// Mengembalikan true jika user sudah login, false jika belum.
  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
