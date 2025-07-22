import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class PengembalianService {
  Future<bool> kirimPengembalian({
    required int id,
    required String keterangan,
    File? imageFile,
    Uint8List? webImageBytes,
    required String token,
  }) async {
    try {
      final url = Uri.parse('http://127.0.0.1:8000/api/pengembalian/$id');

      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['keterangan'] = keterangan;

      if (kIsWeb && webImageBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          webImageBytes,
          filename: 'upload_web.png',
          contentType: MediaType('image', 'png'),
        ));
      } else if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      print('Status: ${response.statusCode}');
      print('Response: $respStr');

      // Anggap berhasil kalau status code 200 atau 201
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Exception: $e');
      return false;
    }
  }
}
