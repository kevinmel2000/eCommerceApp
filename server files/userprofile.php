<?php
include('db_connect.php');
header('Content-Type: application/json');

$USERID = $_REQUEST["userid"];
$arr_retrieve = array();
if(isset($USERID)){
    $requestData = "SELECT * FROM user_profile WHERE `user_id` LIKE '".$USERID."'";
    $result = mysqli_query($conn, $requestData);

    if($result){
        if(mysqli_num_rows($result) != 0){
            while($row=mysqli_fetch_array($result)){
                array_push($arr_retrieve, array(
                    "id" => $row['user_id'],
                    "photo" => "https://www.imperio.co.id/project/ecommerceApp/AdminPanel/upload/userphoto/$USERID/".$row['user_photo'],
                    "name" => $row['user_name'],
                    "street" => $row['user_address_street'],
                    "city" => $row['user_address_city'],
                    "province" => $row['user_address_province'],
                    "country" => $row['user_address_country'],
                    "postalcode" => $row['user_address_postalCode'],
                    "mobilephone" => $row['user_mobilePhone'],
                    "email" => $row['user_email']
                )); 
            }   
        } else {
                array_push($arr_retrieve, array(
                    "id" => "None",
                    "photo" => "None",
                    "name" => "None",
                    "street" => "None",
                    "city" => "None",
                    "province" => "None",
                    "country" => "None",
                    "postalcode" => "None",
                    "mobilephone" => "None",
                    "email" => "None"
                ));
        }
    }
} else {
    array_push($arr_retrieve, array(
        "id" => "None",
        "photo" => "None",
        "name" => "None",
        "street" => "None",
        "city" => "None",
        "province" => "None",
        "country" => "None",
        "postalcode" => "None",
        "mobilephone" => "None",
        "email" => "None"
    ));
}
echo json_encode(array("userprof"=>$arr_retrieve)); 

mysqli_close($conn);

?>