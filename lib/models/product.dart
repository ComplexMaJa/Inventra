/// Model class yang merepresentasikan sebuah produk di toko online.
///
/// Setiap produk memiliki id unik, nama, kategori, harga, dan jumlah stok.
/// Class ini menyediakan method untuk konversi ke/dari Map agar bisa
/// disimpan dan dibaca dari database SQLite.
class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String? description;
  final String? imagePath;
  final String? imageBase64;

  // Constructor dengan named parameters dan null safety
  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.description,
    this.imagePath,
    this.imageBase64,
  });

  /// Membuat instance Product dari Map (biasanya hasil query database).
  ///
  /// Key dari map harus sesuai dengan nama kolom di tabel 'products'.
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      price: (map['price'] as num).toDouble(),
      stock: map['stock'] as int,
      description: map['description'] as String?,
      imagePath: map['imagePath'] as String?,
      imageBase64: map['imageBase64'] as String?,
    );
  }

  /// Mengkonversi Product menjadi Map untuk disimpan ke database.
  ///
  /// Map yang dihasilkan memiliki key yang sesuai dengan nama kolom
  /// di tabel 'products'.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'description': description,
      'imagePath': imagePath,
      'imageBase64': imageBase64,
    };
  }
}
