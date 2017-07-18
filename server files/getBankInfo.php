<?php
include('db_connect.php');
header('Content-Type: application/json');
$arr_retrieve = array();
$arr_banks = array();
$sql="SELECT * FROM `shop_bankAcc`";
if($result = mysqli_query($conn, $sql)){
		if(mysqli_num_rows($result)>0){
			while($row=mysqli_fetch_assoc($result)){
				array_push($arr_banks, array(
					"name"=>$row["Bank_name"],
					"branch"=> $row["Branch_name"],
					"accNumber"=>$row["Acc_number"],
					"accHolderName"=>$row["Acc_holder_name"]
				));
			}
			array_push($arr_retrieve, array(
					"Status"=>"Success",
					"banks"=> $arr_banks
				));			
		} else {
			array_push($arr_banks, array(
					"name"=>"Data is not available.",
					"branch"=> "Data is not available.",
					"accNumber"=>"Data is not available.",
					"accHolderName"=>"Data is not available."
				));
			array_push($arr_retrieve, array(
				"Status"=>"Failed",
				"banks"=>$arr_banks
			));
		}
		
	}
echo json_encode(array("BankInfo"=>$arr_retrieve));

mysqli_close($conn);
?>