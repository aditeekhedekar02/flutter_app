
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:teacher_attendenc/MyBottomNavigationBar.dart';
import 'package:teacher_attendenc/attendance_page.dart';
import 'package:teacher_attendenc/histroy.dart';
import 'package:teacher_attendenc/remark.dart';

class AttendanceTracker extends StatefulWidget {
  @override
  _AttendanceTrackerState createState() => _AttendanceTrackerState();
}

class _AttendanceTrackerState extends State<AttendanceTracker> {
  final List<DateTime> _dates = [];
  final List<String> _status = [];
  final List<String> _locations = [];
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  int _calendarRange = 30; // Range of dates to show in the calendar

  @override
  void initState() {
    super.initState();
    _initDates();
  }

  void _initDates() {
    DateTime now = DateTime.now();
    _dates.clear();
    for (int i = 0; i < _calendarRange; i++) {
      DateTime date = now.subtract(Duration(days: i));
      DateTime dateTimeWithTime =
          DateTime(date.year, date.month, date.day, date.hour, date.minute);
      _dates.add(dateTimeWithTime);
      // Mark Sundays, Wednesdays, and Fridays as absent
      if (date.weekday == DateTime.sunday ||
          date.weekday == DateTime.wednesday ||
          date.weekday == DateTime.friday) {
        _status.add('Absent');
      } else {
        _status.add('Present');
      }
      _locations.add('Office'); // Default location
    }
    _dates.sort((a, b) => b.compareTo(a));
  }

  void _selectDate(DateTime date) {
    if (!_dates.contains(date)) {
      _dates.add(date);
      _status.add('Present'); // Default status for new dates
      _locations.add('Office'); // Default location for new dates
    }
    setState(() {
      _selectedDate = date;
    });
  }

  void _updateStatus(String newStatus, int index) {
    setState(() {
      _status[index] = newStatus;
    });
  }

  void _updateLocation(String newLocation, int index) {
    setState(() {
      _locations[index] = newLocation;
    });
  }

  int _countPresentDays() {
    return _status.where((status) => status == 'Present').length;
  }

  void _showMoreDates() {
    setState(() {
      _calendarRange += 30; // Extend the range by another 30 days
      _initDates(); // Reinitialize dates with the new range
    });
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
      leading: IconButton(
        icon: Icon(Icons.home),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BottomNavigationBarExample()),
          );
        },
      ),
      automaticallyImplyLeading: false,
      title: Text("Attendance History"),
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

      body: SingleChildScrollView(
        child: Column(
          children: [
            // Summary view at the top
            Padding(
              padding: const EdgeInsets.all(8.0),
              // child: Text(
              //   'Total Present Days: ${_countPresentDays()}',
              //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              // ),
            ),
            // Calendar view with border
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight:
                      400, // Adjust this value to minimize the calendar size
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2.0),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: TableCalendar(
                  firstDay:
                      DateTime.now().subtract(Duration(days: _calendarRange)),
                  lastDay: DateTime.now(),
                  focusedDay: _focusedDate,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDate, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDate = selectedDay;
                      _focusedDate =
                          focusedDay; // update `_focusedDay` here as well
                    });
                  },
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      for (int i = 0; i < _dates.length; i++) {
                        if (isSameDay(day, _dates[i])) {
                          Color dayColor = _status[i] == 'Present'
                              ? Color.fromARGB(255, 137, 228, 246)
                              : Color.fromARGB(255, 137, 228, 246);
                          return Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dayColor.withOpacity(0.5),
                            ),
                            margin: const EdgeInsets.all(6.0),
                            alignment: Alignment.center,
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                color: Colors.black, // Make the date number black
                              ),
                            ),
                          );
                        }
                      }
                      return null;
                    },
                    selectedBuilder: (context, date, events) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue, // Customize hover color here
                        ),
                        margin: const EdgeInsets.all(6.0),
                        alignment: Alignment.center,
                        child: Text(
                          '${date.day}',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Status display
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _dates.length,
              itemBuilder: (context, index) {
                return _dates[index].isSameDate(_selectedDate)
                    ? _buildAttendanceRow(index)
                    : Container();
              },
            ),
           // Button to show more dates
            Padding(
              padding: const EdgeInsets.all(8.0),
                // child: ElevatedButton(
                //   onPressed: _showMoreDates,
                //   child: Text('Show More Dates'),
                // ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRow(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side (Date/Time and Location)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${_dates[index].day}/${_dates[index].month}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          // child: Text(
                          //   '${_dates[index].hour}:${_dates[index].minute}',
                          //   style: TextStyle(fontWeight: FontWeight.bold),
                          // ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Location: ${_locations[index]}'),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              // Right side (Status and Edit Icon)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    // child: Text(
                    //   _status[index],
                    //   style: TextStyle(
                    //       color: _status[index] == 'Present'
                    //           ? Color.fromARGB(255, 74, 77, 74)
                    //           : Color.fromARGB(255, 78, 77, 77)),
                    // ),
                  ),
                  SizedBox(height: 8),
                  IconButton(
                    icon: Icon(Icons.remove_red_eye),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceHistoryPage(
                            selectedDate: _dates[index],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension DateTimeExtension on DateTime {
  bool isSameDate(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }
}
