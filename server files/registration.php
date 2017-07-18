<?php

/*
* Copyright (c) 2016, CV. Imperio Teknologi Indonesia. All rights reserved.
* PHP Source Code for SimCloud Project by Luthfi Fathur Rahman.
* It is restricted to other people to use, duplicate, re-write some part or all part of this code without any permission from CV. Imperio Teknologi Indonesia.
*/

 include ('subProcess.php');
 include ('db_connect.php');
 include('randomString.php');
 header('Content-Type: text/html');

 $user_password = $_GET['password'];
 $user_email = $_GET['email'];

$min_length = 10;
  
 if($user_password == '' || $user_email == ''){
 	echo 'Please Fill All Values.';
 }else{
 	$sql_gid = "SELECT user_email FROM user_creds WHERE user_email LIKE '$user_email'";
    
	if(mysqli_num_rows(mysqli_query($conn,$sql_gid))>0){
 		echo 'Your account is already exist. Please go to login page.';
 	}else{
		$hashed_pass = create_hash ($user_password);
 		$userid = "CUSTOMER-".generateRandomString($min_length);
		$sql = "INSERT INTO user_creds(`user_id`,`user_email`,`user_pass`) VALUES('$userid', '$user_email','$hashed_pass')";
 		
		if(mysqli_query($conn,$sql)){
            echo $userid;
            //echo 'Successfully registered.';
 		}else{
 			echo 'Please try again.';
 		}
	}

 mysqli_close($conn); 
}

?>