<?php

/*
* Copyright (c) 2016, CV. Imperio Teknologi Indonesia. All rights reserved.
* PHP Source Code for SimCloud Project by Luthfi Fathur Rahman.
* It is restricted to other people to use, duplicate, re-write some part or all part of this code without any permission from CV. Imperio Teknologi Indonesia.
*/

 include('db_connect.php');
 include('subProcess.php');
 include('randomString.php');
 
 define ("min_pass_length", 12);
 //$email = "luthfir272@gmail.com";
 $email = $_GET['email'];
 //echo $email;
 if($email==''){
    echo "Please insert your email.";
 }else{
    $sql_find_user = "SELECT user_id, user_email FROM `user_creds` WHERE user_email LIKE '$email'";
    $sqlresult = mysqli_query($conn,$sql_find_user);

    if($sqlresult){
     while($row=mysqli_fetch_assoc($sqlresult)){
        $randpass = generateRandomString(min_pass_length);
        $hashed_randpass = create_hash($randpass);
        $sql_ow_pass = "UPDATE `user_creds` SET `user_pass`='$hashed_randpass' WHERE `user_email`='$email'";
        $sqlresult2 = mysqli_query($conn,$sql_ow_pass);
        if($sqlresult2){
                $to = $email;
                $subject = 'eCommerce App - Your New Password.'; 
                $message = "-------DO NOT REPLY THIS EMAIL---------\n\n
Dear ".$row['user_name'].",\nIt seems like you forget your eCommerce App account password. This is your new password:
                \n\n".$randpass."\n\nPlease log in to your account and change the password.\n\nThank you for using eCommerce App.\n\n\nBest Regards,\n\neCommerce App Team";
                $headers = "From: generalsupport@luthfifr.com";//\r\nReply-To:generalsupport@imperio.co.id
                $mail_sent = @mail( $to, $subject, $message, $headers );
                echo $mail_sent ? "Your password has been reset." : "Mail failed to sent. Please try again.";
        }else{
            echo "Upss something went wrong.";
        }
     }
    }else{
 	echo "Upss something went wrong.";
    }
   //echo "Good to go.";
 }
 
 mysqli_close($conn);
?>