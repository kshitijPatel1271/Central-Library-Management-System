import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class IssueBook extends StatefulWidget {
  const IssueBook({super.key});

  @override
  State<IssueBook> createState() => _IssueBookState();
}

class _IssueBookState extends State<IssueBook> {
  DateTime? selectedBorrowDate;
  DateTime? selectedReturnDate;
  final TextEditingController _mid = TextEditingController();
  final TextEditingController _bid = TextEditingController();
  String returnDateText = "Select Deadline Date";
  String borrowDateText = "Select Borrow Date";
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  Future<void> _selectDate(BuildContext context, String field) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(1900);
    DateTime lastDate =
    field == "borrow" ? DateTime.now() : DateTime.now().add(const Duration(days: 365));

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (field == "borrow") {
          selectedBorrowDate = picked;
          borrowDateText = DateFormat("dd-MM-yyyy").format(picked);
        } else {
          selectedReturnDate = picked;
          returnDateText = DateFormat("dd-MM-yyyy").format(picked);
        }
      });
    }
  }
  void _onsubmit() async{
    final String apiurl = "${dotenv.env['BASE_URL']}/libraries/record-borrow";
    final String? token = await secureStorage.read(key: "access_token");
    final response = await http.post(
      Uri.parse(apiurl),
      headers: {"accept": "application/json", "Content-Type": "application/json",'Authorization': 'Bearer $token'},
      body: json.encode({
        "mid":_mid.toString() as int,
        "bid":_bid.toString() as int,
        "borrowdate":borrowDateText,
        "deadline":returnDateText
      }),
    );
    if (response.statusCode == 200){
      final data = json.decode(response.body);
    } else {
      final error = json.decode(response.body)['detail'];
      _showError(error);
    }
  }//TODO:SHOW TID TO THE USER AND MAKE CHANGES IN RECORD BORROW CREATION TO RETURN BorrowRecordResponse

  void _showError(String msg){
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Record Failed"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Issue Book',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 4, 52, 91),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 150),
            TextField(
              controller: _mid,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                labelText: 'Member ID',
                labelStyle: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
                hintText: 'Enter Member ID',
                hintStyle: const TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bid,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                labelText: 'Book ID',
                labelStyle: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
                hintText: 'Enter Book ID',
                hintStyle: const TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context, "borrow"),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      borrowDateText,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.calendar_today,
                        color: Color.fromARGB(255, 30, 30, 31)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _selectDate(context, "Deadline"),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      returnDateText,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.calendar_today,
                        color: Color.fromARGB(255, 30, 30, 31)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _onsubmit;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Issue Book',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}