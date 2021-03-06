<?php
require_once "../php/constantes.php";

if (isset($_GET['ext'])&&($_GET['ext']=="pdf"))
{
  if(isset($_GET['src'])&&($_GET['src']!="")&&(file_exists(PATH_TO_UPLOAD.$_GET['src'])))
  {
    $file = PATH_TO_UPLOAD.$_GET['src'];
  } else {
    exit;
  }

  header('Content-type: application/pdf');
  header('Content-Disposition: inline; filename="fichier.pdf"');
  header('Content-Transfer-Encoding: binary');
  header('Content-Length: ' . filesize($file));
  header('Accept-Ranges: bytes');
  @readfile($file);
  exit;
}

if(isset($_GET['src'])&&($_GET['src']!="")&&(file_exists(PATH_TO_UPLOAD.$_GET['src'])))
{
    $file = PATH_TO_UPLOAD.$_GET['src'];
}
else
{
    $file = PATH_TO_UPLOAD."inconnu.png";
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
