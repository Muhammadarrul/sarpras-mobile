class Pengembalian {
  final int id;
  final int peminjamanId;
  final int userId;
  final int barangId;
  final String image;
  final String keterangan;
  final int jumlah;
  final DateTime tanggalPengembalian;
  final String status;

  Pengembalian({
    required this.id,
    required this.peminjamanId,
    required this.userId,
    required this.barangId,
    required this.image,
    required this.keterangan,
    required this.jumlah,
    required this.tanggalPengembalian,
    required this.status,
  });

  factory Pengembalian.fromJson(Map<String, dynamic> json) {
    return Pengembalian(
      id: json['id'],
      peminjamanId: json['peminjaman_id'],
      userId: json['user_id'],
      barangId: json['barang_id'],
      image: json['image'],
      keterangan: json['keterangan'],
      jumlah: json['jumlah'],
      tanggalPengembalian: DateTime.parse(json['tanggal_pengembalian']),
      status: json['status'],
    );
  }
}
