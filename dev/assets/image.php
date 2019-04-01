<?php
require_once "../php/constantes.php";

if(isset($_GET['src'])&&(file_exists(PATH_TO_UPLOAD.$_GET['src'])))
{
    $file = PATH_TO_UPLOAD.$_GET['src'];
}
else
{
    $file = PATH_TO_UPLOAD."inconnu";
}

$size = getimagesize($file);

$fp = fopen($file, 'rb');

if ($size and $fp)
{
    // Optional never cache
//  header('Cache-Control: no-cache, no-store, max-age=0, must-revalidate');
//  header('Expires: Mon, 26 Jul 1997 05:00:00 GMT'); // Date in the past
//  header('Pragma: no-cache');

    // Optional cache if not changed
//  header('Last-Modified: '.gmdate('D, d M Y H:i:s', filemtime($file)).' GMT');

    // Optional send not modified
//  if (isset($_SERVER['HTTP_IF_MODIFIED_SINCE']) and
//      filemtime($file) == strtotime($_SERVER['HTTP_IF_MODIFIED_SINCE']))
//  {
//      header('HTTP/1.1 304 Not Modified');
//  }

    header('Content-Type: '.$size['mime']);
    header('Content-Length: '.filesize($file));

    fpassthru($fp);

    exit;
}

?>
