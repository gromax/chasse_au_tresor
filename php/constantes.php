<?php
  define("PATH_TO_MEEKRODB", "../vendor/sergeytsalkov/meekrodb/db.class.php");
  define("PATH_TO_UPLOAD", "../up/");
  define("PATH_TO_CLASS", "../php/class");

  // Chemin du dossier
  define("BDD_CONFIG","../php/config/bddConfig.php");
  if (file_exists("../php/config/rootConfig.php")) {
  	require_once("../php/config/rootConfig.php");
  } else {
  	require_once("../php/config/rootConfigDef.php");
  }

  // GPS
  define("GPS_LIMIT", 50);

  // Utilisateurs
  define("PSEUDO_MIN_SIZE", 6);
  define("PSEUDO_MAX_SIZE", 20);

  // mails
  define("PSEUDO_FROM","jeu.goupill.fr");
  define("EMAIL_FROM","jeu@goupill.fr");
  define("PATH_TO_SITE","https://jeu.goupill.fr");
  define("NOM_SITE","Chasse au trésor sur goupill.fr");
  define("SMTP_PASSWORD","zwdHpjudYfv3CbEbt8Aa");
  define("SMTP_USER","jeu@goupill.fr");
  define("SMTP_HOST","mail.goupill.fr");
  define("SMTP_PORT",465);

  // debug
  define("DEBUG",true);
  define("DEBUG_TEMPLATES",true);
  define("BDD_DEBUG_ON",true);



?>
