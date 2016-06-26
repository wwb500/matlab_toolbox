<?php

error_reporting(E_ALL);

$config = @$_GET['config'];
$feat = @$_GET['feat'];

$file = fopen("config.txt", "w");
fwrite($file, $config);
fclose($file);

//system("D:\\Git\\houle\\dev\\tools\\ALC\\alc.exe -d data.$feat -c config.txt -o result");

//readfile("result.all.json");

?>
