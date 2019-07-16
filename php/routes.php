<?php
require "../php/class/Router.php";

function loadRouter()
{
  $router = Router::getInstance();

  // session
  $router->addRule('api/session', 'session', 'fetch', 'GET'); // Session active
  $router->addRule('api/session/:id', 'session', 'insert', 'PUT'); // reconnexion
  $router->addRule('api/session', 'session', 'insert', 'POST'); // Tentative de connexion
  $router->addRule('api/session/:id', 'session', 'delete', 'DELETE'); // Déconnexion
  $router->addRule('api/session/test', 'session', 'logged', 'GET'); // Vérifie l'état de connexion

  // redacteurs
  $router->addRule('api/redacteurs/:id', 'users', 'fetch', 'GET');
  $router->addRule('api/redacteurs/:id', 'redacteurs', 'delete', 'DELETE');
  $router->addRule('api/redacteurs/:id', 'redacteurs', 'update', 'PUT');
  $router->addRule('api/redacteurs', 'redacteurs', 'insert', 'POST');

  // joueurs
  $router->addRule('api/joueurs/:id', 'users', 'fetch', 'GET');
  $router->addRule('api/joueurs/:id', 'joueurs', 'delete', 'DELETE');
  $router->addRule('api/joueurs/:id', 'joueurs', 'update', 'PUT');
  $router->addRule('api/joueurs', 'joueurs', 'insert', 'POST');

  // evenements
  $router->addRule('api/evenements/:id', 'evenements', 'fetch', 'GET');
  $router->addRule('api/evenements/:id', 'evenements', 'delete', 'DELETE');
  $router->addRule('api/evenements/:id', 'evenements', 'update', 'PUT');
  $router->addRule('api/evenements', 'evenements', 'insert', 'POST');
  $router->addRule('api/event/hash/:hash', 'evenements', 'getEventWithHash', 'GET');

  // itemEvenements
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
  $router->addRule('api/essaisJoueur/:id', 'essaisJoueur', 'delete', 'DELETE');
  $router->addRule('api/essaisJoueur/count/:id', 'essaisJoueur', 'getCount', 'GET');


  // data
  $router->addRule('api/customData/:asks', 'data', 'customFetch', 'GET');
  $router->addRule('api/customData/partie/:id', 'data', 'partieFetch', 'GET');
  $router->addRule('api/customData/essais/:id', 'data', 'getEssaisFromPartie', 'GET');

  // forgotten
  $router->addRule('api/user/forgotten', 'users', 'forgottenWithEmail', 'POST');
  $router->addRule('api/user/forgotten/:hash', 'session', 'getUserSessionWithHash', 'GET');
  return $router;
}

?>
