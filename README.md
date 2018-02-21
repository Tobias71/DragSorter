# Drag and Drop Reorder Images using jQuery, Ajax, PHP & MySQL

Drag and Drop feature makes web page user-friendly and provides a nice User Interface for the web application. jQuery UI provides an easy way to add draggable functionality on DOM element. This tutorial shows you the uses of jQuery drag and drop feature to sort the list elements.
If we want to control the display order of images in the list, image order needs to be stored in the database. In this tutorial, we’ll provide a more interactive way to implement the images reorder functionality. Here we’ll explain how to add jQuery drag and drop feature to rearrange images order and save images display order to the MySQL database. You can use this functionality for managing images gallery, managing users list or any other useful place.
Our example script helps to implement dynamic drag and drop reorder images using jQuery, Ajax, PHP and MySQL. Using our scripts you can also implement the drag and drop reorder list, rows or sorting elements.
Before you begin, take a look at the folder and files structure to build drag and drop reorder images functionality using jQuery, Ajax, PHP and MySQL.

* db.php
* orderUpdate.php
* index.php
* style.css
* images/

## Database Table Creation
To store uploaded images information with display order, a table is required in MySQL database. The following SQL creates images table with some basic required fields in the database.

```
CREATE TABLE `images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `img_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `img_order` int(5) NOT NULL DEFAULT '0',
  `created` datetime NOT NULL,
  `modified` datetime NOT NULL,
  `status` enum('1','0') COLLATE utf8_unicode_ci NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
```

## DB Class (db.php)
The DB class handles all the database related works. Specify your database host ($dbHost), username ($dbUsername), password ($dbPassword), and name ($dbName). The DB class contains two methods to fetch and update images data.
* **getRows()** function fetch the images data from the database.
* **updateOrder()** function updates list order of the images.

```
<?php
class DB{
    //database configuration
    private $dbHost     = "localhost";
    private $dbUsername = "root";
    private $dbPassword = "";
    private $dbName     = "codexworld";
    private $imgTbl     = 'images';
    
    function __construct(){
        if(!isset($this->db)){
            // Connect to the database
            $conn = new mysqli($this->dbHost, $this->dbUsername, $this->dbPassword, $this->dbName);
            if($conn->connect_error){
                die("Failed to connect with MySQL: " . $conn->connect_error);
            }else{
                $this->db = $conn;
            }
        }
    }
    
    function getRows(){
        $query = $this->db->query("SELECT * FROM ".$this->imgTbl." ORDER BY img_order ASC");
        if($query->num_rows > 0){
            while($row = $query->fetch_assoc()){
                $result[] = $row;
            }
        }else{
            $result = FALSE;
        }
        return $result;
    }
    
    function updateOrder($id_array){
        $count = 1;
        foreach ($id_array as $id){
            $update = $this->db->query("UPDATE ".$this->imgTbl." SET img_order = $count WHERE id = $id");
            $count ++;    
        }
        return TRUE;
    }
}
?>
```
## Update Images Order (orderUpdate.php)
The **order_update.php** file receive the current images order from the index.php through Ajax. The images IDs string breaks into array and pass to the DB class to update the images reorder.
```
<?php
//include database class
include_once 'db.php';
$db = new DB();

//get images id and generate ids array
$idArray = explode(",",$_POST['ids']);

//update images order
$db->updateOrder($idArray);
?>
```
## Reorder Images with Drag and Drop (index.php)
The index.php file display the images and allow the user to reorder images by drag and drop.
### JavaScript
Include the jQuery and jQuery UI library.
```
<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.2.4/jquery.min.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.12.1/jquery-ui.min.js"></script>
```
The following jQuery codes are used to enable the jQuery **sortable()** features and implement the drag & drop functionality. When save request is submitted by the user, current images order send to the **orderUpdate.php** file using Ajax for update images order.
```
<script>
$(document).ready(function(){
    $('.reorder_link').on('click',function(){
        $("ul.reorder-photos-list").sortable({ tolerance: 'pointer' });
        $('.reorder_link').html('save reordering');
        $('.reorder_link').attr("id","save_reorder");
        $('#reorder-helper').slideDown('slow');
        $('.image_link').attr("href","javascript:void(0);");
        $('.image_link').css("cursor","move");
        $("#save_reorder").click(function( e ){
            if( !$("#save_reorder i").length ){
                $(this).html('').prepend('<img src="images/refresh-animated.gif"/>');
                $("ul.reorder-photos-list").sortable('destroy');
                $("#reorder-helper").html( "Reordering Photos - This could take a moment. Please don't navigate away from this page." ).removeClass('light_box').addClass('notice notice_error');
    
                var h = [];
                $("ul.reorder-photos-list li").each(function() {  h.push($(this).attr('id').substr(9));  });
                
                $.ajax({
                    type: "POST",
                    url: "orderUpdate.php",
                    data: {ids: " " + h + ""},
                    success: function(){
                        window.location.reload();
                    }
                }); 
                return false;
            }   
            e.preventDefault();     
        });
    });
});
</script>
```
### PHP & HTML
Initially, all the images are listed from the database using PHP and DB class. Once the reorder link is clicked, drag & drop feature is enabled for reorder.
```
<?php
//include database class
include_once 'db.php';
$db = new DB();
?>
<div>
    <a href="javascript:void(0);" class="btn outlined mleft_no reorder_link" id="save_reorder">reorder photos</a>
    <div id="reorder-helper" class="light_box" style="display:none;">1. Drag photos to reorder.<br>2. Click 'Save Reordering' when finished.</div>
    <div class="gallery">
        <ul class="reorder_ul reorder-photos-list">
        <?php 
            //Fetch all images from database
            $images = $db->getRows();
            if(!empty($images)){
                foreach($images as $row){
        ?>
            <li id="image_li_<?php echo $row['id']; ?>" class="ui-sortable-handle"><a href="javascript:void(0);" style="float:none;" class="image_link"><img src="images/<?php echo $row['img_name']; ?>" alt=""></a></li>
        <?php } } ?>
        </ul>
    </div>
</div>
```
### style.css
This file contains some CSS code, which is used to styling the image gallery and links.
```
.reorder_link {
    color: #3675B4;
    border: solid 2px #3675B4;
    border-radius: 3px;
    text-transform: uppercase;
    background: #fff;
    font-size: 18px;
    padding: 10px 20px;
    margin: 15px 15px 15px 0px;
    font-weight: bold;
    text-decoration: none;
    transition: all 0.35s;
    -moz-transition: all 0.35s;
    -webkit-transition: all 0.35s;
    -o-transition: all 0.35s;
    white-space: nowrap;
}
.reorder_link:hover {
    color: #fff;
    border: solid 2px #3675B4;
    background: #3675B4;
    box-shadow: none;
}
#reorder-helper{margin: 18px 10px;padding: 10px;}
.light_box {
    background: #efefef;
    padding: 20px;
    margin: 10px 0;
    text-align: center;
    font-size: 1.2em;
}

.gallery{ width:100%; float:left; margin-top:100px;}
.gallery ul{ margin:0; padding:0; list-style-type:none;}
.gallery ul li{ padding:7px; border:2px solid #ccc; float:left; margin:10px 7px; background:none; width:auto; height:auto;}
.gallery img{ width:250px;}

/* NOTICE */
.notice, .notice a{ color: #fff !important; }
.notice { z-index: 8888; }
.notice a { font-weight: bold; }
.notice_error { background: #E46360; }
.notice_success { background: #657E3F; }
```
