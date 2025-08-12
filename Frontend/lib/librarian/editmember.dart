import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:my_library/librarian/Member_list.dart';

class EditMember extends StatefulWidget {
  final int MemberId;
  const EditMember({super.key,required this.MemberId});

  @override
  State<EditMember> createState() => _EditMemberState(MemberId);
}

class _EditMemberState extends State<EditMember> {
  final int MemberId;
  _EditMemberState(this.MemberId);
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _uidController = TextEditingController();
  final String baseurl = "${dotenv.env['BASE_URL']}";
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  void _submit() async{
      if (_nameController.text.isEmpty && _emailController.text.isEmpty && _phoneController.text.isEmpty && _uidController.text.isEmpty){
        return;
      }
      final String? token = await secureStorage.read(key: "access_token");
      final response = await http.put(
        Uri.parse("$baseurl/libraries/members/update"),
        headers: {
          'Authorization': 'Bearer $token',
          'content-type': 'application/json',
          'accept': 'application/json',
        },
        body: json.encode({
          'name': _nameController.text,
          'mlid': MemberId,
          'Email': _emailController.text,
          'Phone': _phoneController.text,
          'uid': _uidController.text,
        }),
      );
      if (response.statusCode == 200){
        final data = json.decode(response.body);//TODO: HANDLE THE DATA AND ERROR ELSE PART
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(data['message'])),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) => MemberList()));
      }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Edit Member',
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontStyle: FontStyle.italic),
          ),
          backgroundColor: const Color.fromARGB(255, 4, 52, 91),
          elevation: 0,
        ),
        body: Column(children: [
          SizedBox(height: 20),
          Text('Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              labelText: 'Name',
              labelStyle: TextStyle(fontSize: 15),
              prefixIcon: Icon(Icons.person, size: 15),
            ),
          ),
          SizedBox(height: 20),
          Text('Email',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              labelText: 'Email',
              labelStyle: TextStyle(fontSize: 16),
              prefixIcon: Icon(Icons.email, size: 15),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Phone',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              labelText: 'Phone',
              labelStyle: TextStyle(fontSize: 15),
              prefixIcon: Icon(Icons.phone, size: 15),
            ),
          ),
          Text('User Id',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          TextField(
            controller: _uidController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              labelText: 'User Id',
              labelStyle: TextStyle(fontSize: 16),
              prefixIcon: Icon(Icons.email, size: 15),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _submit();
            },
            child: const Text("Submit", style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
          ),
        ]));
  }
}