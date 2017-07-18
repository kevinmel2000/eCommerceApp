<?php
include('db_connect.php');
header('Content-Type: application/json');

define("access_key", "8b81b3d7feb4fde374751cc61446cc08");

$currencyIDTo = $_REQUEST['currencyto'];
$currencyIDFrom = $_REQUEST['currencyfrom'];
$amount = $_REQUEST['amount'];
$access_key = access_key;

$resultArr = array();

//use this function if you have a free account in currencylayer.com
function IndirectCurrencyConvertion($access_key, $to, $from, $amount){
	$convertedArr = array();
	$converted = 0;
	$curl = curl_init();
	curl_setopt_array($curl, array(
		CURLOPT_URL => "http://apilayer.net/api/live?access_key=".$access_key."&currencies=".$to.",".$from, //the currency exchange rate is based on USD
		CURLOPT_RETURNTRANSFER => true,
	));

	$response = curl_exec($curl);
    	$err = curl_error($curl);

	curl_close($curl);

	if ($err) {
        	echo "cURL Error #:" . $err;
    	} else {
        	$resultArr = json_decode($response, true);
    	}

	if ($from != "USD" && $to == "USD"){
		//user currency is USD, shop currency is not USD
		$converted = round((1/$resultArr[quotes][USD.$from])*$amount,2);
	} else if ($from == "USD" && $to != "USD" ) {
		//user currency is not USD, shop currency is USD
		$converted = round($resultArr[quotes][USD.$to]*$amount,2);
	} else if ($from != "USD" && $to != "USD") {
		//Both user and shop currency are not USD
		$converted = round($resultArr[quotes][USD.$to]*((1/$resultArr[quotes][USD.$from])*$amount),2);
	}
	$converted = (string)$converted;
	array_push($convertedArr, array(
		"from"=>$from,
		"to"=>$to,
		"originalAmount"=>$amount,
		"convertedAmount"=>$converted
	));
	echo json_encode(array("ConversionResult"=>$convertedArr));
}

//use this function if you have a paid account in currencylayer.com
function DirectCurrencyConvertion($access_key, $to, $from, $amount) {
	$convertedArr = array();
	$curl = curl_init();
	curl_setopt_array($curl, array(
		CURLOPT_URL => "http://apilayer.net/api/convert?access_key=".$access_key."&from=".$from."&to=".$to."&amount=".$amount,
		CURLOPT_RETURNTRANSFER => true,
	));

	$response = curl_exec($curl);
    	$err = curl_error($curl);

	curl_close($curl);

	if ($err) {
        	echo "cURL Error #:" . $err;
    	} else {
        	$resultArr = json_decode($response, true);
    	}

	array_push($convertedArr, array(
		"from"=>$resultArr[query][from],
		"to"=>$resultArr[query][to],
		"originalAmount"=>$resultArr[query][amount],
		"convertedAmount"=>$resultArr[result]
	));
	echo json_encode(array("ConversionResult"=>$convertedArr));
}

function getCurrencyCode($conn, $currencyid) {
	$a="";
	$sql="SELECT currency_code FROM currency_data WHERE currency_id='".$currencyid."'";
	if($result=mysqli_query($conn,$sql)) {
		if(mysqli_num_rows($result)>0) {
			while($row=mysqli_fetch_array($result)) {
				$a=$row['currency_code'];
			}
		}
	}
	return $a;
}

if (isset($currencyIDTo) && isset($currencyIDFrom) && isset($amount)) {
	if(is_numeric($currencyIDTo) && is_numeric($currencyIDFrom) && is_numeric($amount)) {
		$to=getCurrencyCode($conn, $currencyIDTo);
		$from=getCurrencyCode($conn, $currencyIDFrom);
	} else {
		$to=$currencyIDTo;
		$from=$currencyIDFrom;
	}
	IndirectCurrencyConvertion($access_key, $to, $from, $amount);
} else {
	array_push($resultArr,array(
		"result"=>"please fill all the fields"
	));
	echo json_encode(array("ConversionResult"=>$resultArr));
}

?>
