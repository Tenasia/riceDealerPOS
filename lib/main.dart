import 'package:flutter/material.dart';
import 'package:rice_dealer_pos/pages/login_page.dart';
import 'package:rice_dealer_pos/constants.dart';
// Is this really working? Let's see.
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
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
