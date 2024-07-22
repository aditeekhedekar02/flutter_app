import 'package:flutter/material.dart';

class Thankyou extends StatefulWidget {
  const Thankyou({Key? key}) : super(key: key);

  @override
  State<Thankyou> createState() => _ThankyouState();
}

class _ThankyouState extends State<Thankyou> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thank You'),
        backgroundColor: Colors.blue, // Set the AppBar color to blue
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Thank you for submitting!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate back to the previous screen
                Navigator.pop(context);
              },
              child: Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
