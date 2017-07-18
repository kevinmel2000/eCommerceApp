<?php
include('db_connect.php');
header('Content-Type: application/json');

$userID = $_REQUEST['userid'];
$prodname = $_REQUEST['prodname'];
$arr_retrieve = array();
if (isset($userID) && isset($prodname)) {
    $sql_wishlist = "SELECT `productWishlist`.`prod_id` FROM `productWishlist` JOIN `productDetail` ON `productWishlist`.`prod_id` = `productDetail`.`prod_id` WHERE `productWishlist`.`user_id` = '".$userID."' AND `productDetail`.`prod_name`= '".$prodname."'";
    $result = mysqli_query($conn, $sql_wishlist);
    if ($result) {
        if (mysqli_num_rows($result) != 0) {
            array_push($arr_retrieve, array(
                    "result" => "Product is in your wishlist.",
                )); 
        }
    } else {
        array_push($arr_retrieve, array(
                    "result" => "Product is not in your wishlist.",
                )); 
    }
} else {
    array_push($arr_retrieve, array(
        "result" => "please input userID and product name.",
    )); 
}
echo json_encode(array("wishlist"=>$arr_retrieve)); 
mysqli_close($conn);
?>