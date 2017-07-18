<?php
include('db_connect.php');
header('Content-Type: application/json');

$userID = $_REQUEST['userid'];
$newcurrency = $_REQUEST["newcurrency"];
$action = $_REQUEST["action"];
$arr_retrieve = array();

function get_all_currency_data($conn) {
	$arr_retrieve = array();
	$sql = "SELECT * FROM `currency_data`";
	mysqli_set_charset($conn,"utf8");
	$result = mysqli_query($conn, $sql);
	if ($result) {
		if (mysqli_num_rows($result) > 0){
			while ($row=mysqli_fetch_array($result)) {
				array_push($arr_retrieve, array(
        			"id" => $row['currency_id'],
        			"name" => $row['currency_name'],
        			"code" => $row['currency_code']
    				));
			}
			echo json_encode(array("currencylist"=>$arr_retrieve));
		} else {
			array_push($arr_retrieve, array(
    			"status_request" => "Failed",
        		"message" => "No row(s) found in get all currency data function"
    			));
    			echo json_encode(array("currencylist_status"=>$arr_retrieve));
		}
	} else {
		array_push($arr_retrieve, array(
    		"status_request" => "Failed",
        	"message" => mysqli_connect_error($conn)//"There are some errors in mysql sytax in get all currency data function"
    		));
    		echo json_encode(array("currencylist_status"=>$arr_retrieve));
	}
}

function get_user_current_currency($conn, $userID) {
	$arr_retrieve = array();
	$sql = "SELECT `currency_id`,  `currency_code`,  `currency_name` FROM `currency_data` JOIN `user_profile` ON `user_profile`.`user_currency`=`currency_data`.`currency_id` WHERE `user_profile`.`user_id` = '".$userID."'";
	$result = mysqli_query($conn, $sql);
	if ($result) {
		if (mysqli_num_rows($result)>0){
			while ($row=mysqli_fetch_array($result)) {
				array_push($arr_retrieve, array(
        			"id" => $row['currency_id'],
        			"name" => $row['currency_name'],
        			"code" => $row['currency_code']
    				));
    				echo json_encode(array("user_currency"=>$arr_retrieve));
			}
		} else {
			array_push($arr_retrieve, array(
    			"status_request" => "Failed",
        		"message" => "No row(s) found in get user current currency function"
    			));
    			echo json_encode(array("user_currency_status"=>$arr_retrieve));
		}
	} else {
		array_push($arr_retrieve, array(
    		"status_request" => "Failed",
        	"message" => mysqli_connect_error($conn)
    		));
    		echo json_encode(array("user_currency_status"=>$arr_retrieve));
	}
	
}

function change_user_currency($conn, $userID, $newcurrency) {
$arr_retrieve = array();
if (isset($newcurrency)) {
	$sql = "UPDATE user_profile SET user_currency = '".$newcurrency."' WHERE user_id = '".$userID."'";
	$result = mysqli_query($conn, $sql);
	if ($result) {
		array_push($arr_retrieve, array(
    			"status_request" => "Success",
        		"message" => "Your currency preference is successfully updated.",
        		"new currency"=> $newcurrency
    			));
    			echo json_encode(array("update_currency_status"=>$arr_retrieve));
	} else {
		array_push($arr_retrieve, array(
    		"status_request" => "Failed",
        	"message" => mysqli_connect_error($conn),
        	"new currency"=> "none"
    		));
    		echo json_encode(array("update_currency_status"=>$arr_retrieve));
	}
} else {
	array_push($arr_retrieve, array(
    	"status_request" => "Failed",
        "message" => "There is no value in new currency field in change user currency function",
        "new currency"=> "none"
    	));
    	echo json_encode(array("update_currency_status"=>$arr_retrieve));
}
}

if (isset($userID)) {
	switch ($action) {
		case "all_currency":
			get_all_currency_data($conn);
			break;
		case "user_currency":
			get_user_current_currency($conn, $userID);
			break;
		case "change_user_currency":
			change_user_currency($conn, $userID, $newcurrency);
			break;
		default:
			array_push($arr_retrieve, array(
    			"status_request" => "Failed",
        		"message" => "There is no value in action field"
    			));
    			echo json_encode(array("user_currency_status"=>$arr_retrieve));
			break;			
	}
} else {
    array_push($arr_retrieve, array(
    	"status_request" => "Failed",
        "message" => "There is no value in user ID field"
    ));
    echo json_encode(array("user_currency_status"=>$arr_retrieve));
}
 
mysqli_close($conn);
?>