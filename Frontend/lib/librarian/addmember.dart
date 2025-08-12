import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_library/librarian/Member_list.dart';
class AddMember extends StatefulWidget {
  const AddMember({super.key});

  @override
  _AddMemberState createState() => _AddMemberState();
}

class _AddMemberState extends State<AddMember> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _uidController = TextEditingController();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final String baseurl = "${dotenv.env['BASE_URL']}";
  void _saveMember() async{
    final String? token = await secureStorage.read(key: "access_token");
    if (_idController.text.isNotEmpty &&
        _nameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty) {
      Map<String, String> newMember = {
        'mlid': _idController.text,
        'name': _nameController.text,
        'Email': _emailController.text,
        'Phone': _phoneController.text,
        'uid': _uidController.text,
      };
      final response = await http.post(
        Uri.parse("$baseurl/libraries/members/add"),
        headers: {
          'Authorization': 'Bearer $token',
          'content-type': 'application/json',
          'accept': 'application/json',
        },
        body: json.encode({
          'mlid': _idController.text,
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'uid': _uidController.text,
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Member added successfully')),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) => MemberList()));
      }
      else{
        final error = json.decode(response.body)['detail'];
        print(error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Member')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: const InputDecoration(labelText: 'ID'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email ID'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone No'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _uidController,
              decoration: const InputDecoration(labelText: 'User Id'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveMember,
              child: const Text('Save Member'),
            ),
          ],
        ),
      ),
    );
  }
}