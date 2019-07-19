<?php

namespace BDDObject;

use DB;
use ErrorController as EC;
use SessionController as SC;
use MeekroDBException;

use BDDObject\Evenement;
use BDDObject\User;


class Partage extends Item
{
  protected static $BDDName = "partages";

  ##################################### METHODES STATIQUES #####################################

  protected static function champs()
  {
    return array(
      'idEvenement' => array( 'def' => "", 'type' => 'integer'),  // id de l'événement
      'idRedacteur' => array( 'def' => "", 'type'=> 'integer'),  // id du rédacteur
      );
  }

  public static function deleteList($options = array())
  {
    if (self::SAVE_IN_SESSION) {
      SC::get()->unsetParam("partages");
    }
    require_once BDD_CONFIG;
    try {
      if (isset($options['redacteur'])) {
        DB::delete(PREFIX_BDD."partages", "idRedacteur=%i", $options['redacteur']);
      } elseif (isset($options['evenement'])) {
        DB::delete(PREFIX_BDD."partages", "idEvenement=%i", $options['evenement']);
      }
      return true;
    } catch(MeekroDBException $e) {
      EC::addBDDError($e->getMessage(), "Partage/Suppression liste");
    }
    return false;
  }

  public static function getList($options = array())
  {
    require_once BDD_CONFIG;
    try {
      if (isset($options['redacteur']))
      {
        return DB::query("SELECT p.id, p.idRedacteur, p.idEvenement, u.nom FROM (".PREFIX_BDD."partages p JOIN ".PREFIX_BDD."users u ON p.idRedacteur = u.id) WHERE p.idRedacteur=%i", $options['redacteur']);
      }
      elseif (isset($options['evenement']))
      {
        return DB::query("SELECT p.id, p.idRedacteur, p.idEvenement, u.nom FROM (".PREFIX_BDD."partages p JOIN ".PREFIX_BDD."users u ON p.idRedacteur = u.id) WHERE p.idEvenement=%i", $options['evenement']);
      }
      elseif (isset($options['root']))
      {
        return DB::query("SELECT p.id, p.idRedacteur, p.idEvenement, u.nom FROM (".PREFIX_BDD."partages p JOIN ".PREFIX_BDD."users u ON p.idRedacteur = u.id)");
      }
      else
      {
        return array();
      }

    } catch(MeekroDBException $e) {
      if (DEV) return array('error'=>true, 'message'=>"#Partage/getList : ".$e->getMessage());
      return array('error'=>true, 'message'=>'Erreur BDD');
    }
  }

  ##################################### METHODES #####################################


  public function insert_validation($data=array())
  {
    $errors = array();
    if (!isset($data['idEvenement']))
    {
      $errors['partie'] = "Il faut préciser l'id d'un événement";
    }
    if (!isset($data['idRedacteur']))
    {
      $errors['item'] = "Il faut préciser l'id d'un rédacteur";
    }
    // il faut vérifier l'inexistance d'un couple de valeurs idEvenement / idRedacteur
    require_once BDD_CONFIG;
    try {
      $bdd_result = DB::queryFirstRow("SELECT id FROM ".PREFIX_BDD."partages WHERE idRedacteur=%i AND idEvenement=%i", $data['idRedacteur'], $data['idEvenement']);
    }
    catch(MeekroDBException $e)
    {
      if (DEV) return array('error'=>true, 'message'=>"#Partage/insert_validation : ".$e->getMessage());
      return array('error'=>true, 'message'=>'Erreur BDD');
    }

    if ($bdd_result !== null)
    {
      $errors['partie'] = "Ce rédacteur a déjà une entrée de partage pour cet événement";
    }

    if (count($errors)>0)
      return $errors;
    else
      return true;
  }

  public function getEvenement()
  {
    return Evenement::getObject($this->values['idEvenement']);
  }

  public function getRedacteur()
  {
    return User::getObject($this->values['idRedacteur']);
  }

  public function getIdRedacteur()
  {
    return $this->values['idRedacteur'];
  }

  public function getIdProprietaire()
  {
    $evenement = $this->getEvenement();
    return $evenement->getIdProprietaire();
  }

}

?>
