import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_library/listbilds.dart';
import 'package:my_library/book_list.dart';
import 'package:my_library/AddNewBook.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class ADDBooklist extends StatefulWidget{
  @override
  State<ADDBooklist> createState() => _addBooklist();
}
class _addBooklist extends State<ADDBooklist>{
  final TextEditingController _controller= TextEditingController();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final String baseurl = "${dotenv.env['BASE_URL']}";
  int check =1;
  int check2=1;
  List<Book> listofbook=[];
  List<Book> listofauth=[];
  @override
  void initState(){
    super.initState();
    _fetch();
  }
  void _fetch() async{
    final String? token = await secureStorage.read(key: 'access_token');
    final response_book = await http.get(
        Uri.parse("$baseurl/books/search-add?name="),
        headers: {'Authorization': 'Bearer $token'}
    );
    final response_auth = await http.get(
        Uri.parse("$baseurl/books/authors-search-add"),
        headers: {'Authorization': 'Bearer $token'}
    );
    if(response_book.statusCode == 200){
      print(json.decode(response_book.body));
      listofbook = (json.decode(response_book.body) as List).map((e) => Book.fromJson(e)).toList();
    }
    if(response_auth.statusCode == 200){
      print(json.decode(response_auth.body));
      listofauth = (json.decode(response_auth.body) as List).map((e) => Book.fromJson(e)).toList();
    }
  }
  void search() async{
    final String? token = await secureStorage.read(key: 'access_token');
    if(check2==0){
      String input = _controller.text.trim();
      if(input.length>0){
        check=0;
        listofbook=[];
        listofauth=[];
        final response_book = await http.get(
            Uri.parse("$baseurl/books/search-add?name=$input"),
            headers: {'Authorization': 'Bearer $token'}
          );
        final response_auth = await http.get(
            Uri.parse("$baseurl/books/authors-search-add?name=$input"),
            headers: {'Authorization': 'Bearer $token'}
        );
        if(response_book.statusCode == 200){
          listofbook = json.decode(response_book.body);
        }
        if(response_auth.statusCode == 200){
          listofauth = json.decode(response_auth.body);
        }
      }
    }
    if(check2==1){
      setState(() {
        check2=0;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: Container(
          child: Row(
            children: [
              if(check2==1)
                Container(
                  width: MediaQuery.of(context).size.width*0.60,
                  child: Text("Add Book"),
                ),
              if(check2==0)
                Row(
                  children: [
                    Container(
                      height: 40,
                      margin: EdgeInsets.only(
                          left:5,
                          right:5,
                          top:5,
                          bottom:10
                      ),
                      width: MediaQuery.of(context).size.width*0.6,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(7))
                      ),
                      child: TextField(
                        controller: _controller,
                        style: TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                          labelText: "search",
                          labelStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.black
                          ),
                          border:OutlineInputBorder(),
                          hintText: "Book,Id,Author",
                          hintStyle: TextStyle(fontSize: 20,color: Colors.grey),
                          contentPadding: EdgeInsets.only(top: 2),

                        ),
                      ),
                    ),

                  ],
                ),
              IconButton(onPressed: search, icon: Icon(Icons.search))
            ],
          ),
        ),
        backgroundColor: Colors.blue,
      ),

      body: Container(
        padding: EdgeInsets.all(5),
        color: Colors.black12,
        child: Column(
          children: [

            SingleChildScrollView(
              child: Column(
                children: [
                  if(listofbook.isNotEmpty)
                    Container( width:MediaQuery.of(context).size.width*1,padding: EdgeInsets.all(10),child: Text("Books",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),textAlign: TextAlign.left,)),
                  if(listofbook.isNotEmpty)
                    Container(
                        height: 220,
                        child: addBookcardbuilder(libook: listofbook)),
                  if(listofauth.isNotEmpty)
                    Container( width:MediaQuery.of(context).size.width*1,padding: EdgeInsets.all(10),child: Text("Author",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),textAlign: TextAlign.left,)),
                  if(listofauth.isNotEmpty)
                    Container(
                        height: 220,
                        child: addBookcardbuilder(libook: listofauth)),
                  if(check==0 && listofbook.isEmpty && listofauth.isEmpty)
                    Center(child: Container(
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height*0.795,
                      child: Text("No result found", style: TextStyle(color: Colors.grey,fontSize: 40),),
                    )
                    ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context){return AddNewbook();}));     },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}