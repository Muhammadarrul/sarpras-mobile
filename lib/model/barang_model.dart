class Barang {
  final int id;
  final String nama;
  final String deskripsi;
  final String? gambar;
  final int stock;
  final Kategori? kategori;

  Barang({
    required this.id,
    required this.nama,
    required this.deskripsi,
    this.gambar,
    required this.stock,
    this.kategori,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: json['id'],
      nama: json['nama_barang'],
      deskripsi: json['deskripsi'],
      gambar: json['gambar'],
      stock: json['stock'],
      kategori: json['kategori'] != null
          ? Kategori.fromJson(json['kategori'])
          : null,
    );
  }
}

class Kategori {
  final String nama;

  Kategori({required this.nama});

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(nama: json['nama_kategori']);
  }
}
