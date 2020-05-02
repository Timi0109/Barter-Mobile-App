import 'package:final_project/detail_screen.dart';
import 'package:final_project/image_full_screen.dart';
import 'package:final_project/menu_screen.dart';
import 'package:final_project/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:final_project/new_post_screen.dart';
import 'package:final_project/login_screen.dart';
import 'package:final_project/registration_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        MenuScreen.id: (context) => MenuScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        DetailScreen.id: (context) => DetailScreen(),
        PostScreen.id: (context) => PostScreen(),
        FullImgScreen.id: (context) => FullImgScreen(),
      },
    );
  }
}
