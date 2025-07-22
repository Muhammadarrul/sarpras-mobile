class DaftarPengembalian {
  final int id;
  final int userId;
  final int barangId;
  final Barang barang;
  final DateTime tanggalPengembalian;
  final String status;
  final String keterangan;
  final String? image;

  DaftarPengembalian({
    required this.id,
    required this.userId,
    required this.barangId,
    required this.barang,
    required this.tanggalPengembalian,
    required this.status,
    required this.keterangan,
    this.image,
  });

  factory DaftarPengembalian.fromJson(Map<String, dynamic> json) {
    try {
      return DaftarPengembalian(
        id: json['id'] ?? 0,
        userId: json['user_id'] ?? 0,
        barangId: json['barang_id'] ?? 0,
        barang: Barang.fromJson(json['barang'] ?? {}),
        tanggalPengembalian: DateTime.parse(
          json['tanggal_pengembalian'] ?? DateTime.now().toString(),
        ),
        status: json['status'] ?? 'unknown',
        keterangan: json['keterangan'] ?? '',
        image: json['image'],
      );
    } catch (e) {
      print("Error parsing pengembalian: $e");
      throw Exception("Gagal memparsing data pengembalian");
    }
  }
}

class Barang {
  final int id;
  final String namaBarang;

  Barang({required this.id, required this.namaBarang});

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: json['id'] ?? 0,
      namaBarang: json['nama_barang'] ?? 'Unknown Item',
    );
  }
}