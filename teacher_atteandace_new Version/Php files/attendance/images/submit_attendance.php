<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "teachers_attendance";


// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Get the posted data
$data = json_decode(file_get_contents("php://input"), true);

if (isset($data['selectedDate']) && isset($data['selectedTime']) && isset($data['status']) && isset($data['remarks'])) {
    $selectedDate = $data['selectedDate'];
    $selectedTime = $data['selectedTime'];
    $currentLocation = "Shivane"; // Static location
    $status = $data['status'];
    $remarks = $data['remarks'];

    $sql = "INSERT INTO attendance (date, time, location, status, remarks) VALUES ('$selectedDate', '$selectedTime', '$currentLocation', '$status', '$remarks')";

    if ($conn->query($sql) === TRUE) {
        echo json_encode(array("message" => "Attendance submitted successfully!"));
    } else {
        echo json_encode(array("message" => "Error: " . $sql . "<br>" . $conn->error));
    }
} else {
    echo json_encode(array("message" => "Invalid input"));
}

$conn->close();
?>
