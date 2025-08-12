import 'package:flutter/material.dart';
import 'package:my_library/loginpage.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'listbilds.dart';
import 'package:my_library/homepage.dart';
import 'package:my_library/librarian/home_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final baseurl = "${dotenv.env['BASE_URL']}";
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  final OTP = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final TextEditingController _Name= TextEditingController();
  final TextEditingController _address= TextEditingController();
  final TextEditingController _userName= TextEditingController();
  File? _libraryImage;
  String _password='';
  String _confirmPassword='';
  String _phone='';
  String _email='';
  String _libname="";
  String _add="";
  String username ="";
  String _selectedOption = 'User';
  bool _rememberMe = false;
  bool otpcheck=false;
  late final response;
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }

    setState(() {
      otpcheck = true;
    });

    final response = await http.post(
      Uri.parse("$baseurl/auth/ver-email"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({"email": _email}),
    );

    if (response.statusCode == 200) {
      // TODO: success snackbar maybe?
    }
  }

  void OTPCHECK() async{
    if(_Name.text.length>0){
      _libname=_Name.text;
    }
    if(_userName.text.length>0){
      username=_userName.text;
    }
    if(_address.text.length>0){
      _add=_address.text;
    }
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processing Data')),
      );
      final response_otp = await http.post(
        Uri.parse("$baseurl/auth/ver-email-otp"),
        headers:{
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "email":_email,
          "otp":OTP.text
        }),
      );
      if(response_otp.statusCode == 200){
        if (_selectedOption == 'user') {
          response = await http.post(
            Uri.parse('$baseurl/register'),
            headers: {
              'Content-Type': 'application/json',
              "accept": "application/json",
            },
            body: json.encode({
              'gmail': _email,
              'phonenumber': _phone,
              'name': _userName.text,
              'password': _password,
              'role': _selectedOption,
              'remember_me': _rememberMe,
            }),
          );
        } else {
          late final String _userProfilePicPath;
          final userPicRequest = http.MultipartRequest('POST', Uri.parse("$baseurl/uploads/library-image"));
          userPicRequest.files.add(await http.MultipartFile.fromPath('file', _libraryImage!.path));
          final userPicResponse = await userPicRequest.send();
          final userPicResponseBody = await http.Response.fromStream(userPicResponse);

          if (userPicResponse.statusCode == 200) {
            final decoded = json.decode(userPicResponseBody.body);
            _userProfilePicPath = decoded['image_path'];
            print({'gmail': _email,
                'phonenumber': _phone,
                'name': _userName.text,
                'password': _password,
                'role': _selectedOption,
                'remember_me': _rememberMe,
                'library_name': _libname,
                'library_address': _add,
                'library_image': _userProfilePicPath});
            response = await http.post(
              Uri.parse('$baseurl/auth/register-librarian'),
              headers: {
                'Content-Type': 'application/json',
                "accept": "application/json",
              },
              body: json.encode({
                'gmail': _email,
                'phonenumber': _phone,
                'name': _userName.text,
                'password': _password,
                'role': _selectedOption,
                'remember_me': _rememberMe,
                'lib_name': _libname,
                'lib_add': _add,
                'lib_img': _userProfilePicPath
              }),
            );
          } else {
            _showError("Failed to upload profile picture");
            return;
          }
        }
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data is Map<String, dynamic> &&
              data.containsKey("access_token")) {
            final accessToken = data['access_token'].toString();
            final refreshToken = data['refresh_token'].toString();
            await secureStorage.write(key: "access_token", value: accessToken);
            await secureStorage.write(
                key: "refresh_token", value: refreshToken);
            await secureStorage.write(
                key: "remember_me", value: _rememberMe.toString());
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) {
                if (_selectedOption == 'user') {
                  return (HomePage());
                } else {
                  return (Homepage());
                }
              }),
            );
          }
        } else {
          final detail = jsonDecode(response.body)['detail'];
          String errorMessage;
          if (detail is String) {
            errorMessage = detail;
          } else if (detail is List) {
            // Convert list of errors to single string
            errorMessage = detail.map((e) => e['msg']).join(', ');
          } else {
            errorMessage = "Unknown error";
          }
          _showError(errorMessage);
        }
      }else {
        final error = jsonDecode(response_otp.body)['detail'];
        _showError(error);
        return;
      }

    }
  }
  void _showError(String msg){
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Registration Failed"),
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
  void _setImage(File? image) {
    setState(() {
      _libraryImage = image;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        heightFactor: 20,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [

                      Text(
                        'SIGN UP',
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        title: Text('User'),
                        leading: Radio(
                          value: 'User',
                          groupValue: _selectedOption,
                          onChanged: (value) {
                            setState(() {
                              _selectedOption = value!;
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: Text("Libraian"),
                        leading: Radio(
                          value: 'librarian',
                          groupValue: _selectedOption,
                          onChanged: (value) {
                            setState(() {
                              _selectedOption = value!;
                            });
                          },
                        ),
                      ),
                      if(_selectedOption=='librarian')
                        Container(
                          margin: EdgeInsets.all(5),
                          height: 250,
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black)
                              ),
                              child: CustomImagePicker(onImageSelected: _setImage)),),
                      Container(
                        margin: EdgeInsets.all(5),
                        child: TextField(
                          controller: _userName,
                          style: TextStyle(fontSize: 20),
                          decoration: InputDecoration(
                            labelText: "User Name",
                            labelStyle: TextStyle(
                                fontSize: 12,
                                color: Colors.black
                            ),
                            border:OutlineInputBorder(),
                            hintText: "User Name",
                            hintStyle: TextStyle(fontSize: 20),
                            contentPadding: EdgeInsets.only(top: 2),

                          ),
                        ),
                      ),
                      if(_selectedOption=='librarian')
                        Container(
                          margin: EdgeInsets.all(5),
                          child: TextField(
                            controller: _Name,
                            style: TextStyle(fontSize: 20),
                            decoration: InputDecoration(
                              labelText: "Library Name",
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

                      if(_selectedOption=='librarian')
                        Container(
                          margin: EdgeInsets.all(5),
                          child: TextField(
                            controller: _address,
                            style: TextStyle(fontSize: 20),
                            decoration: InputDecoration(
                              labelText: "Library Address",
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
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Phone No',
                          hintText: 'Phone No',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty ) {
                            return 'Please enter your phone No';
                          }
                          if(value.length<10)
                          {
                            return 'Please enter valid phone No';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _phone = value.toString();
                        },
                      ),

                      SizedBox(height: 10),

                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _email = value.toString();
                        },
                      ),
                      SizedBox(height: 10),

                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _password = value.toString();
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'confirm password',
                          hintText: 'confirm password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if(_passwordController.text!=_confirmPasswordController.text)
                          {
                            return 'Password does not match';
                          }
                          if (value.length < 6)
                          {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;

                        },
                        onSaved: (value) {
                          _confirmPassword = value.toString();
                        },
                      ),

                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value!;
                              });
                            },
                          ),
                          const Text("Remember Me"),
                        ],
                      ),
                      const  SizedBox(height: 10,),
                      if(!otpcheck)
                        ElevatedButton(
                          onPressed:_submit,
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text('OTP Verfication'),

                        ),
                      if(otpcheck)
                        Container(
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(5),
                          child: TextField(
                            maxLength: 6,
                            controller: OTP,
                            style: TextStyle(fontSize: 20),
                            decoration: InputDecoration(
                              labelText: "OTP",
                              labelStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black
                              ),
                              border:OutlineInputBorder(),
                              hintText: "______",
                              hintStyle: TextStyle(fontSize: 20),
                              contentPadding: EdgeInsets.only(top: 2),

                            ),
                          ),
                        ),
                      if(otpcheck)
                        TextButton(
                          onPressed: (){},
                          child: const Text('Resend OTP'),
                        ),
                      if(otpcheck)
                        ElevatedButton(
                          onPressed:OTPCHECK,
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text('Sign Up'),

                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account ?'),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage()),
                              );
                            },
                            child: Text('Login'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}