<?php
$file_handle = fopen("menu.txt", "rb");
while (!feof($file_handle)) {
    $line_of_text = fgets($file_handle);
    $appetizers        = explode('=', $line_of_text);
    print $appetizers[0] . $appetizers[1] . "<BR>";
}
fclose($file_handle);
?>