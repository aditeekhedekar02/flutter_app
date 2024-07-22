<?php
header('Content-Type: application/json');

// Database connection parameters
$servername = "localhost";
$username = "dzmbjxtk_aditee1";
$password = "dzmbjxtk_aditee1";
$dbname = "dzmbjxtk_aditee1";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Handle POST request
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Get the Username from the POST request
    $username = $_POST['Username'];

    // Prepare the SQL statement to fetch the user details based on the Username
    $sql = "SELECT * FROM teachers_attendance WHERE username = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $username);
    $stmt->execute();
    $result = $stmt->get_result();
    $user = $result->fetch_assoc();

    // Check if the user exists
    if ($user) {
        $response = array(
            'Name' => $user['Name'],
            'Username' => $user['Username'],
            'Email' => $user['Email'],
            'phone' => $user['PhoneNo'], // Fetching phone number from MySQL table
            'address' => $user['Address'], // Fetching address from MySQL table
            'Status' => $user['Status'],
            'ImagePath' => $user['ImagePath'] ?  $user['ImagePath'] : null // Check if ImagePath is NULL
        );
    } else {
        $response = array('error' => 'User not found');
    }

    // Output the response in JSON format
    echo json_encode($response);
}
?>
