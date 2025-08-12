import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_library/changebyconfirm.dart';
import 'forgotpassword.dart';
import 'package:http/http.dart' as http;
class Confirmpass extends StatefulWidget{
  @override
  State<Confirmpass> createState() {
    return _confirmpass();
  }
}
class _confirmpass extends State<Confirmpass>{
  final TextEditingController prepass= TextEditingController();
  final String baseurl = "${dotenv.env["BASE_URL"]}";
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  void _checker() async{
    bool checked = false;
    final String? token = await secureStorage.read(key: "access_token");
    final response = await http.post(
      Uri.parse("$baseurl/users/ver-pass"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: json.encode({
        "password": prepass.text,
      }),
    );
    if (response.statusCode == 200) {
      bool checked = json.decode(response.body);
      if (checked) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Changebyconfirm()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Incorrect Password')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response.statusCode}')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(5),
            child: TextField(
              controller: prepass,
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.black
                ),
                border:OutlineInputBorder(),
                hintText: "previous passwors",
                hintStyle: TextStyle(fontSize: 20),
                contentPadding: EdgeInsets.only(top: 2),
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(left: 3),
            child: ElevatedButton(
              onPressed: (){
                _checker();
              },
              child: Text("Submit",style: TextStyle(fontSize: 20),),
              style:ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)
                  )
              ) ,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ForgotPassword(),
                ),
              );
            },
            child: const Text('Forgot Password?'),
          ),
        ],
      ),
    );
  }
}