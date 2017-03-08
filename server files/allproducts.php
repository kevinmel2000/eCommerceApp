<?php
include('db_connect.php');
header('Content-Type: application/json');

$arr_retrieve = array();

$requestData = "SELECT * FROM productlist";
$result = mysqli_query($conn, $requestData);

if($result){
    while($row=mysqli_fetch_array($result)){
        array_push($arr_retrieve, array(
          "id" => $row['prod_id'],
          "name" => $row['prod_name'],
          "category" => $row['prod_category']
        ));
    }
    echo json_encode(array("prodlist"=>$arr_retrieve)); 
}
mysqli_close($conn);
?>