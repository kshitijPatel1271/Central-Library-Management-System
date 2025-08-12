import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:my_library/confirmpass.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:my_library/listbilds.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>{
  String Uid = "";
  String Name = "";
  late final TextEditingController _Name= TextEditingController();
  late final TextEditingController _contact= TextEditingController();
  late final TextEditingController _email= TextEditingController();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final String baseurl = "${dotenv.env['BASE_URL']}";
  String email = "";
  String path = "";
  String Phone = "";
  bool mode=false;
  File? _libraryImage;
  void _setImage(File? image) {
    setState(() {
      _libraryImage = image;
    });
  }
  void sate(){
    setState(() {
      mode=true;
    });
  }
  void Save() async{
    setState(() {
      mode=false;
    });
    final String? token = await secureStorage.read(key: "access_token");
    late final String _userProfilePicPath;
    if(_libraryImage != null){
      final userPicRequest = http.MultipartRequest('POST', Uri.parse("$baseurl/uploads/librarian-profile-pic"));
      userPicRequest.files.add(await http.MultipartFile.fromPath('file', _libraryImage!.path));
      userPicRequest.headers['Authorization'] = 'Bearer $token';
      final userPicResponse = await userPicRequest.send();
      final userPicResponseBody = await http.Response.fromStream(userPicResponse);
      if(userPicResponseBody.statusCode == 200){
        final decoded = json.decode(userPicResponseBody.body);
        _userProfilePicPath = decoded['profile_pic_url'] ?? "";
      } else {
        _userProfilePicPath = "";
      }
    } else {
      _userProfilePicPath = "";
    }
    final response = await http.post(
      Uri.parse("$baseurl/users/lbn-update"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'name': _Name.text.isNotEmpty ? _Name.text : null,
        'phonenumber': _contact.text.isNotEmpty ? _contact.text : null,
        'gmail': _email.text.isNotEmpty ? _email.text : null,
        'profile_pic': _userProfilePicPath.isNotEmpty ? _userProfilePicPath : null,
      }),
    );
    if (response.statusCode == 200) {
      //TODO:SUCCESS VS FAILURE
    }
  }
  @override
  void initState(){
    super.initState();
    _fetch();
  }
  void _fetch() async{
    final String? token = await secureStorage.read(key: "access_token");
    final String apiurl = "$baseurl/users/lbn-me";
    final response = await http.get(
        Uri.parse(apiurl),
        headers: {'Authorization': 'Bearer $token'}
    );
    if (response.statusCode == 200){
      final data = json.decode(response.body);
      setState(() {
        Uid = data['lbid'].toString();
        email = data['gmail'];
        Name = data['name'];
        Phone = data['phonenumber'];
        path = data['profile_pic'];
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile Page"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child:Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black12,
          child: Column(
            children: [
              if(!mode)
                Container(
                  height: 250,
                  child: CircleAvatar(
                    radius: 100,
                    backgroundImage: Image.network("$baseurl$path").image,
                  ),
                ),
              if(mode)
                Container(
                  margin: EdgeInsets.all(5),
                  height: 250,
                  child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)
                      ),
                      child: CustomImagePicker(onImageSelected: _setImage)),),
              Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: Text(Uid,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.grey)),
              ),
              if(!mode)
                Container(
                    width: MediaQuery.of(context).size.width*0.95,
                    margin: EdgeInsets.all(5),
                    child:Text("Name: ${Name}",
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
                      hintText: "user Name",
                      hintStyle: TextStyle(fontSize: 20),
                      contentPadding: EdgeInsets.only(top: 2),

                    ),
                  ),
                ),
              if(!mode)
                Container(
                    width: MediaQuery.of(context).size.width*0.95,
                    margin: EdgeInsets.all(5),
                    child:Text("Contact:  ${Phone}",
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
                    keyboardType: TextInputType.number,
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
                      labelText: "email",
                      labelStyle: TextStyle(
                          fontSize: 12,
                          color: Colors.black
                      ),
                      border:OutlineInputBorder(),
                      hintText: "✉ Email Address",
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
              Container(
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.only(left: 3),
                  child: ElevatedButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Confirmpass()));
                    },
                    child: Text("change password",style: TextStyle(fontSize: 20),),
                    style:ElevatedButton.styleFrom(

                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)
                        )
                    ) ,
                  ),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}