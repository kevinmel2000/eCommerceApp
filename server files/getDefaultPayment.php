<?php
include('db_connect.php');
header('Content-Type: application/json');

$USERID = $_REQUEST["userid"];
$arr_retrieve = array();
$sql = "SELECT `default_payment`,`user_id`,`paymentMethods`.`Payment_logo` FROM `paymentMethods_default` JOIN `paymentMethods` ON `Payment_name`=`default_payment` WHERE `user_id`='".$USERID."'";
if ($result = mysqli_query($conn, $sql)){
	if(mysqli_num_rows($result)>0){
		while($row=mysqli_fetch_assoc($result)){
			array_push($arr_retrieve, array("Status"=>"Success",
			"default_payment"=>$row["default_payment"],
			"logo"=>"https://www.imperio.co.id/project/ecommerceApp/AdminPanel/upload/payment_methods/".$row["Payment_logo"]));
		}
	} else {
		array_push($arr_retrieve, array("Status"=>"Failed",
		"default_payment"=>"Data is not available",
		"logo"=>"Data is not available"));
	}
} else {
	array_push($arr_retrieve, array(
		"Status"=>"Failed",
		"default_payment"=>"Data is not available",
		"logo"=>"Data is not available"
	));
}
echo json_encode(array("paymentDefault"=>$arr_retrieve));
mysqli_close($conn);
?>