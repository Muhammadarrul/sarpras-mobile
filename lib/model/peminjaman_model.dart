class PeminjamanRequest {
  final int barangId;
  final int jumlah;
  final String jatuhTempo;

  PeminjamanRequest({
    required this.barangId,
    required this.jumlah,
    required this.jatuhTempo,
  });

  Map<String, dynamic> toJson() => {
        'barang_id': barangId.toString(),
        'jumlah': jumlah.toString(),
        'jatuh_tempo': jatuhTempo,
      };
}
