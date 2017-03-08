<?php

include('db_connect.php');
header('Content-Type: application/json');
date_default_timezone_set('Asia/Jakarta');

$userId = $_REQUEST["userId"];
$invoice = $_REQUEST["invoice"];
$transferto = $_REQUEST["transferto"];
$senderbank = $_REQUEST["senderbank"];
$senderaccnum = $_REQUEST["senderaccnum"];
$transferamount = $_REQUEST["transferamount"];

$arr_retrieve = array();
$curr_date = date("Y-m-d H-i-s");

if(!empty($userId) && !empty($invoice) && !empty($transferto) && !empty($senderbank) && !empty($senderaccnum) && !empty($transferamount)) {
	$sql = "INSERT INTO `paymentConfirmation_Data`(`user_id`, `Inv_number`, `transferTo`, `SenderBank`, `SenderAccNumber`, `transferAmount`, `insertionDate`, `modifiedDate`) VALUES('".$userId."','".$invoice."','".$transferto."','".$senderbank."','".$senderaccnum."','".$transferamount."','".$curr_date."','".$curr_date."')";
	if($result = mysqli_query($conn, $sql)){
		$sql2 = "UPDATE `invoiceData` SET `inv_paymentStatus`='Paid' WHERE `inv_number`='".$invoice."' AND `user_id`='".$userId."'";
		if($result2 = mysqli_query($conn, $sql2)){
			array_push($arr_retrieve, array(
				"Status"=>"Success",
				"message"=>"Your payment confirmation has been sent. Thank you."
			));
		} else {
			array_push($arr_retrieve, array(
				"Status"=>"Failed",
				"message"=>"There is an error to insert your payment confirmation data."
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
		"message"=>"All parameters must be filled. UserID:'".$userId."', Inv Number:'".$invoice."', TransferTo:'".$transferto."', SenderBank:'".$senderbank."', SenderAccNumber:'".$senderaccnum."', TransferAmount:'".$transferamount."'."
	));
}

echo json_encode(array("PaymentConfirmation"=>$arr_retrieve));

mysqli_close($conn);

?>