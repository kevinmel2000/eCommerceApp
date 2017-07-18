<?php

/*
* Copyright (c) 2016, CV. Imperio Teknologi Indonesia. All rights reserved.
* PHP Source Code for SimCloud Project by Luthfi Fathur Rahman.
* It is restricted to other people to use, duplicate, re-write some part or all part of this code without any permission from CV. Imperio Teknologi Indonesia.
*/

 include('db_connect.php');
 
 $namakotak = $_GET['kontaknama'];
 $namakotak = mysqli_real_escape_string ($conn,$namakotak);
 $telfon1kontak = $_GET['kontaktelfon1'];
 $telfon1kontak = mysqli_real_escape_string ($conn,$telfon1kontak);
 $emailkontak = $_GET['kontakemail'];
 $emailUser = $_GET['googleid'];
 $j = strpos($emailUser,"@");
 $trimmed_googleid = substr($emailUser, 0, $j);
 $trimmed_googleid2 = str_replace(".","",$trimmed_googleid);
 //$sql="SELECT * FROM contacts_$trimmed_googleid";
 //$result= mysqli_query($conn,$sql);
 //if(mysqli_num_rows($result)>0){
	$sql_truncate="TRUNCATE TABLE contacts_$trimmed_googleid2";
	$sql_truncate_res=mysqli_query($conn,$sql_truncate);
    $autoInc_reset="ALTER TABLE contacts_$trimmed_googleid2 AUTO_INCREMENT=1";
    $autoInc_reset_RES=mysqli_query($conn,$autoInc_reset);
 //}
 
 mysqli_close($conn);

?>