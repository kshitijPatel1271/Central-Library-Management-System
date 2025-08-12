import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_library/listbilds.dart';
import 'package:my_library/lib.dart';
import 'package:http/http.dart' as http;
class Libeditpage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _Libeditpage();
  }
}//TODO: END POINT TO EDIT LIB
class _Libeditpage extends State<Libeditpage>{
  final String baseurl = "${dotenv.env['BASE_URL']}";
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final TextEditingController _Name= TextEditingController();
  final TextEditingController _address= TextEditingController();
  final TextEditingController _contact= TextEditingController();
  final TextEditingController _email= TextEditingController();
  String email="PH***@gmail.com";
  late Library lib;
  File? _libraryImage;
  bool mode=false;
  @override
  void initState(){
    super.initState();
    _fetch();
  }
  void _fetch() async{
    final String? token = await secureStorage.read(key: "access_token");
    final response = await http.get(Uri.parse("$baseurl/libraries/fetch"),headers: {'Authorization': 'Bearer $token'});
    if(response.statusCode == 200){
      lib = json.decode(response.body);
    }//TODO: ELSE PART OF ERROR
  }
  void sate(){
    setState(() async{
      mode=true;
      String? imagePath;
      if (_libraryImage != null) {
        final uploadRequest = http.MultipartRequest(
          'POST',
          Uri.parse('$baseurl/upload-image'),
        );
        uploadRequest.headers['Authorization'] = 'Bearer ${await secureStorage.read(key: 'access_token')}';
        uploadRequest.files.add(
          await http.MultipartFile.fromPath('file', _libraryImage!.path),
        );

        final streamedResponse = await uploadRequest.send();
        final res = await http.Response.fromStream(streamedResponse);

        if (res.statusCode == 200) {
          final responseData = json.decode(res.body);
          imagePath = responseData['file_path'];
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Image upload failed")),
          );
          return;
        }
      }
      final String apiurl = "$baseurl/libraries/lib-edit";
      final response = await http.post(
        Uri.parse(apiurl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${await secureStorage.read(key: 'access_token')}'
        },
        body: json.encode({
          'name': _Name.toString(),
          'add': _address.toString(),
          'lib_pic': imagePath ?? lib.picturePath,
          'phone': _contact.toString(),
          'penalty': _email.toString(),//TODO: CHANGE EMAIL TO PENALTY WITH TYPE OF FLOAT
        }),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Library updated successfully')),
        );
      }//TODO: ELSE PART OF ERROR
    });
  }
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter phone number';
    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }
  void Save(){
    setState(() {
      mode=false;
      if(_Name.text.length>0){
        lib.name=_Name.text;
      }
      if(_address.text.length>0){
        lib.address=_address.text;
      }
      if(_contact.text.length>0){
        lib.contact=_contact.text;
      }
      if(_email.text.length>0) {
        email = _email.text;
      }
      if(_libraryImage!=null){
        lib.picturePath=_libraryImage!.path;
      }
    });
  }
  void _setImage(File? image) {
    setState(() {
      _libraryImage = image;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Library"),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width*1,
        height: MediaQuery.of(context).size.height*1,
        color: Colors.black12,
        child: SingleChildScrollView(
          child: Column(
            children: [
              if(!mode)
                Container(
                  margin: EdgeInsets.all(5),
                  height: 250,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black)
                    ),
                      child: Image.asset(lib.picturePath,fit: BoxFit.cover,)),),
              if(mode)
                Container(
                  margin: EdgeInsets.all(5),
                  height: 250,
                  child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)
                      ),
                      child: CustomImagePicker(onImageSelected: _setImage)),),
              if(mode)
                Text("* please enter only that data which you want to change",style: TextStyle(fontSize: 13),),
              if(!mode)
                Container(
                  width: MediaQuery.of(context).size.width*0.95,
                  margin: EdgeInsets.all(5),
                  child:Text("Name: ${lib.name}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ),
              if(mode)
                Container(
                  child: TextField(
                    controller: _Name,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      labelText: "Name",
                      labelStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.black
                      ),
                      border:OutlineInputBorder(),
                      hintText: "Library Name",
                      hintStyle: TextStyle(fontSize: 20),
                      contentPadding: EdgeInsets.only(top: 2),

                    ),
                  ),
                ),
              if(!mode)
                Container(
                    width: MediaQuery.of(context).size.width*0.95,
                    margin: EdgeInsets.all(5),
                    child:Text("Address: : ${lib.address}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                ),
              if(mode)
                Container(
                  child: TextField(
                    controller: _address,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      labelText: "Address",
                      labelStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.black
                      ),
                      border:OutlineInputBorder(),
                      hintText: "Library Address",
                      hintStyle: TextStyle(fontSize: 20),
                      contentPadding: EdgeInsets.only(top: 2),

                    ),
                  ),
                ),

              if(!mode)
                Container(
                    width: MediaQuery.of(context).size.width*0.95,
                    margin: EdgeInsets.all(5),
                    child:Text("Contact:  ${lib.contact}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                ),
              if(mode)
                Container(
                  child: TextFormField(
                    controller: _contact,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      labelText: "Contact",
                      labelStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.black
                      ),
                      border:OutlineInputBorder(),
                      hintText: "+91 XXXXX XXXXX",
                      hintStyle: TextStyle(fontSize: 20),
                      contentPadding: EdgeInsets.only(top: 2),

                    ),
                    keyboardType: TextInputType.phone,
                    validator: _validatePhoneNumber,
                  ),
                ),
              if(!mode)
                Container(
                    width: MediaQuery.of(context).size.width*0.95,
                    margin: EdgeInsets.all(5),
                    child:Text("Email Address: : ${email}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                ),
              if(mode)
                Container(
                  child: TextField(
                    controller: _email,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                      labelText: "Panalty rate",
                      labelStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.black
                      ),
                      border:OutlineInputBorder(),
                      hintText: "Enter penalty rate as per day",
                      hintStyle: TextStyle(fontSize: 20),
                      contentPadding: EdgeInsets.only(top: 2),

                    ),
                  ),
                ),
              if(!mode)
                Container(
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width*0.95,
                  padding: EdgeInsets.only(left: 3),
                  child: ElevatedButton(
                    onPressed: sate ,
                    child: Text("Edit",style: TextStyle(fontSize: 20),),
                    style:ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                        )
                    ) ,
                  ),
                ),
              if(mode)
                Container(
                  alignment: Alignment.centerLeft,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(left: 3),
                  child: ElevatedButton(
                    onPressed: Save ,
                    child: Text("Save",style: TextStyle(fontSize: 20),),
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
      ),
    );
  }

}