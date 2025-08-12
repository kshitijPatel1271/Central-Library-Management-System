import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_library/loginpage.dart';

class Splashserives{

  void isLogin(BuildContext context){
    
    Timer(Duration(seconds:3), () => Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginPage())));

  }

}
