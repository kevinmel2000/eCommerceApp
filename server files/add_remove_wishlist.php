<?php
include('db_connect.php');
header('Content-Type: text/html');

$userID = $_REQUEST['userid'];
$prodID = $_REQUEST['prodid'];
$status = $_REQUEST['wishlist_status']; //add or delete

if (isset($userID) && isset($prodID)){
    if($status == "add") {
        $sql_cek = "SELECT * FROM `productWishlist` WHERE `user_id`='".$userID."' AND `prod_id`='".$prodID."'";
        $result = mysqli_query($conn, $sql_cek);
        if($result) {
            if (mysqli_num_rows($result) > 0) {
                echo "The product is already in your wishlist.";
            } else {
                $sql_add = "INSERT INTO `productWishlist`(`user_id`, `prod_id`) VALUES ('".$userID."','".$prodID."')";
                if(mysqli_query($conn, $sql_add)) {
                    echo "The product has been added to your wishlist.";
                } else {
                    echo "Unable to add product to your wishlist.";
                }
            }
        } else {
            echo "Something wrong with the server.";
        }
    } else if ($status == "delete") {
        $sql_remove = "DELETE FROM `productWishlist` WHERE `user_id`='".$userID."' AND `prod_id`='".$prodID."'";
        if (mysqli_query($conn, $sql_remove)) {
            echo "The product has been removed from your wishlist.";
        } else {
            echo "Something wrong with the server.";
        }
    } else {
        echo "Product status is unclear.";
    }
} else {
    echo "No product to add.";
}
mysqli_close($conn);
?>