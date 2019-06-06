<?php
use ErrorController as EC;
define("DEV",false);

require_once "../php/myFunctions.php";
require_once "../php/constantes.php";

if (file_exists("../php/config/bddConfig.php")) {
  include "../php/routes.php";
  $router = loadRouter();
  $response = $router->load();
} else {
  $response = array("error" => "Le fichier bddConfig.php n'existe pas !");
  EC::set_error_code(422);
}

if ($response === false) {
  $jsonOutput =  json_encode(array("ajaxMessages"=>EC::messages()));
} else {
  if (isset($response["errors"]) && (count($response["errors"])==0)) {
    unset($response["errors"]);
  }
  $errorsMessages = EC::messages();
  if (count($errorsMessages)>0)
  {
    $response['errorsMessages'] = $errorsMessages;
  }
  $jsonOutput = json_encode($response);

  if ($jsonOutput===false)
  {
    EC::set_error_code(501);
    $jsonOutput = json_encode(array("error"=>"Problème encodage json"));
  }
}
EC::header(); // Doit être en premier !
echo $jsonOutput;

?>
