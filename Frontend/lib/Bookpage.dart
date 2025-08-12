import 'package:flutter/material.dart';
import 'package:my_library/book_list.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:my_library/lib.dart';
import 'package:my_library/listbilds.dart';
class Bookpage extends StatefulWidget {
  final Book book;
  const Bookpage({super.key, required this.book});

  @override
  State<StatefulWidget> createState() => _bookpage(book: book);
}
class _bookpage extends State<Bookpage>{
  Book book;
  List<Library> listoflib = [];
  _bookpage({required this.book});
  final FlutterSecureStorage flutterSecureStorage = const FlutterSecureStorage();
  void _fetcher() async{
    final String apiurl = "${dotenv.env['BASE_URL']}/library/search/${book.id}";
    final String? token = await flutterSecureStorage.read(key: "access_token");
    final response = await http.get(
        Uri.parse(apiurl),
        headers: {'Authorization': 'Bearer $token'}
    );
    if (response.statusCode == 200){
      listoflib = json.decode(response.body);
    }else{
      final error = jsonDecode(response.body)['detail'];
      _showError(error);
    }
  }
  void _fav_add() async{
    final String apiurl = "${dotenv.env['BASE_URL']}/users/add-to-fav/${book.id}";
    final String? token = await flutterSecureStorage.read(key: "access_token");
    final response = await http.post(
      Uri.parse(apiurl),
      headers: {
        "accept": "application/json",
        'Authorization': 'Bearer $token'
      },
    );
    if (response.statusCode == 200){
      final msg = json.decode(response.body)['message'];
      //_showSuccess(msg);
    }
  }
  void _showSuccess(String msg){
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Success"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
  void _showError(String msg){
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Login Failed"),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
      ),
      body:Container(
        height: MediaQuery.of(context).size.height*1,
        color: Color(0xFFD5DDE4),
        child: SingleChildScrollView(
          child: Container(

            padding: EdgeInsets.only(top: 10),
            child: Column(
              children: [

                Container(
                  margin: EdgeInsets.only(bottom: 5),
                  height: MediaQuery.of(context).size.height*0.4,
                  alignment: Alignment.center,
                  child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: Image.network(book.img)),
                ),
                Container(
                  width: MediaQuery.of(context).size.width*1,
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey),top: BorderSide(color: Colors.grey))),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        width: MediaQuery.of(context).size.width*0.8,
                        child:  Text(book.name,textAlign: TextAlign.left, style: TextStyle(fontSize: 20),),),
                      Container(width: MediaQuery.of(context).size.width*0.15, alignment: Alignment.centerRight,child: IconButton(onPressed: (){
                        _fav_add();
                      }, icon: Icon(Icons.favorite))),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                      children: [
                        Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Text("Author:${book.author}", style: TextStyle(fontSize: 20)),
                            alignment: Alignment.centerLeft),
                        Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Text("Genre:${book.genre}", style: TextStyle(fontSize: 20)),
                            alignment: Alignment.centerLeft),
                        Container(
                            padding: EdgeInsets.only(left: 10),
                            child: Text("Description:${book.description}", style: TextStyle(fontSize: 20)),
                            alignment: Alignment.centerLeft),

                      ]
                  ),
                ),
                if(listoflib.isNotEmpty)
                  Container(
                      height: 220,
                      child: libcardbuilder(lilist: listoflib)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}