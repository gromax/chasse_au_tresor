<?php
use ErrorController as EC;
define("DEV",true);

// Pour le dev
// Afficher les erreurs à l'écran
ini_set('display_errors', 1);
// Enregistrer les erreurs dans un fichier de log
ini_set('log_errors', 1);
// Nom du fichier qui enregistre les logs (attention aux droits à l'écriture)
ini_set('error_log', dirname(__file__) . '/log_error_php.txt');
// Afficher les erreurs et les avertissements
error_reporting(E_ALL);

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
