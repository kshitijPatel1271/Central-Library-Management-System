import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_library/homepage.dart';
import 'package:my_library/loginpage.dart';
import 'package:my_library/librarian/home_page.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyApp();
}
class _MyApp extends State<MyApp>{
  String _userRole = '';
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkLoginStatus());
  }
  void _checkLoginStatus() async {
    String? accessToken = await secureStorage.read(key: "access_token");

    if (accessToken != null && accessToken.isNotEmpty) {
      final response = await http.get(
        Uri.parse("https://your-api.com/auth/verify-token"),
        headers: {"Authorization": "Bearer $accessToken"},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String role = data["role"];
        setState(() {
          _userRole = role; // Store user role
        });
        if (role == "librarian") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Homepage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      } else {
        secureStorage.delete(key: "access_token"); // Clear invalid token
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}
