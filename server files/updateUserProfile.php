<?php
include('db_connect.php');
header('Content-Type: text/html');

$NAME = $_REQUEST["name"];
$STREET = $_REQUEST["street"];
$CITY = $_REQUEST["city"];
$PROVINCE = $_REQUEST["province"];
$COUNTRY = $_REQUEST["country"];
$POSTCODE = $_REQUEST["postalCode"];
$MOBILENUMBER = $_REQUEST["mobileNumber"];
$USERID = $_REQUEST["userid"];

if($NAME == '' && $STREET == '' && $CITY == '' && $PROVINCE == '' && $COUNTRY == '' && $POSTCODE == '' && $MOBILENUMBER == ''){
 	echo 'Please Fill All Values.';
} else {
	//update the existing user data
	$sql_search = "SELECT * FROM user_profile WHERE `user_id`='".$USERID."'";
	$result = mysqli_query($conn, $sql_search);
	if ($result){
		if(mysqli_num_rows($result) > 0) {
			$sql_update = "UPDATE user_profile SET `user_name`='$NAME',`user_address_street`='$STREET',`user_address_city`='$CITY',`user_address_province`='$PROVINCE',`user_address_country`='$COUNTRY',`user_address_postalCode`='$POSTCODE',`user_mobilePhone`='$MOBILENUMBER' WHERE `user_id`='$USERID'";
 		
			if(mysqli_query($conn,$sql_update)){
      				echo 'User profile data input success.';
 			}else{
 	  			echo 'Cannot update user info. Please try again.';
 			}
		} else {
			//insert new user data
			$sql_email = "SELECT `user_email` FROM `user_creds` WHERE `user_id` = '".$USERID."'";
			if ($result = mysqli_query($conn, $sql_email)){
				if (mysqli_num_rows($result) > 0) {
					while($row = mysqli_fetch_assoc($result)) {
						$sql_insert = "INSERT INTO `user_profile`(`user_id`, `user_name`, `user_email`, `user_address_street`, `user_address_city`, `user_address_province`, `user_address_country`, `user_address_postalCode`, `user_mobilePhone`) VALUES('".$USERID."', '".$NAME."', '".$row['user_email']."', '".$STREET."', '".$CITY."', '".$PROVINCE."', '".$COUNTRY."', '".$POSTCODE."', '".$MOBILENUMBER."')";
						if(mysqli_query($conn, $sql_insert)) {
							echo 'User profile data input success.';
						} else {
							echo "Cannot insert user info. Please try again.";
						}
					}
				} else {
					echo 'Email not found, please try again.';
				}
			} else {
				echo 'Query error. Please try again.';
			}
		}
	} else {
		echo 'Query error. Please try again.';
	}
}

mysqli_close($conn); 
?>