import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_library/listbilds.dart';
import 'package:my_library/libbooks.dart';
import 'package:my_library/Addbooklist.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AddNewbook extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _AddNewbook();
}
class _AddNewbook extends State<AddNewbook>{
  final String baseurl = "${dotenv.env['BASE_URL']}";
  final TextEditingController _name= TextEditingController();
  final TextEditingController _auth= TextEditingController();
  final TextEditingController _Lid= TextEditingController();
  final TextEditingController _genre= TextEditingController();
  final TextEditingController _desc= TextEditingController();
  final TextEditingController _Qunti= TextEditingController();
  final TextEditingController _Avi= TextEditingController();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  File? _libraryImage;
  Libbook? _book;
  void _setImage(File? image) {
    setState(() {
      _libraryImage = image;
    });
  }
  void _onsubmit() async{
    final String? token = await secureStorage.read(key: 'access_token');
    final String apiurl = "$baseurl/books/add-book";
    final response = await http.post(
      Uri.parse(apiurl),
      headers: {
        'Content-Type': 'application/json',
        "accept": "application/json",
        'Authorization': 'Bearer $token'
      },
      body: json.encode({
        'name': _name,
      'author': _auth,
      'genre': _genre,
      'description': _desc,
      'cover': _libraryImage,
      'lid':_Lid,
      'available_count': _Avi
      }),
    );
    if(response.statusCode == 200){
      final data = json.decode(response.body);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ADDBooklist())
      );
    } else {
      final error = jsonDecode(response.body)['detail'];
      _showError(error);
    }
  }
  void _showError(String msg){
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Book Registration Failed"),
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
     title: Text("Add New Book"),
     backgroundColor: Colors.blue,
   ),
   body: Container(
     width: MediaQuery.of(context).size.width*1,
     height: MediaQuery.of(context).size.height*1,
     color: Colors.black12,
     child: SingleChildScrollView(
       child: Column(
         children: [
           Container(
             margin: EdgeInsets.all(5),
             height: 250,
             child: Container(
                 decoration: BoxDecoration(
                     border: Border.all(color: Colors.black)
                 ),
                 child: CustomImagePicker(onImageSelected: _setImage)),),
           Container(  margin: EdgeInsets.only(bottom: 10),child: Text("* please filled all details properly ",style: TextStyle(fontSize: 10),),),
           Container(
             margin: EdgeInsets.only(bottom: 10),
             child: TextField(
               controller: _name,
               style: TextStyle(fontSize: 20),
               decoration: InputDecoration(
                 labelText: "Name",
                 labelStyle: TextStyle(
                     fontSize: 12,
                     color: Colors.black
                 ),
                 border:OutlineInputBorder(),
                 hintText: "Book Name",
                 hintStyle: TextStyle(fontSize: 20),
                 contentPadding: EdgeInsets.only(top: 2),

               ),
             ),
           ),
           Container(
             margin: EdgeInsets.only(bottom: 10),
             child: TextField(
               controller: _Lid,
               style: TextStyle(fontSize: 20),
               decoration: InputDecoration(
                 labelText: "Library Id",
                 labelStyle: TextStyle(
                     fontSize: 12,
                     color: Colors.black
                 ),
                 border:OutlineInputBorder(),
                 hintText: "Book Id",
                 hintStyle: TextStyle(fontSize: 20),
                 contentPadding: EdgeInsets.only(top: 2),

               ),
             ),
           ),
           Container(
             margin: EdgeInsets.only(bottom: 10),
             child: TextField(
               controller: _auth,
               style: TextStyle(fontSize: 20),
               decoration: InputDecoration(
                 labelText: "Author",
                 labelStyle: TextStyle(
                     fontSize: 12,
                     color: Colors.black
                 ),
                 border:OutlineInputBorder(),
                 hintText: "Author Name",
                 hintStyle: TextStyle(fontSize: 20),
                 contentPadding: EdgeInsets.only(top: 2),

               ),
             ),
           ),
           Container(
             margin: EdgeInsets.only(bottom: 10),
             child: TextField(
               controller: _desc,
               style: TextStyle(fontSize: 20),
               decoration: InputDecoration(
                 labelText: "description",
                 labelStyle: TextStyle(
                     fontSize: 12,
                     color: Colors.black
                 ),
                 border:OutlineInputBorder(),
                 hintText: "Book Description",
                 hintStyle: TextStyle(fontSize: 20),
                 contentPadding: EdgeInsets.only(top: 2),

               ),
             ),
           ),
           Container(
             margin: EdgeInsets.only(bottom: 10),
             child: TextField(
               controller: _Qunti,
               style: TextStyle(fontSize: 20),
               decoration: InputDecoration(
                 labelText: "Quntity",
                 labelStyle: TextStyle(
                     fontSize: 12,
                     color: Colors.black
                 ),
                 border:OutlineInputBorder(),
                 hintText: "Quntity of Book",
                 hintStyle: TextStyle(fontSize: 20),
                 contentPadding: EdgeInsets.only(top: 2),

               ),
             ),
           ),
           Container(
             margin: EdgeInsets.only(bottom: 10),
             child: TextField(
               controller: _Avi,
               style: TextStyle(fontSize: 20),
               decoration: InputDecoration(
                 labelText: "Available",
                 labelStyle: TextStyle(
                     fontSize: 12,
                     color: Colors.black
                 ),
                 border:OutlineInputBorder(),
                 hintText: "Available Quntity",
                 hintStyle: TextStyle(fontSize: 20),
                 contentPadding: EdgeInsets.only(top: 2),

               ),
             ),
           ),
           if(_libraryImage != null && _Avi!=null && _Qunti!=null && _desc!=null && _name!=null && _auth!=null && _Lid!=null)
           Container(
             alignment: Alignment.centerLeft,
             width: MediaQuery.of(context).size.width,
             child: ElevatedButton(
               onPressed:_onsubmit,
               child: Text("ADD",style: TextStyle(fontSize: 20),),
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
   )
 );
  }
}
