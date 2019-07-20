<?php

namespace BDDObject;

use DB;
use ErrorController as EC;
use SessionController as SC;
use MeekroDBException;

class Joueur extends User
{
  ##################################### METHODES STATIQUES #####################################

  public static function getList($options = array())
  {
    require_once BDD_CONFIG;
    try {
      if (isset($options['root']))
        return DB::query("SELECT j.id, j.nom, j.username, (SELECT COUNT(p.id) FROM ".PREFIX_BDD."parties p where p.idProprietaire = j.id) AS count_parties, 0 AS isredac FROM ".PREFIX_BDD."users j WHERE j.isredac=0");
      else
        return array();
    } catch(MeekroDBException $e) {
      if (DEV) return array('error'=>true, 'message'=>"#User/getList : ".$e->getMessage());
      return array('error'=>true, 'message'=>'Erreur BDD');
    }
  }

  ##################################### METHODES #####################################

}

?>
