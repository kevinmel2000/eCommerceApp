<?php
/*
* Copyright (c) 2016, CV. Imperio Teknologi Indonesia. All rights reserved.
* PHP Source Code for SimCloud Project by Luthfi Fathur Rahman.
* It is restricted to other people to use, duplicate, re-write some part or all part of this code without any permission from CV. Imperio Teknologi Indonesia.
*/

 include('db_connect.php');
 
 header('Content-Type: text/html');

 $userid = $_REQUEST['userid'];

 $sql_dropCred="DELETE FROM `user_creds` WHERE `user_id` = '$userid'";
 $sql_dropCred_res=mysqli_query($conn,$sql_dropCred);
 if ($sql_dropCred_res) {
     $sql_dropProfile = "DELETE FROM `user_profile` WHERE `user_id` = '$userid'";
     $sql_dropProfile_res = mysqli_query($conn,$sql_dropCred);
     if ($sql_dropProfile_res) {
         echo "You account has been deleted.";
     }
 } else {
     echo "There is something wrong, your account cannot be deleted. Please try again."
 }
 
 mysqli_close($conn);

?>