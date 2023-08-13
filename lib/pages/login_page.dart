import 'package:flutter/material.dart';
import 'package:rice_dealer_pos/api/database_helper.dart';
import 'package:rice_dealer_pos/views/main_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';


enum StateType {login, forgotCredentials}
class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  StateType _currentState = StateType.login;

  String _username = '';
  String _password = '';
  int loggedInUserId = 0;
  int loggedInRoleId = 0;

  bool _isLoading = false; // Flag to track the login process


  String recipient = 'example@example.com';
  String subject = 'Request New Password';
  String body = 'Hello, I wanted to share the following feedback with you: ...';


  void _login() async {

    setState(() {
      _isLoading = true; // Set the flag to indicate login process has started
    });

    try {
      List<dynamic> data = await DatabaseHelper.getUsers();

      bool isValid = false;

      for (var i = 0; i < data.length; i++) {
        // Hash the user inputted password using SHA-1 algorithm
        var bytes = utf8.encode(_password);
        var sha1Hash = sha1.convert(bytes).toString();
        if (data[i]['email'] == _username && data[i]['password'] == sha1Hash) {
          loggedInUserId = int.parse(data[i]['id']);
          loggedInRoleId = int.parse(data[i]['role_id']);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setInt('loggedInUserId', loggedInUserId);
          prefs.setInt('loggedInRoleId', loggedInRoleId);
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
            content: const Text('Invalid Login Credentials', style: TextStyle(color: Colors.white, fontSize: 20.0)),
            duration: const Duration(seconds: 2), // Set the duration for which the snackbar should be visible
          ),
        );
      }
    } catch (e) {
      // Handle any exceptions that may have occurred
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: recipient,
      queryParameters: {
        'subject': 'Your subject here',
        'body': 'Your message here',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Could not launch email client';
    }
  }



  @override
  Widget build(BuildContext context){
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          margin: const EdgeInsets.only(top: 150),
          child: (_currentState == StateType.forgotCredentials) ? Row(
            children: [
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Image.asset(
                    'assets/images/company_logo.png',
                    width: 400,
                    height: 400,
                  ),
                ),
              ),

              Expanded(
                flex:3,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      const Text(
                        'PHILIPS RICE DEALER',
                        style: TextStyle(fontSize: 42, color: Colors.red, fontFamily: 'PRD'),
                      ),
                      const Text(
                        'FORGOT PASSWORD',
                        style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: 500,
                        child: TextFormField(
                          style: const TextStyle(color: Colors.black, fontSize: 32.0),
                          decoration: InputDecoration(
                            labelText: ' Username',
                            labelStyle: const TextStyle(color: Colors.black, fontSize: 24.0),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue, width: 4.0),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 4.0),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red, width: 4.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100], // Set the desired background color here
                            contentPadding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 10.0),
                          ),
                          onChanged: (value) {
                            setState(() {
                              recipient = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _currentState = StateType.login;
                              });
                            },
                            child: const Text(
                              'Remembered Password?',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.underline,

                              ),
                            ),
                          ),

                        ],
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: 500,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(500, 50), // Set the desired width and height
                            backgroundColor: Colors.red[400], // Set the desired background color
                          ),
                          child: const Text(
                            'Send Email Confirmation',
                            style: TextStyle(fontSize: 32), // Increase the font size by 10 pixels
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ) : Row(
            children: [
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  child: Image.asset(
                    'assets/images/company_logo.png',
                    width: 400,
                    height: 400,
                  ),
                ),
              ),

              Expanded(
                flex:3,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      const Text(
                        'PHILIPS RICE DEALER',
                        style: TextStyle(fontSize: 42, color: Colors.red, fontFamily: 'PRD'),
                      ),
                      const Text(
                        'POS LOGIN',
                        style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: 500,
                        child: TextFormField(
                          style: const TextStyle(color: Colors.black, fontSize: 32.0),
                          decoration: InputDecoration(
                            labelText: ' Username',
                            labelStyle: const TextStyle(color: Colors.black, fontSize: 24.0),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue, width: 4.0),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 4.0),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red, width: 4.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100], // Set the desired background color here
                            contentPadding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 10.0),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _username = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: 500,
                        child: TextFormField(
                          style: const TextStyle(color: Colors.black, fontSize: 32.0), // Set the desired font color here
                          decoration: InputDecoration(
                            labelText: ' Password',
                            labelStyle: const TextStyle(color: Colors.black, fontSize: 24.0),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue, width: 4.0),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey, width: 4.0),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red, width: 4.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100], // Set the desired background color here
                            contentPadding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 10.0),
                          ),
                          obscureText: true, // Hide the entered text
                          onChanged: (value) {
                            setState(() {
                              _password = value;
                            });
                          },
                        ),
                      ),


                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _currentState = StateType.forgotCredentials;
                              });
                            },
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.underline,

                              ),
                            ),
                          ),

                        ],
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: 500,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(500, 50),
                            backgroundColor: _isLoading ? Colors.black : Colors.red[400],
                          ),
                          onPressed: _isLoading ? null : _login,
                          child: _isLoading
                              ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Set the color to red
                          )
                              : const Text(
                            'Login',
                            style: TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                    ],
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