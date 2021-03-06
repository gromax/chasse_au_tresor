<?php
  define("PATH_TO_MEEKRODB", "../vendor/sergeytsalkov/meekrodb/db.class.php");
  define("PATH_TO_UPLOAD", "../up/");
  define("PATH_TO_CLASS", "../php/class");

  // Chemin du dossier
  define("BDD_CONFIG","../php/config/bddConfig.php");
  if (file_exists("../php/config/rootConfig.php")) {
  	require_once("../php/config/rootConfig.php");
  } else {
  	require_once("../php/configDef/rootConfig.php");
  }

  if (file_exists("../php/config/mailConfig.php"))
  {
    require_once("../php/config/mailConfig.php");
  }
  else
  {
    require_once("../php/configDef/mailConfig.php");
  }

  // GPS
  define("GPS_LIMIT", 40);

  // Utilisateurs
  define("PSEUDO_MIN_SIZE", 6);
  define("PSEUDO_MAX_SIZE", 20);

  // hashs
  define("USER_PWD_LOST",1);


?>
