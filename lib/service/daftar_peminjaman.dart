import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/daftar_peminjaman.dart';

class PeminjamanService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<List<Peminjaman>> fetchPeminjaman(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/peminjaman'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final List<dynamic> data = body['data'];

      return data.map((e) => Peminjaman.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat daftar peminjaman');
    }
  }
}
