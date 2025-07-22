import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/barang_model.dart';

class BarangService {
  Future<List<Barang>> fetchBarangs(String token) async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/barangs'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List list = data['data'];
      return list.map((e) => Barang.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat data barang');
    }
  }
}
