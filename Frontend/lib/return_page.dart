import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_library/Borrowdata.dart';
import 'package:my_library/listbilds.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class Returnpage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
 return _Returnpage();
  }
}
class _Returnpage extends State<Returnpage>{
  final TextEditingController _controller= TextEditingController();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final String baseurl = "${dotenv.env['BASE_URL']}";
  int check=0;
  int check2=1;
  String stime='';
  late DateTime selectedDate; // Initializes with current date and time

  List<Borrow> BorrowList= [];
  @override
  void initState(){
    super.initState();
    _fetch();
  }
  void _fetch() async{
    print("GOT HERE");
    final String? token = await secureStorage.read(key: "access_token");
    final response = await http.get(
      Uri.parse("$baseurl/books/borrowed/search/0"),
      headers: {
        'authorization': 'Bearer $token'
      }
    );
    if(response.statusCode == 200){
      final List<dynamic> data = json.decode(response.body);
      BorrowList = data.map((item) => Borrow.fromJson(item)).toList();
      setState(() {});
    }
  }
  void search() async{
    final String? token = await secureStorage.read(key: 'access_token');
    String input;
    input="";
    input=_controller.text;
    BorrowList=[];
    final response = await http.get(
        Uri.parse("$baseurl/books/borrowed/search/$input"),
        headers: {
          'authorization': 'Bearer $token'
        }
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      BorrowList = data.map((item) => Borrow.fromJson(item)).toList();
      setState(() {});
    }//TODO: ELSE PART OF ERROR
    setState((){
      if(check2==1){
        check2=0;
      }
      if(check2==0){

        if(_controller.text.length>0){
          /*for(var i in borrowList){
            if(i.bookId.toString().contains(input) || i.userId.toString().contains(input) || i.transactionId.toString().contains(input)){
              BorrowList.add(i);
            }
          }*/
        }
      }
    });
  }
  void filt(date){

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
                  child: Text("ReturnPage"),
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
                          hintText: "BookId,Userid,transactionId",
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
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black12,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(left: 5),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey),top: BorderSide(color: Colors.grey)),
                ),
                child: Row(
                  children: [
                    Text("return date: " ,style: TextStyle(fontSize: 20),),
                    Container(
                      alignment: Alignment.centerRight,
                      width: MediaQuery.of(context).size.width*0.6,
                      child: Row(
                        children: [
                          if(stime.isNotEmpty)
                            Text(stime ,style: TextStyle(fontSize: 20),),
                          DatePickerWidget(onDateSelected:(date) {
                            setState(() {
                              selectedDate = date;
                              stime = selectedDate.toString();
                              stime = stime.split(" ")[0];
                              List<Borrow> temp = BorrowList;
                              BorrowList = [];
                              for (var i in temp) {
                                if (selectedDate != Null) {
                                  if (i.deadline.isBefore(selectedDate) ||
                                      i.deadline == selectedDate) {
                                    BorrowList.add(i);
                                  }
                                }
                              }
                            });
                          } ),
                        ],
                      )
                    )
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height*0.8,
                child: Borowlistbilt(bolist: BorrowList),
              )
            ],
          ),
        ),
      ),
    );
  }
}