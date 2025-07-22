import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginService {
  // Base URL API
  static const String _baseUrl = 'http://127.0.0.1:8000/api';

 Future<Map<String, dynamic>> login({
  required String email,
  required String password,
}) async {
  try {
    print('Mengirim request ke: $_baseUrl/login'); // Debug
    print('Dengan data: email=$email, password=[PROTECTED]'); // Debug

    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    print('Status code: ${response.statusCode}'); // Debug
    print('Response body: ${response.body}'); // Debug

    final responseData = jsonDecode(response.body);

    // Debug struktur respons
    print('Response keys: ${responseData.keys}');

    if (response.statusCode == 200) {
      // Cek berbagai kemungkinan nama field token
      final token = responseData['token'] ?? 
                   responseData['access_token'] ?? 
                   responseData['auth_token'];

      if (token == null) {
        print('Token tidak ditemukan. Struktur respons lengkap: $responseData');
        return {
          'success': false,
          'message': 'Token tidak ditemukan dalam respons. Struktur respons: ${responseData.keys}',
          'fullResponse': responseData, // Untuk debugging lebih lanjut
        };
      }

      return {
        'success': true,
        'token': token,
        'user': responseData['user'] ?? responseData['data'],
        'message': responseData['message'] ?? 'Login berhasil',
      };
    } else {
      return {
        'success': false,
        'message': responseData['message'] ?? 
            (response.statusCode == 401 
                ? 'Email atau password salah' 
                : 'Login gagal (${response.statusCode})'),
        'statusCode': response.statusCode,
        'fullResponse': responseData, // Untuk debugging lebih lanjut
      };
    }
  } catch (e) {
    print('Error during login: $e');
    return {
      'success': false,
      'message': 'Terjadi kesalahan: ${e.toString()}',
    };
  }
}

  Future<void> logout(String token) async {
  final response = await http.delete(
    Uri.parse('$_baseUrl/logout'),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Logout gagal. Status: ${response.statusCode}. Body: ${response.body}');
  }

  print('Logout berhasil. Response: ${response.body}');
}

}