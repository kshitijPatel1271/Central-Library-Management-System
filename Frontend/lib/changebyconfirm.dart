import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_library/loginpage.dart';
import 'package:http/http.dart' as http;

class Changebyconfirm extends StatefulWidget{
  @override
  State<Changebyconfirm> createState() {
    return _changepass();
  }
}
class _changepass extends State<Changebyconfirm>{
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final String baseurl = "${dotenv.env["BASE_URL"]}";
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  String _password='';
  String _confirmPassword='';
  void _submit() async{
    _password=_passwordController.text;
    _confirmPassword=_confirmPasswordController.text;
    if(_password==_confirmPassword && _password.length>=6){
      final String? token = await secureStorage.read(key: "access_token");
      final response = await http.put(
        Uri.parse("$baseurl/users/change-pass"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: json.encode({
          "password": _password,
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password Changed Successfully')),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return LoginPage();
        }));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to change password')),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Change Password"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.all(5),
              child: TextField(
                obscureText: true,
                controller: _passwordController,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  labelText: "New passwprd",
                  labelStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.black
                  ),
                  border:OutlineInputBorder(),
                  hintText: "New password",
                  hintStyle: TextStyle(fontSize: 20),
                  contentPadding: EdgeInsets.only(top: 2),

                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.all(5),
              child: TextField(
                obscureText: true,
                controller: _confirmPasswordController,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  labelText: "Confirm password",
                  labelStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.black
                  ),
                  border:OutlineInputBorder(),
                  hintText: "Confirm password",
                  hintStyle: TextStyle(fontSize: 20),
                  contentPadding: EdgeInsets.only(top: 2),

                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: Text('verify'),
            ),
          ],
        ),
      ),
    );
  }

}