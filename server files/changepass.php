<?php

/*
* Copyright (c) 2016, CV. Imperio Teknologi Indonesia. All rights reserved.
* PHP Source Code for SimCloud Project by Luthfi Fathur Rahman.
* It is restricted to other people to use, duplicate, re-write some part or all part of this code without any permission from CV. Imperio Teknologi Indonesia.
*/

 include('db_connect.php');
 include('subProcess.php');

 header('Content-Type: text/html');
 
 define ("min_pass_length", 12);
 $userid = $_REQUEST['userid'];
 $oldpass = $_REQUEST['old_password'];
 $newpass = $_REQUEST['new_password'];

 //$sql_find_phone = "SELECT user_phone FROM `user_credentials` WHERE user_phone LIKE '".$_REQUEST['user_phone']."'";
 $sql_find_user = "SELECT user_pass FROM `user_creds` WHERE user_id LIKE '$userid'";
 $sqlresult = mysqli_query($conn, $sql_find_user);
 if($sqlresult){
     while($row=mysqli_fetch_assoc($sqlresult)){
        if(validate_password($oldpass, $row['user_pass'])){
            $hashed_randpass = create_hash($newpass);
            $sql_ow_pass = "UPDATE `user_creds` SET `user_pass`='$hashed_randpass' WHERE `user_id`='$userid'";
            $sqlresult2 = mysqli_query($conn, $sql_ow_pass);
            if($sqlresult2){
                echo "Your password has been changed. Please log-in again using your new password.";
            }else{
                echo "Upss something went wrong.";
            }   
        }else{
            echo "Wrong password.";
        }
     }
 }else{
 	echo "Your data is not found.";
 }
 
 mysqli_close($conn);

?>