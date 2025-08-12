import 'package:my_library/splash_serives.dart';
import 'package:flutter/material.dart';

class Splash_screen extends StatefulWidget {
  const Splash_screen({super.key});

  @override
  State<Splash_screen> createState() => _Splash_screenState();
}

class _Splash_screenState extends State<Splash_screen> {
  Splashserives Splash_screen=Splashserives();
  @override
  
  void initState() {
    super.initState();
    Splash_screen.isLogin(context);
  }
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('my_library'),
        ),
    );
  }
}