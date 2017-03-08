<?php
include('db_connect.php');
header('Content-Type: application/json');

$DEST = $_REQUEST['dest'];
$WEIGHTINGRAM = $_REQUEST['weight'];
if($WEIGHTINGRAM < 1000) {
	$WEIGHTINGRAM = 1000;
}

$COURIERCODE = array();
$arr_retrieve = array();
$arr_costArr = array_fill_keys(array('shipper','service','cost','etd'));

$sql_API="SELECT `APIKey`, `courier_code` FROM `shipment_courier` WHERE `Status`='Enabled' AND `Shipper_Name` NOT LIKE '%DSC Delivery%'";
$result_API= mysqli_query($conn,$sql_API);
if(mysqli_num_rows($result_API)>0){
	while($row=mysqli_fetch_assoc($result_API)){
		$APIKEY = $row['APIKey'];
		array_push($COURIERCODE, $row['courier_code']);
        }
}else{
	//echo "no row or syntax error for SELECT query in shipment_courier.";
	array_push($arr_retrieve, array("SQL_Error"=>"no row or syntax error for SELECT query in shipment_courier."));
}

$sql_origin="SELECT `Shop_city` FROM `shop_info`";
$result_origin= mysqli_query($conn, $sql_origin);
if(mysqli_num_rows($result_origin)>0){
	while($row=mysqli_fetch_assoc($result_origin)){
		$ORIGIN = $row['Shop_city'];
        }
}else{
	array_push($arr_retrieve, array("SQL_Error"=>"no row or syntax error for SELECT query in shop_info."));
}


$ORIGINCODE = getCityID($APIKEY, $ORIGIN);
$DESTCODE = getCityID($APIKEY, $DEST);

getCost($ORIGINCODE, $DESTCODE, $WEIGHTINGRAM, $COURIERCODE, $APIKEY, $conn);

function getCost($ORIGINCODE, $DESTCODE, $WEIGHTINGRAM, $COURIERCODE, $APIKEY, $conn){
    foreach($COURIERCODE as $courier){
    	$curl = curl_init();
    	
	curl_setopt_array($curl, array(
        CURLOPT_URL => "http://api.rajaongkir.com/starter/cost",
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_ENCODING => "",
        CURLOPT_MAXREDIRS => 10,
        CURLOPT_TIMEOUT => 30,
        CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
        CURLOPT_CUSTOMREQUEST => "POST",
        CURLOPT_POSTFIELDS => "origin=".$ORIGINCODE."&destination=".$DESTCODE."&weight=".$WEIGHTINGRAM."&courier=".$courier,
        CURLOPT_HTTPHEADER => array(
            "content-type: application/x-www-form-urlencoded",
            "key: ".$APIKEY
        ),
    	));
	
    	$response = curl_exec($curl);
    	$err = curl_error($curl);
	
	curl_close($curl);
	
    	if ($err) {
        	array_push($arr_retrieve, array("cURL_Error"=>$err));
    	} else {
        	$costArr = json_decode($response, true);	
    	}
    	
    	$sql_logo = "SELECT Shipper_Logo FROM shipment_courier WHERE courier_code='".$courier."'";
    	$result = mysqli_query($conn, $sql_logo);
    	if($result){
    		if(mysqli_num_rows($result)>0) {
    			while($row=mysqli_fetch_array($result)) {
    				$arr_costArr['logo'] = "https://www.scbdresearch.com/dscApp/upload/shipper/".$row['Shipper_Logo'];
    			}
    		}
    	}
    	for($h=0; $h<count($costArr[rajaongkir][results]);$h++){
        	for($i=0; $i<count($costArr[rajaongkir][results][$h][costs]); $i++){
        		for($j=0; $j<count($costArr[rajaongkir][results][$h][costs][$i][cost][$j]); $j++){
        			$arr_costArr['shipper']=$costArr[rajaongkir][results][$h][name];
        			$arr_costArr['service']=$costArr[rajaongkir][results][$h][costs][$i][service];
        			$arr_costArr['cost']=$costArr[rajaongkir][results][$h][costs][$i][cost][$j][value];
        			$arr_costArr['etd']=$costArr[rajaongkir][results][$h][costs][$i][cost][$j][etd];
        			$arr_retrieve[count($arr_retrieve)] = $arr_costArr;
        		}
        	}
    	}
    }
    $arr_costArr['logo'] = "https://www.scbdresearch.com/dscApp/upload/shipper/Logo_DSC.png";
    $arr_costArr['shipper']="DSC Delivery";
    $arr_costArr['service']="Local Delivery";
    $arr_costArr['cost']=10000;
    $arr_costArr['etd']="1";
    $arr_retrieve[count($arr_retrieve)] = $arr_costArr;
    echo json_encode(array("ShipperResult"=>$arr_retrieve));
}

function getCityID($APIKEY, $FindCity){
    $curl = curl_init();

    curl_setopt_array($curl, array(
        CURLOPT_URL => "http://rajaongkir.com/api/starter/city",
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_ENCODING => "",
        CURLOPT_MAXREDIRS => 10,
        CURLOPT_TIMEOUT => 30,
        CURLOPT_HTTP_VERSION => CURL_HTTP_VERSION_1_1,
        CURLOPT_CUSTOMREQUEST => "GET",
        CURLOPT_HTTPHEADER => array(
            "key: ".$APIKEY
        ),
    ));

    $response = curl_exec($curl);
    $err = curl_error($curl);

    curl_close($curl);

    if ($err) {
        echo "cURL Error #:" . $err;
    } else {
        $citiesArr = json_decode($response, true);
    }
    
    for($i=0;$i<count($citiesArr[rajaongkir][results]);$i++){
    	if($FindCity == $citiesArr[rajaongkir][results][$i][city_name]){
    		return $citiesArr[rajaongkir][results][$i][city_id];
    	};
    }
}
?>
