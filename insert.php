<?php
$conn = new mysqli("localhost", "root", "", "trippies_db");

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// These names must match the 'name' attributes in your HTML form!
$email = $_POST['user_email'];
$location = $_POST['user_location'];

$sql = "INSERT INTO contact_info (email, location) VALUES ('$email', '$location')";

if ($conn->query($sql) === TRUE) {
    echo "<h1>Success!</h1><p>Data saved to Trippies Database.</p>";
    echo "<a href='index.html'>Back to Home</a>";
} else {
    echo "Error: " . $conn->error;
}

$conn->close();
?>