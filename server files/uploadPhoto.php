<?php

include('db_connect.php');
header('Content-Type: text/html');

$userId = $_POST["userId"];
$arr_retrieve = array();

if (isset($_FILES["file"])) {
    $filename = basename($_FILES['file']['name']);
    $filedir = dirname(__FILE__).'/AdminPanel/upload/userphoto/'.$userId."/";
    if (!file_exists($filedir)){
        mkdir($filedir, 0777, true);
    }
    $newname = $filedir.$filename;
    $imageFileType = pathinfo($newname,PATHINFO_EXTENSION);
    if($imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg" && $imageFileType != "gif" ) {
        echo "Sorry, only JPG, JPEG, PNG & GIF files are allowed.";
    } else {
        if (move_uploaded_file($_FILES["file"]["tmp_name"], $newname)) {
            $StrNewname = (string)$newname;
            $properURL = str_replace("/home/imperio/public_html/","https://www.imperio.co.id/",$StrNewname);
            $sql_update = "UPDATE `user_profile` SET `user_photo`='".$properURL."' WHERE `user_id` = '".$userId."'";
            if(mysqli_query($conn, $sql_update)){
                //echo "User profile is updated.";
                echo $properURL;
            }
        } else {
            echo "File is not uploaded.";
        }
    }
} else {
    echo "File is not sent to server.";
}
mysqli_close($conn);

?>