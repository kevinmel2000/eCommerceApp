<?php
include('db_connect.php');

$arr_retrieve = array();
header('Content-Type: application/json');
$requestData = "SELECT * FROM promoBanners WHERE Status = 'Enabled' AND start_date < CURDATE() < end_date";
$result = mysqli_query($conn, $requestData);

if($result){
    while($row=mysqli_fetch_array($result)){
        array_push($arr_retrieve, array(
          "id" => $row['promo_id'],
          "banner" => "https://www.imperio.co.id/project/ecommerceApp/AdminPanel/upload/promotions/".$row['promo_banner'],
          "text" => $row['promo_text']
        ));
    }
} else {
	array_push($arr_retrieve, array(
          "id" => 0,
          "banner" => "None. Query error.",
          "text" => "None. Query error."
        ));
}

echo json_encode(array("PromoBanners"=>$arr_retrieve));
mysqli_close($conn);
?>