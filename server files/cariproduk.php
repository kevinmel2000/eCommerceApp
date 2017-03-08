<?php
include('db_connect.php');
header('Content-Type: application/json');
$CARI = $_REQUEST["cari"];
$arr_retrieve = array();
if(isset($CARI)){
    $cariLC = strtolower($CARI);
    $requestData = "SELECT * FROM productlist WHERE (`prod_name` LIKE '%".$cariLC."%')";
    $result = mysqli_query($conn, $requestData);

    if($result){
        if(mysqli_num_rows($result) != 0){
            while($row=mysqli_fetch_array($result)){
                array_push($arr_retrieve, array(
                    "id" => $row['prod_id'],
                    "name" => $row['prod_name'],
                    "category" => $row['prod_category']
                )); 
            }   
        } else {
                array_push($arr_retrieve, array(
                    "id" => "0",
                    "name" => "Not found",
                    "category" => "None"
                ));
        }
    }
} else {
    array_push($arr_retrieve, array(
        "id" => "0",
        "name" => "Your search format is incorrect",
        "category" => "None"
    ));
}
echo json_encode(array("HasilPencarian"=>$arr_retrieve)); 
mysqli_close($conn);
?>