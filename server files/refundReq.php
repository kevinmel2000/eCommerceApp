<?php
include('db_connect.php');
header('Content-Type: application/json');
date_default_timezone_set('Asia/Jakarta');

$userID = $_REQUEST["userid"];
$Inv_number = $_REQUEST["inv_number"];
$items = $_REQUEST["items"];

$arr_retrieve = array();
$curr_date = date("Y-m-d H-i-s");

if(!empty($Inv_number) && !empty($items)) {
	$sql = "UPDATE `invoiceData` SET `inv_paymentStatus`='Requested for refund',`modifiedDate`='".$curr_date."' WHERE `inv_number`='".$Inv_number."' AND `user_id`='".$userID."'";
	if($result = mysqli_query($conn, $sql)) {
		$sql1 = "INSERT INTO `refundreq_data`(`user_id`, `Inv_number`, `items`,`modifiedDate`) VALUES('".$userID."','".$Inv_number."','".$items."','".$curr_date."')";
		if($result1 = mysqli_query($conn, $sql1)) {
			array_push($arr_retrieve, array(
				"Status"=>"Success",
				"message"=>"Your refund request will be processed shortly."
			));
		} else {
			array_push($arr_retrieve, array(
				"Status"=>"Failed",
				"message"=>"There is an error to insert your refund request data."
			));
		}
	} else {
		array_push($arr_retrieve, array(
			"Status"=>"Failed",
			"message"=>"There is an error to update your invoice status."
		));
	}
} else {
	array_push($arr_retrieve, array(
		"Status"=>"Failed",
		"message"=>"All parameters must be filled."
	));
}

echo json_encode(array("RefundRequest"=>$arr_retrieve));
?>