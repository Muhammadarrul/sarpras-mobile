class Peminjaman {
  final int id;
  final int userId;
  final int barangId;
  final int jumlah;
  final String status;
  final String tanggalPinjam;
  final String? tanggalKembali;
  final String? namaBarang;

  Peminjaman({
    required this.id,
    required this.userId,
    required this.barangId,
    required this.jumlah,
    required this.status,
    required this.tanggalPinjam,
    this.tanggalKembali,
    this.namaBarang,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    return Peminjaman(
      id: json['id'],
      userId: json['user_id'],
      barangId: json['barang_id'],
      jumlah: json['jumlah'],
      status: json['status'],
      tanggalPinjam: json['tanggal_pinjam'],
      tanggalKembali: json['tanggal_kembali'],
      namaBarang: json['barang'] != null ? json['barang']['nama_barang'] : null,
    );
  }
}
