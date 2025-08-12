import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_library/book_list.dart';
import 'package:my_library/lib.dart';
import 'package:my_library/listbilds.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
class Searchpage extends StatefulWidget {
  const Searchpage({super.key});

  @override
  State<Searchpage> createState() => _Searchpage();

}
class _Searchpage extends State<Searchpage>{
  final TextEditingController _controller= TextEditingController();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  late String input;
  List<Book> listofbook=[];
  List<Book> listofauth=[];
  List<Library> listoflib=[];
  int check=1;
  void search() async {
    final String? token = await secureStorage.read(key: 'access_token');
    input = _controller.text;

    if (input.isNotEmpty) {
      setState(() {
        check = 0;
        listofbook = [];
        listofauth = [];
        listoflib = [];
      });

      final baseurl = dotenv.env['BASE_URL'];
      final response_book = await http.get(
        Uri.parse("$baseurl/books/search?name=$input"),
        headers: {'Authorization': 'Bearer $token'},
      );
      final response_auth = await http.get(
        Uri.parse("$baseurl/books/authors-search?name=$input"),
        headers: {'Authorization': 'Bearer $token'},
      );
      final response_lib = await http.get(
        Uri.parse("$baseurl/libraries/search?name=$input"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response_book.statusCode == 200) {
        print(json.decode(response_book.body));
        setState(() {
          listofbook = (json.decode(response_book.body) as List)
              .map((item) => Book.fromJson(item))
              .toList();
        });
      }

      if (response_auth.statusCode == 200) {
        setState(() {
          listofauth = (json.decode(response_auth.body) as List)
              .map((item) => Book.fromJson(item))
              .toList();
        });
      }

      if (response_lib.statusCode == 200) {
        setState(() {
          listoflib = (json.decode(response_lib.body) as List)
              .map((item) => Library.fromJson(item))
              .toList();
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Searchpage",style: TextStyle(color: Colors.white,fontSize:30)),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        color: Colors.white10,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                    top: 6,
                    bottom: 5
                ),
                height:50,
                decoration: BoxDecoration(
                    color: Colors.white12,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(3))
                ),
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          left:5,
                          right:5,
                          top:5,
                          bottom:5
                      ),
                      width: 260,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.all(Radius.circular(5))
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
                          hintText: "Book,Author,Genre",
                          hintStyle: TextStyle(fontSize: 20),
                          contentPadding: EdgeInsets.only(top: 2),

                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      width: 100,
                      padding: EdgeInsets.only(left: 3),
                      child: ElevatedButton(
                        onPressed: search ,
                        child: Text("Search",style: TextStyle(fontSize: 12),),
                        style:ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                            )
                        ) ,
                      ),
                    ),
                  ],
                ),
              ),
              if(listofbook.isNotEmpty)
                Container( width:MediaQuery.of(context).size.width*1,child: Text("Books",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),textAlign: TextAlign.left,)),
              if(listofbook.isNotEmpty)
                Container(
                    height: 210,
                    child: Bookcardbuilder(libook: listofbook)),
              if(listofauth.isNotEmpty)
                Container( width:MediaQuery.of(context).size.width*1,child: Text("Authors",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),textAlign: TextAlign.left,)),
              if(listofauth.isNotEmpty)
                Container(
                    height: 210,
                    child: Bookcardbuilder(libook: listofauth)),
              if(listoflib.isNotEmpty)
                Container( width:MediaQuery.of(context).size.width*1,child: Text("library",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),textAlign: TextAlign.left,)),
              if(listoflib.isNotEmpty)
                Container(
                    height: 220,
                    child: libcardbuilder(lilist: listoflib)),
              if(check==0 && listofbook.isEmpty && listofauth.isEmpty && listoflib.isEmpty)
                Center(child: Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height*0.80,
                  child: Text("No result found", style: TextStyle(color: Colors.grey,fontSize: 40),),
                )
                )
            ],
          ),
        ),
      ),
    );
  }

}