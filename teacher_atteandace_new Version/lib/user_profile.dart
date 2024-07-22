import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_attendenc/login_screen.dart';
import 'dart:convert';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfile> {
  String _username = '';
  Map<String, dynamic>? _profileData;
  String imagePath =
      'E:/Flutter Project/teacher_attendance/teacher_attendance-main/teacher_atteandace_new Version/assets/images/Profile_Image.jpeg';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? '';
    });
    _fetchUserProfile();
  }

  ///
  Future<void> _saveUserId(String employee_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('employee_id', employee_id);
  }

  Future<void> _fetchUserProfile() async {
    var url = Uri.parse(
        "https://project1.myospaz.in/aditee/Profile2.php"); // Change to your server address
    var response = await http.post(url, body: {
      "Username": _username,
    });

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['error'] != null) {
        print('Error: ${data['error']}');
      } else {
        setState(() {
          _profileData = data;
        });
        await _saveUserId(data['employee_id']);
      }
    } else {
      print('Failed to load profile: ${response.statusCode}');
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                    color:
                        Colors.black), // Set Cancel button text color to black
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.black), // OK button text color
              ),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('username');
                await prefs.remove('employee_id');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20.0),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            title: Text("Profile"),
            centerTitle: true,
            backgroundColor: Color.fromARGB(255, 65, 172, 194),
            actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _showLogoutDialog,
          ),
        ],
          ),
        ),
     ),
      body: _profileData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40), // Add space from the top
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: _profileData!['ImagePath'] != null
                        ? NetworkImage(_profileData!['ImagePath'])
                        : AssetImage('assets/images/Profile_Image.jpeg')
                            as ImageProvider,
                  ),
                  SizedBox(height: 20),
                  Text(
                    _profileData!['name'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text(_profileData!['email']),
                      subtitle: Text('email'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.email),
                      title: Text(_profileData!['contact_no']),
                      subtitle: Text('contact_no'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.phone),
                      title: Text(_profileData!['local_address']),
                      subtitle: Text('local_address'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text(_profileData!['permanent_address']),
                      subtitle: Text('permanent_address'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.info),
                      title: Text(_profileData!['is_active'].toString()),
                      subtitle: Text('is_active'),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
