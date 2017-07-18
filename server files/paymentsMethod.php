<?php
include('db_connect.php');
header('Content-Type: application/json');
$arr_retrieve = array();
$sql="SELECT `Payment_name`, `Payment_logo` FROM `paymentMethods` WHERE `Status`='Enabled'";
$result= mysqli_query($conn,$sql);
if(mysqli_num_rows($result)>0){
	while($row=mysqli_fetch_assoc($result)){
		array_push($arr_retrieve, array(
            "payment_name"=>$row['Payment_name'],  "payment_logo"=>"https://www.imperio.co.id/project/ecommerceApp/AdminPanel/upload/payment_methods/".$row['Payment_logo']
        ));
    }
}else{
	echo "no row or syntax error";
}

echo json_encode(array("payments"=>$arr_retrieve));
mysqli_close($conn);
?>
