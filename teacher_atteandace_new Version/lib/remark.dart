import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:teacher_attendenc/MyBottomNavigationBar.dart'; // Make sure the import path is correct
import 'dart:convert';
import 'package:http/http.dart' as http;

class AttendanceHistoryPage extends StatefulWidget {
  final DateTime selectedDate;

  AttendanceHistoryPage({required this.selectedDate});

  @override
  _AttendanceHistoryPageState createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  String currentLocation = "Fetching location...";
  LatLng? _currentLatLng;
  List<dynamic> _attendanceHistory = []; // Initialize as empty list

  final TextStyle _textStyle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w400,
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchAttendanceHistory(); // Fetch attendance history when the page is initialized
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

  Future<void> _fetchAttendanceHistory() async {
    final url = 'https://project1.myospaz.in/aditee/fetch_attendance1.php';

    final client = http.Client();
    final request = http.Request('POST', Uri.parse(url))
      ..headers[HttpHeaders.contentTypeHeader] = 'application/json'
      ..body = jsonEncode({
        'selectedDate':
            '${widget.selectedDate.toLocal().toIso8601String().split('T')[0]}',
      });

    try {
      final response = await client.send(request);
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        setState(() {
          _attendanceHistory = jsonDecode(responseBody);
        });
      } else {
        throw Exception('Failed to load attendance history');
      }
    } catch (e) {
      print('Error fetching attendance history: $e');
    } finally {
      client.close();
    }
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
            leading: IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BottomNavigationBarExample()),
                );
              },
            ),
            automaticallyImplyLeading: false,
            title: Text("Attendance Information"),
            centerTitle: true,
            backgroundColor: Color.fromARGB(255, 65, 172, 194),
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
                Text(
                  'Selected Date: ${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}',
                  style: _textStyle,
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
                SizedBox(height: 16.0),
                _currentLatLng == null
                    ? Center(child: CircularProgressIndicator())
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        height: 300,
                        child: GoogleMap(
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
                            controller.animateCamera(
                              CameraUpdate.newLatLng(_currentLatLng!),
                            );
                          },
                        ),
                      ),
                SizedBox(height: 10.0),
                Divider(),
                SizedBox(height: 16.0),
                _buildAttendanceHistory(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceHistory() {
    if (_attendanceHistory.isEmpty) {
      return Text('No attendance records found for the selected date.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _attendanceHistory.map((record) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                record['date'],
                style: _textStyle,
              ),
              Text(
                record['is_active'],
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                  color: record['is_active'] == 'Present'
                      ? Colors.green
                      : record['is_active'] == 'Absent'
                          ? Colors.red
                          : Colors.orange,
                ),
              ),
              Text(
                record['remark'] ?? 'No remarks',
                style: _textStyle,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
