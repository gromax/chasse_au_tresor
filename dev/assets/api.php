<?php
use ErrorController as EC;

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
require "../php/class/Router.php";

if (file_exists("../php/config/bddConfig.php")) {
  $router = Router::getInstance();

  // session
  $router->addRule('api/session', 'session', 'fetch', 'GET'); // Session active
  $router->addRule('api/session/:id', 'session', 'insert', 'PUT'); // reconnexion
  $router->addRule('api/session', 'session', 'insert', 'POST'); // Tentative de connexion
  $router->addRule('api/session/:id', 'session', 'delete', 'DELETE'); // Déconnexion
  $router->addRule('api/session/test', 'session', 'logged', 'GET'); // Vérifie l'état de connexion

  // redacteurs
  $router->addRule('api/redacteurs/:id', 'redacteurs', 'fetch', 'GET');
  $router->addRule('api/redacteurs/:id', 'redacteurs', 'delete', 'DELETE');
  $router->addRule('api/redacteurs/:id', 'redacteurs', 'update', 'PUT');
  $router->addRule('api/redacteurs', 'redacteurs', 'insert', 'POST');

  // redacteurs
  $router->addRule('api/joueurs/:id', 'joueurs', 'fetch', 'GET');
  $router->addRule('api/joueurs/:id', 'joueurs', 'delete', 'DELETE');
  $router->addRule('api/joueurs/:id', 'joueurs', 'update', 'PUT');
  $router->addRule('api/joueurs', 'joueurs', 'insert', 'POST');

  // evenements
  $router->addRule('api/evenements/:id', 'evenements', 'fetch', 'GET');
  $router->addRule('api/evenements/:id', 'evenements', 'delete', 'DELETE');
  $router->addRule('api/evenements/:id', 'evenements', 'update', 'PUT');
  $router->addRule('api/evenements', 'evenements', 'insert', 'POST');

  // evenements
  $router->addRule('api/itemsEvenement/:id', 'itemsEvenement', 'fetch', 'GET');
  $router->addRule('api/itemsEvenement/:id', 'itemsEvenement', 'delete', 'DELETE');
  $router->addRule('api/itemsEvenement/:id', 'itemsEvenement', 'update', 'PUT');
  $router->addRule('api/itemsEvenement', 'itemsEvenement', 'insert', 'POST');

  // images
  $router->addRule('api/images/:id', 'images', 'fetch', 'GET');
  $router->addRule('api/images/:id', 'images', 'delete', 'DELETE');
  $router->addRule('api/images', 'images', 'insert', 'POST');

  // parties
  $router->addRule('api/parties/:id', 'parties', 'fetch', 'GET');
  $router->addRule('api/parties/:id', 'parties', 'delete', 'DELETE');
  $router->addRule('api/parties', 'parties', 'insert', 'POST');


  // data
  $router->addRule('api/customData/:asks', 'data', 'customFetch', 'GET');
  $router->addRule('api/customData/partie/:id', 'data', 'partieFetch', 'GET');
  $router->addRule('api/event/hash/:hash', 'data', 'getPartieWithHash', 'GET');

  // forgotten
  $router->addRule('api/redacteur/forgotten', 'redacteurs', 'forgottenWithEmail', 'POST');
  $router->addRule('api/redacteur/forgotten/:hash', 'session', 'getRedacteurSessionWithHash', 'GET');
  $router->addRule('api/joueur/forgotten', 'joueurs', 'forgottenWithEmail', 'POST');
  $router->addRule('api/joueur/forgotten/:hash', 'session', 'getRedacteurSessionWithHash', 'GET');


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
