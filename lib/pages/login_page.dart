import 'package:flutter/material.dart';
import 'package:rice_dealer_pos/api/database_helper.dart';
import 'package:rice_dealer_pos/views/main_view.dart';

class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{

  String _username = '';
  String _password = '';

  void _login() async {
    try {
      List<dynamic> data = await DatabaseHelper.getUsers();
      bool isValid = false;
      for (var i = 0; i < data.length; i++) {
        if (data[i]['username'] == _username && data[i]['password'] == _password) {
          isValid = true;
          break;
        }
      }
      if (isValid) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainView()),
        );
      } else {
        print('error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[400],
            content: Text('Invalid Login Credentials', style: TextStyle(color: Colors.white, fontSize: 20.0)),
            duration: Duration(seconds: 2), // Set the duration for which the snackbar should be visible
          ),
        );
      }
    } catch (e) {
      // Handle any exceptions that may have occurred
      print(e);
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Container(
        margin: EdgeInsets.only(top: 60),
        child: Center(
          child: Column(children: [

            const SizedBox(height: 50),

            // Logo
            Icon(
              Icons.lock,
              size: 100,
            ),

            const SizedBox(height: 50),

            // Welcome Back, You've been missed!
            Text(
              'Rice Dealer POS',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),

            // Username textfield
            SizedBox(
              width: 500,
              child: TextFormField(
                style: TextStyle(color: Colors.black, fontSize: 24.0),
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.black, fontSize: 20.0),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 4.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 4.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 4.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100], // Set the desired background color here
                  contentPadding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 10.0),
                ),
                onChanged: (value) {
                  setState(() {
                    _username = value;
                  });
                },
              ),
            ),





            const SizedBox(height: 25),
            // Password textfield
            SizedBox(
              width: 500,
              child: TextFormField(
                style: TextStyle(color: Colors.black, fontSize: 24.0), // Set the desired font color here
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.black, fontSize: 20.0),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 4.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 4.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 4.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100], // Set the desired background color here
                  contentPadding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 10.0),
                ),
                obscureText: true, // Hide the entered text
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
              ),
            ),



            const SizedBox(height: 10),
            // forgot password?
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Forgot password?',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // sign in button
            SizedBox(
              width: 500,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(500, 50), // Set the desired width and height
                  backgroundColor: Colors.red[400], // Set the desired background color
                ),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 20), // Increase the font size by 10 pixels
                ),
                onPressed: _login,
              ),
            ),


            const SizedBox(height: 50),

            // or continue with

            // google + apple sign in buttons
          ]),
        ),
      ),
    );
  }
}