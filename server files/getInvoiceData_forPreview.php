<?php
include('db_connect.php');
header('Content-Type: application/json');

$INV_NUMBER = $_REQUEST["inv_number"];
$arr_retrieve = array();
$arr_invoices = array();
$arr_total = array();
$total = 0;

$sql="SELECT a.inv_prodID, a.inv_prodQty, b.prod_price, b.prod_name FROM invoiceDetail a JOIN productDetail b ON a.inv_prodID=b.prod_id WHERE a.inv_number='".$INV_NUMBER."'";
if($result = mysqli_query($conn, $sql)){
	if(mysqli_num_rows($result)>0){
		$i=0;
		while($row=mysqli_fetch_assoc($result)){
			
			$arr_total[$i] = intval($row["prod_price"])* intval($row["inv_prodQty"]);
			array_push($arr_invoices, array(
				"inv_prodID"=>$row["inv_prodID"],
				"inv_prodQty"=>$row["inv_prodQty"],
				"prod_price"=>$row["prod_price"],
				"prod_name"=>$row["prod_name"]
			));
			$i++;
			
		}
		$total = array_sum($arr_total);
		array_push($arr_retrieve, array(
				"Status"=>"Success",
				"Total" => (string)$total,
				"Products" => $arr_invoices
			));
	} else {
		array_push($arr_invoices, array(
			"inv_prodID"=>"Data is not available",
			"inv_prodQty"=>"Data is not available",
			"prod_price"=>"Data is not available",
			"prod_name"=>"Data is not available"
		));
		array_push($arr_retrieve, array(
				"Status"=>"Failed",
				"Total" => "0",
				"Products" => $arr_invoices
			));
	}
}else{
	array_push($arr_invoices, array(
		"invoices"=>"None. Query error.",
		"inv_prodID"=>"None. Query error.",
		"inv_prodQty"=>"None. Query error.",
		"prod_price"=>"None. Query error.",
		"prod_name"=>"None. Query error."
	));
	array_push($arr_retrieve, array(
				"Status"=>"Failed",
				"Total" => "0",
				"Products" => $arr_invoices
			));
}


echo json_encode(array("Invoice"=>$arr_retrieve));
?>