<?php
include('db_connect.php');
header('Content-Type: application/json');

$arr_retrieve = array();
$requestData = "SELECT * FROM shop_info";
$result = mysqli_query($conn, $requestData);

if($result){
	if(mysqli_num_rows($result) != 0){
		while($row=mysqli_fetch_array($result)){
                	array_push($arr_retrieve, array(
                	        "status"=> "Success",
                    		"name" => $row['Shop_Name'],
                    		"logo"=> "http://scbdresearch.com/dscApp/upload/shop/".$row['Shop_logo'],
                    		"street" => $row['Shop_street'],
                    		"city" => $row['Shop_city'],
                    		"province" => $row['Shop_province'],
                    		"country" => $row['Shop_country'],
                    		"postalcode" => $row['Shop_postalCode'],
                    		"currency" => $row['Shop_currency'],
                    		"abbrevation" => $row['Shop_Abbr']
                	)); 
            	}   
        } else {
                array_push($arr_retrieve, array(
                    "status"=>"Failed",
                    "name" => "None",
                    "logo"=> "None",
                    "street" => "None",
                    "city" => "None",
                    "province" => "None",
                    "country" => "None",
                    "postalcode" => "None",
                    "currency" => "None",
                    "abbrevation" => "None"
                ));
        }
}

echo json_encode(array("shopinfo"=>$arr_retrieve)); 

mysqli_close($conn);

?>