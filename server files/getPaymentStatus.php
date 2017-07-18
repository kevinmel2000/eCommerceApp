<?php
include('db_connect.php');
header('Content-Type: application/json');
$arr_retrieve = array();

$invoice = $_REQUEST["invoice"];

if (!empty($invoice)) {
	$sql="SELECT `inv_paymentStatus` FROM `invoiceData` WHERE `inv_number` = '".$invoice."'";
	
	if($result = mysqli_query($conn, $sql)){
		if(mysqli_num_rows($result)>0){
			while($row=mysqli_fetch_assoc($result)){
				array_push($arr_retrieve, array(
					"Status"=>"Success",
					"PaymentStatus"=> $row["inv_paymentStatus"]
				));
			}			
		} else {
			array_push($arr_retrieve, array(
				"Status"=>"Failed",
				"PaymentStatus"=>"Data is not vailable for invoice '".$invoice."'"
			));
		}
		
	}
} else {
	array_push($arr_retrieve, array(
		"Status"=>"Failed",
		"PaymentStatus"=>"Data is not vailable. Please provide the invoice number."
	));
}

echo json_encode(array("PaymentStatus"=>$arr_retrieve));

mysqli_close($conn);
?>