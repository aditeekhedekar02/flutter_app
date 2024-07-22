class AttendanceRecord {
  final String status;
  final String selectedDate;
  final String selectedTime;
  
  final String remarks;

  AttendanceRecord({
    required this.status,
    required this.selectedDate,
    required this.selectedTime,
    
    required this.remarks,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      status: json['status'],
      selectedDate: json['selectedDate'],
      selectedTime: json['selectedTime'],
     
      remarks: json['remarks'],
    );
  }
}
