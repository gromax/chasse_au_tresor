<?php

namespace BDDObject;

use DB;
use ErrorController as EC;
use SessionController as SC;
use MeekroDBException;
use BDDObject\Partie;
use BDDObject\ItemEvenement;
use BDDObject\Image;

final class Evenement extends Item
{
  protected static $BDDName = "evenements";

  ##################################### METHODES STATIQUES #####################################

  protected static function champs()
  {
    return array(
      'titre' => array( 'def' => "", 'type' => 'string'),  // titre de l'événement
      'idProprietaire' => array( 'def' => 0, 'type'=> 'integer'),  // id du Rédacteur propriétaire
      'description' => array( 'def' => "", 'type'=> 'string'),  // description de l'événement
      'actif' => array( 'def' => true, 'type'=> 'boolean'),  // l'événement est-il actif ?
      'visible' => array( 'def' => true, 'type'=> 'boolean'),  // l'événement est-il visible ?
      'sauveEchecs' => array( 'def' => false, 'type' => 'boolean'),  // faut-il sauvé les essais ratés ?
      'ptsEchecs' => array( 'def'=> 0, 'type' => 'integer'),  // points comptés négativement pour les les essais faux
      'hash' => array( 'def' => true, 'type'=> 'string'),  // clé privée de l'événement ?
      );
  }

  public static function getList($options = array())
  {
    require_once BDD_CONFIG;
    try {
      if (isset($options['redacteur']))
        return DB::query("SELECT e.id, e.titre, e.idProprietaire, r.nom AS nomProprietaire, e.description, e.actif, e.visible, e.sauveEchecs, e.ptsEchecs, e.hash, (SELECT COUNT(p.id) FROM ".PREFIX_BDD."parties p where p.idEvenement = e.id) AS count_parties, (SELECT COUNT(i.id) FROM ".PREFIX_BDD."itemsEvenement i where i.idEvenement = e.id) AS count_items FROM (".PREFIX_BDD."evenements e JOIN ".PREFIX_BDD."redacteurs r ON r.id = e.idProprietaire) WHERE e.idProprietaire=%i", $options['redacteur']);
      elseif (isset($options['joueur']))
        return DB::query("SELECT e.id, e.titre, e.idProprietaire, e.description, e.actif, e.sauveEchecs, e.ptsEchecs, p.id as idPartie, (SELECT COUNT(i.id) FROM ".PREFIX_BDD."itemsEvenement i where i.idEvenement = e.id) AS count_items FROM (".PREFIX_BDD."evenements e LEFT JOIN ".PREFIX_BDD."parties p ON e.id = p.idEvenement AND p.idProprietaire=%i) WHERE e.visible=1", $options['joueur']);
      elseif (isset($options['root']))
        return DB::query("SELECT e.id, e.titre, e.idProprietaire, r.nom AS nomProprietaire, e.description, e.actif, e.visible, e.sauveEchecs, e.ptsEchecs, e.hash, (SELECT COUNT(p.id) FROM ".PREFIX_BDD."parties p where p.idEvenement = e.id) AS count_parties, (SELECT COUNT(i.id) FROM ".PREFIX_BDD."itemsEvenement i where i.idEvenement = e.id) AS count_items FROM (".PREFIX_BDD."evenements e JOIN ".PREFIX_BDD."redacteurs r ON r.id = e.idProprietaire)");
      else
        return array();

    } catch(MeekroDBException $e) {
      if (DEV) return array('error'=>true, 'message'=>"#Evenement/getList : ".$e->getMessage());
      return array('error'=>true, 'message'=>'Erreur BDD');
    }
  }

  public static function deleteList($options = array())
  {
    if (!Partie::deleteList($options) || !ItemEvenement::deleteList($options) || !Image::deleteList($options))
    {
      return false;
    }

    if (self::SAVE_IN_SESSION) {
      SC::get()->unsetParam("evenements");
    }
    require_once BDD_CONFIG;
    try {
      if (isset($options['redacteur'])) {
        DB::delete(PREFIX_BDD."evenements", "idProprietaire=%i", $options['redacteur']);
      }
      return true;
    } catch(MeekroDBException $e) {
      EC::addBDDError($e->getMessage(), "Evenement/Suppression liste");
    }
    return false;
  }

  public static function getWithHash($hash)
  {
    require_once BDD_CONFIG;
    try {
      $bdd_result=DB::queryFirstRow("SELECT * FROM ".PREFIX_BDD.static::$BDDName." WHERE hash=%s AND actif=1", $hash);
      if ($bdd_result === null)
      {
        return null;
      }

      $item = new Evenement($bdd_result);
      return $item;
    } catch(MeekroDBException $e) {
      EC::addBDDError($e->getMessage(),"Evenement/getWithHash");
    }
    return null;
  }

  ##################################### METHODES #####################################

  public function getIdProprietaire()
  {
    return $this->values['idProprietaire'];
  }

  public function customDelete()
  {
    $options = array("evenement"=>$this->id);
    return (Partie::deleteList($options) && ItemEvenement::deleteList($options) && Image::deleteList($options));
  }

}

?>
