import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teacher_attendenc/attendance_histroy.dart';
import 'package:teacher_attendenc/histroy.dart';

enum Status {
  present,
  late,
  halfDay,
  absent,
  onSite,
  OnVisit,
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String currentLocation = "Fetching location...";
  Status _status = Status.onSite; // Initial status set to active
  TextEditingController _remarkController = TextEditingController();

  GoogleMapController? _mapController;
  LatLng? _currentLatLng;

  final TextStyle _textStyle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w400,
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        currentLocation = "Location services are disabled.";
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          currentLocation = "Location permissions are denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        currentLocation = "Location permissions are permanently denied.";
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    _getAddressFromLatLng(position);

    setState(() {
      _currentLatLng = LatLng(position.latitude, position.longitude);
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(_currentLatLng!),
        );
      }
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];

      setState(() {
        currentLocation = "${place.name}, ${place.locality}, ${place.country}";
      });
    } catch (e) {
      setState(() {
        currentLocation = "Unable to get location.";
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _handleStatusChange(Status? newStatus) {
    setState(() {
      if (newStatus != null) {
        _status = newStatus;
      }
    });
  }

  Future<String?> _getEmployeeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('employee_id');
  }

  void _handleSubmit() async {
    if (_remarkController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter remarks before submitting.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    String? employeeId = await _getEmployeeId();
    if (employeeId == null) {
      Fluttertoast.showToast(
        msg: "Employee ID not found. Please log in again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    String statusText;
    switch (_status) {
      case Status.present:
        statusText = 'Present';
        break;
      case Status.late:
        statusText = 'Late';
        break;
      case Status.halfDay:
        statusText = 'Half Day';
        break;
      case Status.OnVisit:
        statusText = 'On Visit';
        break;
      case Status.absent:
        statusText = 'Absent';
        break;
      case Status.onSite:
        statusText = 'On Site';
        break;
    }

    Map<String, dynamic> data = {
      'employee_id': employeeId.toString(), // Add employee_id to the data map
      'selectedDate': DateFormat('yyyy-MM-dd').format(selectedDate),
      'selectedTime': selectedTime.format(context),
      'currentLocation': currentLocation,
      'status': statusText,
      'remarks': _remarkController.text,
    };

    String apiUrl = 'https://project1.myospaz.in/aditee/submit_attendance1.php';

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        body: jsonEncode(data),
        headers: {"Content-Type": "application/json"},
      );

      var responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData["message"] == "Attendance submitted successfully!") {
          Fluttertoast.showToast(
            msg: "Attendance submitted successfully!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AttendanceTracker(),
            ),
          );
        } else if (responseData["message"] ==
            "Attendance already submitted for this date.") {
          Fluttertoast.showToast(
            msg: "Attendance already submitted for this date.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        } else {
          Fluttertoast.showToast(
            msg: "Failed to submit attendance. Please try again.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Failed to submit attendance. Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg:
            "Failed to connect to the server. Please check your internet connection.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
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
            title: Text('Mark Attendance'),
            backgroundColor: Color.fromARGB(255, 48, 198, 232),
            actions: [
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: _showLogoutDialog,
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                      style: _textStyle,
                    ),
                    Text(
                      "Time: ${selectedTime.format(context)}",
                      style: _textStyle,
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 300,
                  child: _currentLatLng == null
                      ? Center(child: CircularProgressIndicator())
                      : GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _currentLatLng!,
                            zoom: 14.0,
                          ),
                          markers: _currentLatLng != null
                              ? {
                                  Marker(
                                    markerId: MarkerId('currentLocation'),
                                    position: _currentLatLng!,
                                  ),
                                }
                              : {},
                          onMapCreated: (GoogleMapController controller) {
                            _mapController = controller;
                          },
                          gestureRecognizers: Set()
                            ..add(Factory<PanGestureRecognizer>(
                                () => PanGestureRecognizer()))
                            ..add(Factory<ScaleGestureRecognizer>(
                                () => ScaleGestureRecognizer()))
                            ..add(Factory<TapGestureRecognizer>(
                                () => TapGestureRecognizer()))
                            ..add(Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer())),
                        ),
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Current Location:",
                      style: _textStyle,
                    ),
                    Expanded(
                      child: Text(
                        "$currentLocation",
                        style: _textStyle,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text("Status:", style: _textStyle),
                    Container(
                      width: 150,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Status>(
                          value: _status,
                          items: [
                            DropdownMenuItem(
                              value: Status.present,
                              child: Text('Present', style: _textStyle),
                            ),
                            DropdownMenuItem(
                              value: Status.late,
                              child: Text('Late', style: _textStyle),
                            ),
                            DropdownMenuItem(
                              value: Status.halfDay,
                              child: Text('Half Day', style: _textStyle),
                            ),
                            DropdownMenuItem(
                              value: Status.OnVisit,
                              child: Text('On Visit', style: _textStyle),
                            ),
                            DropdownMenuItem(
                              value: Status.absent,
                              child: Text('Absent', style: _textStyle),
                            ),
                            DropdownMenuItem(
                              value: Status.onSite,
                              child: Text('On Site', style: _textStyle),
                            ),
                          ],
                          onChanged: _handleStatusChange,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Remarks:',
                        style: _textStyle,
                      ),
                      SizedBox(height: 8.0),
                      TextField(
                        controller: _remarkController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter any remarks here',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 0, 151, 178),
                  ),
                  onPressed: _handleSubmit,
                  child: Text(
                    'Submit',
                    style: _textStyle.copyWith(color: Colors.white),
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
