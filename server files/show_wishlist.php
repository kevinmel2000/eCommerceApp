<?php
include('db_connect.php');
header('Content-Type: application/json');

$userID = $_REQUEST['userid'];
$arr_retrieve = array();
if (isset($userID)) {
    $sql_wishlist = "SELECT `productWishlist`.`prod_id`, `productDetail`.`prod_name` FROM `productWishlist` JOIN `productDetail` ON `productWishlist`.`prod_id` = `productDetail`.`prod_id` WHERE `productWishlist`.`user_id` = '".$userID."'";
    $result = mysqli_query($conn, $sql_wishlist);
    if ($result) {
        if (mysqli_num_rows($result) != 0) {
            while($row=mysqli_fetch_array($result)){
                array_push($arr_retrieve, array(
                    "query_status" => "Success",
                    "id" => $row['prod_id'],
                    "name" => $row['prod_name']
                )); 
            }
        }
    } else {
        array_push($arr_retrieve, array(
            "query_status" => "Failed",
            "id" => "None",
            "name" => "None"
        ));
    }
} else {
    array_push($arr_retrieve, array(
        "query_status" => "Failed",
        "id" => "None",
        "name" => "None"
    ));
}
echo json_encode(array("wishlist"=>$arr_retrieve)); 
mysqli_close($conn);
?>