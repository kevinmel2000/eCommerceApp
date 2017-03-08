<?php
include('db_connect.php');
header('Content-Type: application/json');
$arr_retrieve = array();
$arr_invoices = array();
$sql = "SELECT inv_number, insertionDate FROM invoiceData";
if($result = mysqli_query($conn, $sql)){
	if(mysqli_num_rows($result)>0){
		while($row=mysqli_fetch_assoc($result)){
			array_push($arr_invoices, array("inv_number"=>$row["inv_number"], "date"=>$row["insertionDate"]));
		}
		/*array_push($arr_retrieve, array(
			"Status"=>"Success",
			"invoices"=>$arr_invoices
		));*/
	} else {
		array_push($arr_retrieve, array(
			//"Status"=>"Failed",
			"invoices"=>"None. Column is empty."
		));
	}
} else {
	array_push($arr_retrieve, array(
		"Status"=>"Failed",
		"invoices"=>"None. Query error."
	));
}
//echo json_encode(array("Invoice"=>$arr_retrieve));
echo json_encode(array("invoices"=>$arr_invoices));
?>