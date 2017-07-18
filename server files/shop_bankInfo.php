<?php
include('db_connect.php');
header('Content-Type: application/json');

$arr_retrieve = array();
$requestData = "SELECT * FROM shop_bankAcc";
if($result = mysqli_query($conn, $requestData)){
	if(mysqli_num_rows($result) != 0){
		while($row=mysqli_fetch_array($result)){
                	array_push($arr_retrieve, array(
                    		"bank" => $row['Bank_name']
                	)); 
            	}   
        } else {
                array_push($arr_retrieve, array(
                    "bank" => "None"
                ));
        }
}



echo json_encode(array("bankInfo"=>$arr_retrieve)); 

mysqli_close($conn);
?>