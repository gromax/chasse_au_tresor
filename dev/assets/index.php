<?php
include "../php/constantes.php";

// Pour le dev
// Afficher les erreurs à l'écran
ini_set('display_errors', 1);
// Enregistrer les erreurs dans un fichier de log
ini_set('log_errors', 1);
// Nom du fichier qui enregistre les logs (attention aux droits à l'écriture)
ini_set('error_log', dirname(__file__) . '/log_error_php.txt');
// Afficher les erreurs et les avertissements
error_reporting(E_ALL);

?>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
  <meta name="viewport" content="user-scalable=no, initial-scale=1, maximum-scale=1, minimum-scale=1, width=device-width, height=device-height, target-densitydpi=device-dpi" />
  <title><%= htmlWebpackPlugin.options.title %></title>
</head>
<body>
  <div id="app-container">
    <div id="header-region"></div><br />
    <div id="message-region"></div>
    <div id="main-region" class="container">
        <div class="alert alert-warning" role="alert"> <i class="fa fa-spinner fa-spin fa-2x fa-fw"></i> Contenu en cours de chargement...</div>
    </div>
    <div id="dialog-region"></div>
  </div>
  <script type="text/javascript">
  // Mon code Javascript
  const GPS_LIMIT = <?php echo GPS_LIMIT;?>;
  </script>

</body>
</html>
