import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:teacher_attendenc/MyBottomNavigationBar.dart';
import 'package:teacher_attendenc/attendance_page.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  Future<void> login() async {
    try {
      var url = Uri.parse(
          "https://project1.myospaz.in/aditee/login.php"); // Change to your server address
      var response = await http.post(url, body: {
        "username": _usernameController.text,
        "password": _passwordController.text,
      });

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      var data = json.decode(response.body);
      if (data == "Success") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BottomNavigationBarExample()),
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Invalid Username or Password',
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } catch (e, stackTrace) {
      print('Login failed: $e');
      print('Stack trace: $stackTrace');

      // Fluttertoast.showToast(
      //   msg: 'An error occurred. Please try again later.',
      //   backgroundColor: Colors.red,
      //   textColor: Colors.white,
      //   toastLength: Toast.LENGTH_SHORT,
      // );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_bk.avif'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset(
                  'assets/images/login_icon.svg', // Ensure the SVG file exists in your assets
                  height: 100,
                ),
                SizedBox(height: 30.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person),
                      suffixIcon: Icon(Icons.account_circle),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    obscureText: !_isPasswordVisible,
                  ),
                ),
                SizedBox(height: 15.0),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.0),
                  child: Row(
                    children: <Widget>[
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (bool? value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                      ),
                      Text(
                        'Remember Me',
                        style: TextStyle(
                          color: Color.fromARGB(255, 1, 101, 119),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: () {
                          print('Forgot Password');
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Color.fromARGB(255, 1, 101, 119),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.0),
                ElevatedButton(
                  onPressed: login,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Color.fromARGB(255, 1, 101, 119),
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
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


