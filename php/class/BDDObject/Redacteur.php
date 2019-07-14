<?php

namespace BDDObject;

use DB;
use ErrorController as EC;
use SessionController as SC;
use MeekroDBException;

class Redacteur extends User
{
  public static function getList($options = array())
  {
    require_once BDD_CONFIG;
    try {
      if (isset($options['root']))
        return DB::query("SELECT r.id, r.nom, r.username, (SELECT COUNT(e.id) FROM ".PREFIX_BDD."evenements e where e.idProprietaire = r.id) AS count_evenements FROM ".PREFIX_BDD."users r WHERE r.isredac=1");
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
