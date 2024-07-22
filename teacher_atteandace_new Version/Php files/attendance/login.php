

<?php
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
// Define global variables for username and password
global $username, $password;

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $username = $_POST['username'];
    $password = $_POST['password'];

    $sql = "SELECT * FROM teachers_attendance WHERE Username='$username' AND password='$password' AND status='active'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        echo json_encode("Success");
    } else {
        echo json_encode("Invalid credentials or inactive account");
    }
   
}


?>


