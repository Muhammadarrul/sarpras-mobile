import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/daftar_pengembalian_model.dart';

class DaftarPengembalianService {
  final String baseUrl = "http://127.0.0.1:8000/api/pengembalian";
  final Duration timeout = const Duration(seconds: 15);

  Future<List<DaftarPengembalian>> fetchData(String token) async {
    try {
      print("Mengambil data pengembalian...");
      
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(timeout, onTimeout: () {
        throw Exception('Request timed out after ${timeout.inSeconds} seconds');
      });

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        
        if (responseData is List) {
          return responseData.map<DaftarPengembalian>((json) => DaftarPengembalian.fromJson(json)).toList();
        } else if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data') && responseData['data'] is List) {
            return (responseData['data'] as List)
                .map<DaftarPengembalian>((json) => DaftarPengembalian.fromJson(json))
                .toList();
          } else {
            return [DaftarPengembalian.fromJson(responseData)];
          }
        } else {
          throw FormatException("Invalid response format");
        }
      } else {
        throw http.ClientException(
          'Failed to load data. Status: ${response.statusCode}',
          Uri.parse(baseUrl),
        );
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } on FormatException catch (e) {
      throw Exception('Data parsing error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }
}