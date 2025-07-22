import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pbo_mobile/page/login_page.dart';
import 'package:pbo_mobile/page/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialPage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final userJson = prefs.getString('user');

    if (token.isNotEmpty && userJson != null) {
      final user = jsonDecode(userJson) as Map<String, dynamic>;
      if (user['id'] != null) {
        return HomePage(
          token: token,
          user: user,
          title: 'Beranda',
        );
      }
    }

    return const LoginPage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Your App',
      theme: ThemeData.dark(),
      home: FutureBuilder<Widget>(
        future: _getInitialPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data!;
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
