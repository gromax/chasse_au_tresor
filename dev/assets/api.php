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

$router = Router::getInstance();

// session
$router->addRule('api/session', 'session', 'fetch', 'GET'); // Session active
// $router->addRule('api/session/:id', 'session', 'insert', 'PUT'); // reconnexion
// $router->addRule('api/session', 'session', 'insert', 'POST'); // Tentative de connexion
// $router->addRule('api/session/:id', 'session', 'delete', 'DELETE'); // Déconnexion
$router->addRule('api/session/test', 'session', 'logged', 'GET'); // Vérifie l'état de connexion


$response = $router->load();
EC::header(); // Doit être en premier !
if ($response === false) {
	echo json_encode(array("ajaxMessages"=>EC::messages()));
} else {
	if (isset($response["errors"]) && (count($response["errors"])==0)) {
		unset($response["errors"]);
	}
	echo json_encode($response);
}

?>
