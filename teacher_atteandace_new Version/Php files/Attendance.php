<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

$servername = "localhost";
$username = "dzmbjxtk_aditee1";
$password = "dzmbjxtk_aditee1";
$dbname = "dzmbjxtk_aditee1";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die(json_encode(array("message" => "Connection failed: " . $conn->connect_error)));
}

// Get the posted data
$data = json_decode(file_get_contents("php://input"), true);

if (isset($data['startDate']) && isset($data['endDate'])) {
    $startDate = $data['startDate'];
    $endDate = $data['endDate'];

    $sql = "SELECT date, status FROM attendance WHERE date BETWEEN ? AND ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ss", $startDate, $endDate);
    $stmt->execute();
    $result = $stmt->get_result();

    $attendanceData = array();

    while ($row = $result->fetch_assoc()) {
        $attendanceData[$row['date']] = $row['status'];
    }

    echo json_encode($attendanceData);
    $stmt->close();
} else {
    echo json_encode(array("message" => "Invalid input"));
}

$conn->close();
?>
