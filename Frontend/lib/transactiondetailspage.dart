import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_library/Borrowdata.dart';
import 'package:http/http.dart' as http;
class TransactionPage extends StatefulWidget{
  final Borrow borrow;

   TransactionPage({super.key, required this.borrow});

  @override
  State<TransactionPage> createState() {
      return _TransactionPage(borrow: borrow);
  }
}
class _TransactionPage extends State<TransactionPage>{
  bool setup= false;
  final String baseurl = "${dotenv.env['BASE_URL']}";
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  void setupvar() async{
    final String? token = await secureStorage.read(key: "access_token");
    final response = await http.put(
      Uri.parse("$baseurl/books/librarian/return-book"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: borrow.transactionId,
    );
    if (response.statusCode == 200) {
      setState(() {
        setup=true;
      });
    } else {
      final error = json.decode(response.body);
      print(error);
    }
  }
  Borrow borrow;
  _TransactionPage({required this.borrow});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(borrow.transactionId),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height*1,
        width: MediaQuery.of(context).size.width*1,
        color: Colors.black12,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(5),
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width*1,
                child: Text("Transaction: ${borrow.transactionId}",style: TextStyle(fontSize: 25,color: Colors.black),
              ),
              ),
              Container(
                width: MediaQuery.of(context).size.width*1,
                height: 1,
                color: Colors.black,
              ),
              Container(
                margin: EdgeInsets.all(3),
                padding: EdgeInsets.only(left: 10),
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width*1,
                child: Text("Book Id: ${borrow.bookId}",style: TextStyle(fontSize: 20,color: Colors.black),
                ),
              ),
              Container(
                margin: EdgeInsets.all(3),
                padding: EdgeInsets.only(left: 10),
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width*1,
                child: Text("Book: ${borrow.bookName}",style: TextStyle(fontSize: 20,color: Colors.black),
                ),
              ),
              Container(
                margin: EdgeInsets.all(3),
                padding: EdgeInsets.only(left: 10),
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width*1,
                child: Text("Assign To: ${borrow.userId}",style: TextStyle(fontSize: 20,color: Colors.black),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width*1,
                height: 1,
                color: Colors.black,
              ),
              Container(
                width: MediaQuery.of(context).size.width*8,
                alignment: Alignment.centerLeft,
                child: Text("🕒: ${(borrow.issueDate).toString().split(" ")[0]} ~ ${borrow.deadline.toString().split(" ")[0]}",
                  style: TextStyle(fontSize: 20,color: Colors.black),),
              ),
              if(borrow.latency>0)
              Container(
                margin: EdgeInsets.all(3),
                padding: EdgeInsets.only(left: 10),
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width*1,
                child: Text("Latancy: ${borrow.latency} days",style: TextStyle(fontSize: 20,color: Colors.red),
                ),
              ),
              if(borrow.penalty>0)
                Container(
                  margin: EdgeInsets.all(3),
                  padding: EdgeInsets.only(left: 10),
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width*1,
                  child: Text("penalty: ${borrow.penalty} Rs",style: TextStyle(fontSize: 20,color: Colors.red),
                  ),
                ),
              Container(
                width: MediaQuery.of(context).size.width*1,
                height: 1,
                color: Colors.black,
              ),
              if(!setup)
              Container(
                margin: EdgeInsets.only(top: 50),
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width*1,
                child:ElevatedButton(onPressed: setupvar,
                    child: Text("Complete",style: TextStyle(
                      fontSize: 25,
                    ),),
                    style:ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(MediaQuery.of(context).size.width*0.8, 50),
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    ),
                      elevation: 7,
                      shadowColor: Colors.black
                    ),
                ) ,
              ),
              if(setup)
                Container(width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.all(20),
                  alignment:Alignment.center,
                  child: Text("Completed",style: TextStyle(color: Colors.green,fontSize: 30),),
                )
            ],
          ),
        ),
      ),
    );
  }
}