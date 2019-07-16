<?php

namespace BDDObject;

use DB;
use ErrorController as EC;
use SessionController as SC;
use MeekroDBException;
use BDDObject\Partie;

final class EssaiJoueur extends Item
{
  protected static $BDDName = "essaisJoueur";

  ##################################### METHODES STATIQUES #####################################

  protected static function champs()
  {
    return array(
      'idPartie' => array( 'def' => 0, 'type'=> 'integer'), // id de la partie liée
      'essai' => array( 'def' => "", 'type'=> 'string'),  // données décrivant la clé
      'data' => array( 'def' => "", 'type'=> 'string'), // données décrivant les éventuelles réponses
      'date' => array( 'def' => "", 'type'=> 'dateHeure'),  // date de création
      'idItem' => array( 'def' => 0, 'type'=> 'integer') // item lié à cet essai
      );
  }

  public static function deleteList($options = array())
  {
    if (self::SAVE_IN_SESSION) {
      SC::get()->unsetParam("essaisJoueur");
    }
    require_once BDD_CONFIG;
    try {
      if (isset($options['redacteur'])) {
        DB::query("DELETE ".PREFIX_BDD."essaisJoueur FROM ((".PREFIX_BDD."essaisJoueur JOIN ".PREFIX_BDD."parties ON ".PREFIX_BDD."essaisJoueur.idPartie = ".PREFIX_BDD."parties.id) JOIN ".PREFIX_BDD."evenements ON ".PREFIX_BDD."parties.idEvenement = ".PREFIX_BDD."evenements.id) WHERE ".PREFIX_BDD."evenements.idProprietaire=%i", $options['redacteur']);
      } elseif (isset($options['joueur'])) {
        DB::query("DELETE ".PREFIX_BDD."essaisJoueur FROM (".PREFIX_BDD."essaisJoueur JOIN ".PREFIX_BDD."parties ON ".PREFIX_BDD."essaisJoueur.idPartie = ".PREFIX_BDD."parties.id) WHERE ".PREFIX_BDD."parties.idProprietaire=%i", $options['joueur']);
      } elseif (isset($options['evenement'])) {
        DB::query("DELETE ".PREFIX_BDD."essaisJoueur FROM (".PREFIX_BDD."essaisJoueur JOIN ".PREFIX_BDD."parties ON ".PREFIX_BDD."essaisJoueur.idPartie = ".PREFIX_BDD."parties.id) WHERE ".PREFIX_BDD."parties.idEvenement=%i", $options['evenement']);
      } elseif (isset($options['itemEvenement'])) {
        DB::delete(PREFIX_BDD."essaisJoueur", 'idItem=%i', $options['itemEvenement']);
      } elseif (isset($options['partie'])) {
        DB::delete(PREFIX_BDD."essaisJoueur", "idPartie=%i", $options['partie']);
      }
      return true;
    } catch(MeekroDBException $e) {
      EC::addBDDError($e->getMessage(), "Partie/Suppression liste");
    }
    return false;
  }

  public static function getList($options = array())
  {
    require_once BDD_CONFIG;
    try {
      if (isset($options['joueur']))
        return DB::query("SELECT c.id, c.idItem, c.essai, c.date FROM (".PREFIX_BDD."essaisJoueur c JOIN ".PREFIX_BDD."parties p ON p.id = c.idPartie) WHERE p.idProprietaire=%i", $options['joueur']);
      elseif (isset($options['redacteur']))
        return DB::query("SELECT c.id, c.idItem, c.essai, c.date, COALESCE(ie.pts,e.ptsEchecs) AS pts, COALESCE(ie.prerequis,'') AS prerequis FROM (((".PREFIX_BDD."essaisJoueur c JOIN ".PREFIX_BDD."parties p ON p.id = c.idPartie) JOIN ".PREFIX_BDD."evenements e ON e.id = p.idEvenement) LEFT JOIN ".PREFIX_BDD."itemsEvenement ie ON ie.id=c.idItem) WHERE e.idProprietaire=%i", $options['redacteur']);
      elseif (isset($options['evenement']))
        return DB::query("SELECT c.id, c.idItem, c.essai, c.date FROM (".PREFIX_BDD."essaisJoueur c JOIN ".PREFIX_BDD."parties p ON p.id = c.idPartie) WHERE p.idEvenement=%i", $options['evenement']);
      elseif (isset($options['partie']))
      {
        $arrOut = DB::query("SELECT c.id, c.idPartie, c.idItem, c.essai, date, COALESCE(i.tagCle, '') AS tagCle , COALESCE(i.pts,e.ptsEchecs) AS pts, COALESCE(i.prerequis, '') AS prerequis FROM (((".PREFIX_BDD."essaisJoueur c JOIN ".PREFIX_BDD."parties p ON c.idPartie = p.id) JOIN ".PREFIX_BDD."evenements e ON p.idEvenement = e.id) LEFT JOIN ".PREFIX_BDD."itemsEvenement i ON i.id=c.idItem ) WHERE c.idPartie=%i", $options['partie']);
        if (isset($options['markFinished']))
        {
          $suites = $options['markFinished'];
          $founds = array_column($arrOut,"idItem");
          foreach ($arrOut as $key=>$essai) {
              $idItem = $essai["idItem"];
              if ($idItem!="-1")
              {
                  if (isset($suites[$idItem]))
                  {
                    $suite = $suites[$idItem];
                  }
                  else
                  {
                    $suite = "";
                  }
                  if ($suite=="$")
                  {
                      $arrOut[$key]["fini"]=1;
                  }
                  elseif ($suite!=="")
                  {
                      $arrSuite = explode(";",$suite);
                      foreach ($arrSuite as $itSuite) {
                          if (!in_array($itSuite,$founds))
                          {
                              $arrOut[$key]["fini"]=0;
                              break;
                          }
                      }
                      if (!isset($arrOut[$key]["fini"]))
                      {
                          $arrOut[$key]["fini"]=1;
                      }
                  }
                  else
                  {
                      $arrOut[$key]["fini"]=0;
                  }
              }
          }
        }
        return $arrOut;
      }
      elseif (isset($options['root']))
        return DB::query("SELECT id, essai, date FROM ".PREFIX_BDD."essaisJoueur");
      else
        return array();

    } catch(MeekroDBException $e) {
      if (DEV) return array('error'=>true, 'message'=>"#EssaiJoueur/getList : ".$e->getMessage());
      return array('error'=>true, 'message'=>'Erreur BDD');
    }
  }

  public static function getOkCount($idPartie)
  {
    require_once BDD_CONFIG;
    try {
      $bddResult = DB::query("SELECT COUNT(*) AS cnt FROM ((".PREFIX_BDD."essaisJoueur c JOIN ".PREFIX_BDD."parties p ON c.idPartie = p.id) JOIN ".PREFIX_BDD."evenements e ON p.idEvenement = e.id) WHERE c.idPartie=%i AND c.idItem >=0", $idPartie);
      return (integer) $bddResult[0]["cnt"];
    } catch(MeekroDBException $e) {
      if (DEV) return array('error'=>true, 'message'=>"#EssaiJoueur/getOkCount : ".$e->getMessage());
      return null;
    }
  }

  ##################################### METHODES #####################################

  public function insert_validation($data=array())
  {
    $errors = array();
    if (!isset($data['idPartie']))
    {
      $errors['partie'] = "Il faut préciser l'id d'un propriétaire";
    }
    if (!isset($data['idItem']))
    {
      $errors['item'] = "Il faut préciser l'id d'un item";
    }
    if ($data['idItem']!=-1)
    {
      // il faut vérifier l'inexistance d'un couple de valeurs idPartie / idItem
      require_once BDD_CONFIG;
      try {
        $bdd_result = DB::queryFirstRow("SELECT id FROM ".PREFIX_BDD."essaisJoueur WHERE idPartie=%i AND idItem=%i", $data['idPartie'], $data['idItem']);
      }
      catch(MeekroDBException $e)
      {
        if (DEV) return array('error'=>true, 'message'=>"#EssaiJoueur/insert_validation : ".$e->getMessage());
        return array('error'=>true, 'message'=>'Erreur BDD');
      }

      if ($bdd_result !== null)
      {
        $errors['partie'] = "Cette partie a déjà une partie clé liée à cet item";
      }
    } else {
      // il faut vérifier l'inexistance d'un couple de valeurs idPartie / essai
      require_once BDD_CONFIG;
      try {
        $bdd_result = DB::queryFirstRow("SELECT id FROM ".PREFIX_BDD."essaisJoueur WHERE idPartie=%i AND essai=%s", $data['idPartie'], $data['essai']);
      }
      catch(MeekroDBException $e)
      {
        if (DEV) return array('error'=>true, 'message'=>"#EssaiJoueur/insert_validation : ".$e->getMessage());
        return array('error'=>true, 'message'=>'Erreur BDD');
      }

      if ($bdd_result !== null)
      {
        $errors['partie'] = "Cette partie a déjà une partie clé liée à cet item";
      }
    }

    if (count($errors)>0)
      return $errors;
    else
      return true;
  }

  public function getPartie()
  {
    return Partie::getObject($this->values['idPartie']);
  }

}

?>
