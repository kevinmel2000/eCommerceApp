<?php
include('db_connect.php');
header('Content-Type: application/json');

$PRODUK = $_REQUEST["produk"];
$USERID = $_REQUEST["userid"];
$arr_retrieve = array();
$usercurrency = "";
$shopcurrency = "";

$ShopCurrency_sql = "SELECT Shop_currency FROM shop_info";
if ($result = mysqli_query($conn, $ShopCurrency_sql)) {
	if (mysqli_num_rows($result)>0) {
		while($row=mysqli_fetch_array($result)) {
			$shopcurrency = $row["Shop_currency"];
		}
	}
}

if (isset($USERID)) {
	$UserCurrency_sql = "SELECT user_currency FROM user_profile WHERE user_id='".$USERID."'";
	if ($result = mysqli_query($conn, $UserCurrency_sql)) {
		if (mysqli_num_rows($result)>0) {
			while($row=mysqli_fetch_array($result)) {
				$usercurrency = $row["user_currency"];
			}
		}
	}
} else {
	$usercurrency = $shopcurrency;
}

$requestData = "SELECT * FROM productDetail WHERE prod_name='".$PRODUK."'";
$result = mysqli_query($conn, $requestData);
if($result){
    while($row=mysqli_fetch_array($result)){
    	$prodname = $row['prod_name'];
    	$FolderProdPath = str_replace(" ","_",$prodname);
        array_push($arr_retrieve, array(
          "id" => $row['prod_id'],
          "name" => $row['prod_name'],
          "price" => convertcurrency($usercurrency, $shopcurrency, $row['prod_price'], $conn),
          "pict1" => "https://www.imperio.co.id/project/ecommerceApp/AdminPanel/upload/product/$FolderProdPath/".$row['prod_pict_1'],
          "pict2" => "https://www.imperio.co.id/project/ecommerceApp/AdminPanel/upload/product/$FolderProdPath/".$row['prod_pict_2'],
          "pict3" => "https://www.imperio.co.id/project/ecommerceApp/AdminPanel/upload/product/$FolderProdPath/".$row['prod_pict_3'],
          "info_minBuy" => $row['prod_info_minBuy'],
          "info_weight" => $row['prod_info_weight'],
          "info_condition" => $row['prod_info_condition'],
          "info_stock" => $row['prod_info_stock'],
          "desc" => $row['prod_desc']
        ));
    }
    echo json_encode(array("ProdukDetail"=>$arr_retrieve)); 
}

function convertcurrency($usercurrency, $shopcurrency, $amount, $conn) {
	if ($usercurrency != $shopcurrency) {
		$curl = curl_init();
		curl_setopt_array($curl, array(
			CURLOPT_URL => "https://www.imperio.co.id/project/ecommerceApp/convertcurrency.php?currencyto=".$usercurrency."&currencyfrom=".$shopcurrency."&amount=".$amount, 
			CURLOPT_RETURNTRANSFER => true,
		));
		$response = curl_exec($curl);
    		$err = curl_error($curl);
	
		curl_close($curl);
		if ($err) {
        		echo "cURL Error #:" . $err;
    		} else {
    			//echo $response;
        		$resultArr = json_decode($response, true);
        		return $resultArr[ConversionResult][0][to]." ".$resultArr[ConversionResult][0][convertedAmount];
    		}
	} else {
		$a = "";
		$sql="SELECT currency_code FROM currency_data WHERE currency_id='".$shopcurrency."'";
		if($result=mysqli_query($conn,$sql)) {
			if(mysqli_num_rows($result)>0) {
				while($row=mysqli_fetch_array($result)) {
					$a = $row['currency_code']." ".$amount;
				}
			}
		}
		return $a;
	}
}

mysqli_close($conn);
?>