<?php
include('db_connect.php');
header('Content-Type: application/json');

$USERID = $_REQUEST["userid"];
$PAYMETHOD = $_REQUEST["method"];
$res_status = array();

$sql = "UPDATE `paymentMethods_default` SET `default_payment`='".$PAYMETHOD."' WHERE `user_id`='".$USERID."'";
if ($result = mysqli_query($conn, $sql)){
	array_push($res_status, array(
		"Status"=>"Success"
	));
} else {
	array_push($res_status, array(
		"Status"=>"Failed"
	));
}
echo json_encode(array("paymentDefault"=>$res_status));
mysqli_close($conn);
?>