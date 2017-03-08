<?php

/*
* Copyright (c) 2016, CV. Imperio Teknologi Indonesia. All rights reserved.
* PHP Source Code for SimCloud Project by Luthfi Fathur Rahman.
* It is restricted to other people to use, duplicate, re-write some part or all part of this code without any permission from CV. Imperio Teknologi Indonesia.
*/

include('subProcess.php');
include('db_connect.php');
header('Content-Type: application/json');

$user_password = $_GET['password'];
$user_email = $_GET['email'];
$arr_retrieve = array();

if($user_password == '' || $user_email == ''){
 	array_push($arr_retrieve, array(
		"status"=>"failed",
		"message"=>"Please Fill All Values.",
		"userid"=> "none",
		"usercurrency"=> "none"
	));
}else{
	$sql="SELECT user_creds.user_id, user_creds.user_pass, user_creds.user_email, user_currency FROM user_creds JOIN user_profile ON user_creds.user_id = user_profile.user_id WHERE user_creds.user_email='$user_email'";
	$result= mysqli_query($conn,$sql);
	if(mysqli_num_rows($result)>0){
		while($row=mysqli_fetch_assoc($result)){
			if(validate_password($user_password, $row['user_pass'])){
				if($user_email == $row['user_email']){
					array_push($arr_retrieve, array(
						"status"=>"success",
						"message"=>"Login success.",
						"userid"=> $row['user_id'],
						"usercurrency"=> $row['user_currency']
					));
                }
            } else {
				array_push($arr_retrieve, array(
						"status"=>"failed",
						"message"=>"Email or Password is wrong. Please try again.",
						"userid"=> "none",
						"usercurrency"=> "none"
					));
			}
		}
	}else{
		array_push($arr_retrieve, array(
						"status"=>"failed",
						"message"=>"Email or ID is not found. Please go to Sign Up page to register.",
						"userid"=> "none",
						"usercurrency"=> "none"
					));
	}
}

echo json_encode(array("loginstatus"=>$arr_retrieve));
mysqli_close($conn);
?>