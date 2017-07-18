<?php
	$db_hostname="localhost"; //local server name default localhost
	$db_username="scbdres1_admin";  //mysql username default is root.
	$db_password="admin123";   //blank if no password is set for mysql.
	$db_database="scbdres1_dscApp";  //database name which you created
	
	$conn = new mysqli($db_hostname, $db_username, $db_password);

	if ($conn->connect_error) {
		die("Connection failed: " . $conn->connect_error);
	}

	$conn->select_db ($db_database );
?>