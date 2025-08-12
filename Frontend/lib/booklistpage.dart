import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_library/Addbooklist.dart';
import 'package:my_library/libbooks.dart';
import 'package:my_library/listbilds.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
class Booklist extends StatefulWidget{
  @override
  State<Booklist> createState() => _Booklist();
}
class _Booklist extends State<Booklist> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // <--- ADDED
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final String baseurl = "${dotenv.env['BASE_URL']}";
  int check = 1;
  int check2 = 1;
  int page = 0; // <--- ADDED
  bool isLoading = false; // <--- ADDED
  List<Libbook> listofbook = [];
  List<Libbook> listofauth = [];
  List<Libbook> listofid = [];

  @override
  void initState() {
    super.initState();
    fetch();
    _scrollController.addListener(_scrollListener); // <--- ADDED
  }

  @override
  void dispose() {
    _scrollController.dispose(); // <--- ADDED
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent && !isLoading) {
      // User reached bottom
      fetch();
    }
  }

  void fetch() async {
    final String? token = await secureStorage.read(key: 'access_token');
    if (isLoading) return; // Avoid multiple calls
    setState(() => isLoading = true);

    final int limit = 10; // items per page
    final response_book = await http.get(
      Uri.parse("$baseurl/libraries/search-books?name=&skip=${page * limit}&limit=$limit"),
      headers: {'Authorization': 'Bearer $token'},
    );
    final response_auth = await http.get(
      Uri.parse("$baseurl/libraries/search-author?author=&skip=${page * limit}&limit=$limit"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response_book.statusCode == 200 && response_auth.statusCode == 200) {
      final data_book = json.decode(response_book.body);
      final data_auth = json.decode(response_auth.body);

      setState(() {
        listofbook.addAll((data_book['books'] as List).map((item) => Libbook.fromJson(item)).toList());
        listofauth.addAll((data_auth['books'] as List).map((item) => Libbook.fromJson(item)).toList());
        page += 1; // next page
        isLoading = false;
      });
    } else {
      isLoading = false;
      final error1 = json.decode(response_book.body);
      final error2 = json.decode(response_auth.body);
      if (response_book.statusCode != 200) {
        _showError(error1['detail'] ?? 'Unknown error');
      } else {
        _showError(error2['detail'] ?? 'Unknown error');
      }
    }
  }

  void search() async {
    final String? token = await secureStorage.read(key: 'access_token');

    if (check2 == 1) {
      setState(() {
        check2 = 0;
      });
    }

    String input = _controller.text.trim();
    if (input.isNotEmpty) {
      setState(() {
        listofbook = [];
        listofauth = [];
        listofid = [];
        page = 0;
      });

      final int limit = 10;
      final response_book = await http.get(
        Uri.parse("$baseurl/libraries/search-books?name=$input&skip=0&limit=$limit"),
        headers: {'Authorization': 'Bearer $token'},
      );

      final response_auth = await http.get(
        Uri.parse("$baseurl/libraries/search-author?author=$input&skip=0&limit=$limit"),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response_book.statusCode == 200 && response_auth.statusCode == 200) {
        final data_book = json.decode(response_book.body);
        final data_auth = json.decode(response_auth.body);

        setState(() {
          listofbook = (data_book['books'] as List).map((item) => Libbook.fromJson(item)).toList();
          listofauth = (data_auth['books'] as List).map((item) => Libbook.fromJson(item)).toList();
          page = 1;
        });
      } else {
        final error1 = json.decode(response_book.body);
        final error2 = json.decode(response_auth.body);
        if (response_book.statusCode != 200) {
          _showError(error1['detail'] ?? 'Unknown error');
        } else {
          _showError(error2['detail'] ?? 'Unknown error');
        }
      }
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Error"),
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
      appBar:  AppBar(
      title: Container(
        child: Row(
          children: [
            if(check2==1)
              Container(
                width: MediaQuery.of(context).size.width*0.60,
                child: Text("Book List"),
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
              controller: _scrollController,
              child: Column(
                children: [
                  if(listofid.isNotEmpty)
                    Container( width:MediaQuery.of(context).size.width*1,padding: EdgeInsets.all(10),child: Text("Id",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),textAlign: TextAlign.left,)),
                  if(listofid.isNotEmpty)
                    Container(
                        height: 220,
                        child: libbooksBuild(lilist: listofid)),
                  if(listofbook.isNotEmpty)
                    Container( width:MediaQuery.of(context).size.width*1,padding: EdgeInsets.all(10),child: Text("Books",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),textAlign: TextAlign.left,)),
                  if(listofbook.isNotEmpty)
                    Container(
                        height: 220,
                        child: libbooksBuild(lilist: listofbook)),
                  if(listofauth.isNotEmpty)
                    Container( width:MediaQuery.of(context).size.width*1,padding: EdgeInsets.all(10),child: Text("Author",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),textAlign: TextAlign.left,)),
                  if(listofauth.isNotEmpty)
                    Container(
                        height: 220,
                        child: libbooksBuild(lilist: listofauth)),
                  if(check==0 && listofbook.isEmpty && listofauth.isEmpty && listofid.isEmpty)
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
        Navigator.push(context, MaterialPageRoute(builder: (context){return ADDBooklist();}));
      },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),),
    );
  }
  }