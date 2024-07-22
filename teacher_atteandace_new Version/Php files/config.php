<?php
// config.php

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
?>
