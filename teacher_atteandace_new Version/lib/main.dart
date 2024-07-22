import 'package:flutter/material.dart';
import 'package:teacher_attendenc/MyBottomNavigationBar.dart';
import 'package:teacher_attendenc/attendance_page.dart';
import 'package:teacher_attendenc/login_screen.dart';
import 'package:teacher_attendenc/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Move this property here
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: WelcomeScreen(),
    );
  }
}
