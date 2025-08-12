import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_library/Borrowdata.dart';
import 'package:my_library/listbilds.dart';
import 'package:http/http.dart' as http;
class UserBorrow extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _UserBorrow();
  }

}
class _UserBorrow extends State<UserBorrow>{
  List<Borrow> BorrowList=[];
  final String baseurl = "${dotenv.env['BASE_URL']}/books/my-borrowed-books";
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  @override
  void initState(){
    super.initState();
    fetch();
  }
  void fetch()async{
    final String? token = await secureStorage.read(key: "access_token");
    final response = await http.get(
      Uri.parse(baseurl),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200){
      print(json.decode(response.body));
      final responseData = jsonDecode(response.body);
      setState(() {
        BorrowList = (responseData as List).map((item) => Borrow.fromJson(item)).toList();
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return Scaffold(
     appBar: AppBar(
       title: Text("UserBorrow"),
       backgroundColor: Colors.blue,
     ),
     body:Borowlistbilt2(bolist: BorrowList),
   );
  }

}