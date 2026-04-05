import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

/// Service class yang menangani semua operasi database SQLite.
///
/// Menggunakan pola Singleton untuk memastikan hanya ada satu instance
/// database yang aktif di seluruh aplikasi. Semua operasi CRUD untuk
/// tabel 'products' didefinisikan di class ini.
class DatabaseService {
  // Singleton instance — hanya satu DatabaseService di seluruh app
  static final DatabaseService _instance = DatabaseService._internal();

  // Factory constructor mengembalikan singleton instance
  factory DatabaseService() => _instance;

  // Private constructor untuk singleton
  DatabaseService._internal();

  // Referensi ke database SQLite, nullable karena belum diinisialisasi
  static Database? _database;

  /// Getter untuk database. Jika belum diinisialisasi, akan memanggil
  /// _initDatabase() terlebih dahulu.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Menginisialisasi database SQLite.
  ///
  /// Database disimpan di path default device dengan nama 'toko_online.db'.
  /// Saat pertama kali dibuat (onCreate), tabel 'products' akan dibuat
  /// dengan kolom: id, name, category, price, stock.
  Future<Database> _initDatabase() async {
    // Mendapatkan path default untuk database di device
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'toko_online.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        // Membuat tabel products saat database pertama kali dibuat
        await db.execute('''
          CREATE TABLE products (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            price REAL NOT NULL,
            stock INTEGER NOT NULL,
            description TEXT,
            imagePath TEXT,
            imageBase64 TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE products ADD COLUMN description TEXT');
          await db.execute('ALTER TABLE products ADD COLUMN imagePath TEXT');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE products ADD COLUMN imageBase64 TEXT');
        }
      },
    );
  }

  // =====================
  // OPERASI CRUD
  // =====================

  /// CREATE — Menambahkan produk baru ke database.
  ///
  /// Menerima object [Product] dan menyimpannya ke tabel 'products'.
  /// Mengembalikan row id dari record yang baru ditambahkan.
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// READ — Mengambil semua produk dari database.
  ///
  /// Mengembalikan `List<Product>` yang berisi semua record di tabel 'products'.
  /// Jika tabel kosong, mengembalikan list kosong.
  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');

    // Konversi setiap Map menjadi object Product
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  /// UPDATE — Memperbarui data produk yang sudah ada.
  ///
  /// Mencari record berdasarkan id dari [product], lalu memperbarui
  /// semua kolomnya. Mengembalikan jumlah row yang terpengaruh.
  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  /// DELETE — Menghapus produk dari database berdasarkan [id].
  ///
  /// Mengembalikan jumlah row yang terhapus (seharusnya 1 jika berhasil).
  Future<int> deleteProduct(String id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
