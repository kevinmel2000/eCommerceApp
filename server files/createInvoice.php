<?php
include('db_connect.php');
include('randomString.php');
header('Content-Type: application/json');
date_default_timezone_set('Asia/Jakarta');

$products = $_REQUEST['products'];
$subtotal = $_REQUEST['subtotal'];
$tax = $_REQUEST['tax'];
$weight = $_REQUEST['weight'];
$shipper = $_REQUEST['shipper'];
$shipperService = $_REQUEST['shipperService'];
$shippingCost = $_REQUEST['shippingCost'];
$paymentMethod = $_REQUEST['paymentMethod'];
$userid = $_REQUEST["userid"];

$arr_retrieve = array();
$min_length = 8;

if (!empty($userid) && !empty($products) && !empty($subtotal) && !empty($tax) && !empty($shipper) && !empty($shipperService) && !empty($shippingCost) && !empty($paymentMethod)) {
	if (validateJSON($products)) {
		$inv_number = createInvoiceNumber(generateRandomString($min_length));
		$decodedProducts = json_decode($products, true);
		if(!empty($decodedProducts)){//Decode 1 is success.
			if (is_array($decodedProducts)) {
				/*array_push($arr_retrieve, array(
				"status"=>"Success",
				"message"=>"Decode 1: Products JSON is successfully decoded"
				));*/
				if (insertInvoiceData($userid, $inv_number, $subtotal, $tax, $weight, $shipper, $shipperService, $shippingCost, $paymentMethod, $conn)){
					if (insertInvoiceDetail($inv_number, $decodedProducts, $conn)) {
						array_push($arr_retrieve, array(
						"status"=>"Success",
						"message"=>"New invoice is created and recorded successfully."
						));
					} else {
						array_push($arr_retrieve, array(
						"status"=>"Failed",
						"message"=>"Something is wrong in function insertInvoiceDetail."
						));
					}
				} else {
					array_push($arr_retrieve, array(
					"status"=>"Failed",
					"message"=>"Something is wrong in function insertInvoiceData."
					));
				}
			} else if (is_string($decodedProducts)) {
				$decodedProducts1 = json_decode($decodedProducts, true);
				if(is_array($decodedProducts1)){
					array_push($arr_retrieve, array(
					"status"=>"Success",
					"message"=>"Decode 2: Products JSON is successfully decoded"
					));
				} else {
					array_push($arr_retrieve, array(
					"status"=>"Failed",
					"message"=>"Decode 2: Products JSON is failed to decode"
					));
				}
			} else {
				array_push($arr_retrieve, array(
				"status"=>"Failed",
				"message"=>"Decode 1: It is neither an array or string."
				));
			}
		} else {
			array_push($arr_retrieve, array(
			"status"=>"Failed",
			"message"=>"Decode 1: Products JSON is failed to decode"
			));
		}
	} else {
		array_push($arr_retrieve, array(
			"status"=>"Failed",
			"message"=>"Products data is not a valid JSON"
		));
	}
} else {
	array_push($arr_retrieve, array(
		"status"=>"Failed",
		"message"=>"All parameter fields must be filled. Userid= $userid, roduct = $products; subtotal = $subtotal; tax = $tax; shipper name = $shipper; shipper service = $shipperService; shipping cost = $shippingCost; payment method = $paymentMethod."
	));
}

if (!empty($arr_retrieve)) {
	echo json_encode(array("InvoiceStatus"=>$arr_retrieve));
} else {
	array_push($arr_retrieve, array(
		"status"=>"Failed",
		"message"=>"Something is wrong when input the data into database. Please try again."
	));
	echo json_encode(array("InvoiceStatus"=>$arr_retrieve));
}


function createInvoiceNumber($rand_str) {
	$monthInRomanNumerals = ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII"];
	return "INV/".date("Y")."/".$monthInRomanNumerals[date("m")-1]."/".date("d")."/".$rand_str;
}

function insertInvoiceData($userid, $inv_number, $subtotal, $tax, $weight, $shipper, $shipperService, $shippingCost, $paymentMethod, $conn) {
	$sql = "INSERT INTO `invoiceData`(`user_id`, `inv_number`, `inv_subtotal`, `inv_tax`, `inv_totalWeight`, `inv_shipper`, `inv_shipperService`, `inv_shippingCost`, `inv_paymentMethod`) VALUES ('".$userid."','".$inv_number."', '".$subtotal."', '".$tax."', '".$weight."', '".$shipper."', '".$shipperService."', '".$shippingCost."', '".$paymentMethod."')";
	if ($result=mysqli_query($conn, $sql)) {
		return true;	
	} else {
		return false;
	}
}

function insertInvoiceDetail($inv_number, $arr_products, $conn) {
	$sql="";
	
	foreach($arr_products as $item){
        	$values[] = "('$inv_number', '{$item[prodID]}', '{$item[qty]}')";
    	}
    	
    	$values = implode(", ", $values);
	
	$sql = "INSERT INTO `invoiceDetail`(`inv_number`, `inv_prodID`, `inv_prodQty`) VALUES {$values};";
	
	if(mysqli_query($conn, $sql)){ //mysqli_multi_query
		return true;
	} else {
		return false;
	}
}

function validateJSON($string) {
    $result = json_decode($string);

    // switch and check possible JSON errors
    switch (json_last_error()) {
        case JSON_ERROR_NONE:
            $error = ''; // JSON is valid // No error has occurred
            break;
        case JSON_ERROR_DEPTH:
            $error = 'The maximum stack depth has been exceeded.';
            break;
        case JSON_ERROR_STATE_MISMATCH:
            $error = 'Invalid or malformed JSON.';
            break;
        case JSON_ERROR_CTRL_CHAR:
            $error = 'Control character error, possibly incorrectly encoded.';
            break;
        case JSON_ERROR_SYNTAX:
            $error = 'Syntax error, malformed JSON.';
            break;
        // PHP >= 5.3.3
        case JSON_ERROR_UTF8:
            $error = 'Malformed UTF-8 characters, possibly incorrectly encoded.';
            break;
        // PHP >= 5.5.0
        case JSON_ERROR_RECURSION:
            $error = 'One or more recursive references in the value to be encoded.';
            break;
        // PHP >= 5.5.0
        case JSON_ERROR_INF_OR_NAN:
            $error = 'One or more NAN or INF values in the value to be encoded.';
            break;
        case JSON_ERROR_UNSUPPORTED_TYPE:
            $error = 'A value of a type that cannot be encoded was given.';
            break;
        default:
            $error = 'Unknown JSON error occured.';
            break;
    }

    if ($error !== '') {
    	return false;
    } else {
    	return true;
    }
}

?>