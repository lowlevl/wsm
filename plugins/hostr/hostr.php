<?php
/* 
 * This file is part of hostr manager project,
 * so he is liscenced as GNU GPLv3, read about it
 * here : http://choosealicense.com/licenses/gpl-3.0/
 */
 
function hostr_config() {
    $configarray = array(
    "name" => "hostr",
    "description" => "",
    "version" => "1.0",
    "author" => "TheCake",
    "fields" => array(
        "exec" => array ("FriendlyName" => "Executable path", "Type" => "text", "Size" => "30",
                              "Description" => "Textbox", "Default" => "/etc/hostbox/hostbox", ),
    ));
    return $configarray;
}

add_hook('ServerAdd', 1, function ($data) 
{
    
});
?>