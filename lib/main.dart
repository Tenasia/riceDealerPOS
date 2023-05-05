
import 'package:flutter/material.dart';
import 'package:rice_dealer_pos/pages/login_page.dart';
import 'package:rice_dealer_pos/views/main_view.dart';
import 'package:rice_dealer_pos/constants.dart';

void main(){
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rice Dealer POS',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
      ),
      home: LoginPage(),
    );
  }
}