import 'package:http/http.dart' as http;
import 'dart:convert';

class PeminjamanService {
  Future<bool> kirimPeminjaman({
    required int barangId,
    required int jumlah,
    required String jatuhTempo,
    required String token,
  }) async {
    final url = Uri.parse('http://127.0.0.1:8000/api/peminjaman');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'barang_id': barangId.toString(),
        'jumlah': jumlah.toString(),
        'jatuh_tempo': jatuhTempo,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}
