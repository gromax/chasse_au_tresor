<?php

namespace BDDObject;

use DB;
use ErrorController as EC;
use SessionController as SC;
use MeekroDBException;

use BDDObject\EssaiJoueur;
use BDDObject\Evenement;

final class Partie extends Item
{
  protected static $BDDName = "parties";

  ##################################### METHODES STATIQUES #####################################

  protected static function champs()
  {
    return array(
      'idEvenement' => array( 'def' => 0, 'type' => 'integer'),  // id de l'événement lié
      'idProprietaire' => array( 'def' => 0, 'type'=> 'integer'),  // id du Joueur propriétaire
      'dateDebut' => array( 'def' => "", 'type'=> 'dateHeure'),  // date de création de la partie
      );
  }

  public static function deleteList($options = array())
  {
    if (!EssaiJoueur::deleteList($options))
    {
      return false;
    }

    if (self::SAVE_IN_SESSION) {
      SC::get()->unsetParam("parties");
    }
    require_once BDD_CONFIG;
    try {
      if (isset($options['redacteur'])) {
        DB::query("DELETE ".PREFIX_BDD."parties FROM (".PREFIX_BDD."parties JOIN ".PREFIX_BDD."evenements ON ".PREFIX_BDD."parties.idEvenement = ".PREFIX_BDD."evenements.id) WHERE ".PREFIX_BDD."evenements.id=%i", $options['redacteur']);
      } elseif (isset($options['joueur'])) {
        DB::delete(PREFIX_BDD."parties", "idProprietaire=%i", $options['joueur']);
      } elseif (isset($options['evenement'])) {
        DB::delete(PREFIX_BDD."parties", "idEvenement=%i", $options['evenement']);
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
      {
        return DB::query("SELECT p.id, p.idEvenement, e.titre AS titreEvenement, e.description AS descriptionEvenement, p.idProprietaire, p.dateDebut, e.actif FROM (".PREFIX_BDD."parties p JOIN ".PREFIX_BDD."evenements e ON e.id=p.idEvenement) WHERE p.idProprietaire=%i", $options['joueur']);
      }
      elseif (isset($options['redacteur']))
      {
        $idRedacteur = $options['redacteur'];
        return DB::query("SELECT p.id, p.idEvenement, e.titre AS titreEvenement, p.idProprietaire, j.nom AS nomProprietaire, p.dateDebut, MAX(essai.date) AS dateFin, SUM(COALESCE(ie.pts,e.ptsEchecs)) AS score, e.actif, (NOT s.id IS NULL) AS isshare FROM (((((".PREFIX_BDD."parties p JOIN ".PREFIX_BDD."users j ON j.id=p.idProprietaire) JOIN ".PREFIX_BDD."evenements e ON e.id=p.idEvenement) LEFT JOIN ".PREFIX_BDD."essaisJoueur essai ON essai.idPartie=p.id) LEFT JOIN ".PREFIX_BDD."itemsEvenement ie ON ie.id=essai.idItem) LEFT JOIN ".PREFIX_BDD."partages s ON s.idEvenement=p.idEvenement AND s.idRedacteur=%i) WHERE e.idProprietaire=%i or NOT s.id IS NULL GROUP BY p.id", $idRedacteur, $idRedacteur);
      }
      elseif (isset($options['evenement']))
      {
        return DB::query("SELECT p.id, p.idEvenement, e.titre AS titreEvenement, p.idProprietaire, j.nom AS nomProprietaire, p.dateDebut, p.dateFin, p.fini, e.actif FROM ((".PREFIX_BDD."parties p JOIN ".PREFIX_BDD."users j ON j.id=p.idProprietaire) JOIN ".PREFIX_BDD."evenements e ON e.id=p.idEvenement) WHERE e.id=%i", $options['evenement']);
      }
      elseif (isset($options['root']))
      {
        return DB::query("SELECT p.id, p.idEvenement, e.titre AS titreEvenement, p.idProprietaire, j.nom AS nomProprietaire, p.dateDebut, e.actif FROM ((".PREFIX_BDD."parties p JOIN ".PREFIX_BDD."users j ON j.id=p.idProprietaire) JOIN ".PREFIX_BDD."evenements e ON e.id=p.idEvenement)");
      }
      else
      {
        return array();
      }

    } catch(MeekroDBException $e) {
      if (DEV) return array('error'=>true, 'message'=>"#Partie/getList : ".$e->getMessage());
      return array('error'=>true, 'message'=>'Erreur BDD');
    }
  }

  public static function getLinkedWithEvenementEtJoueur($idEvenement, $idJoueur)
  {
    require_once BDD_CONFIG;
    try {
      $bdd_result = DB::queryFirstRow("SELECT * FROM ".PREFIX_BDD."parties WHERE idEvenement=%i AND idProprietaire=%i", $idEvenement, $idJoueur);
      if ($bdd_result!==null){
        return new Partie($bdd_result);
      }
    }
    catch(MeekroDBException $e)
    {
      if (DEV) return array('error'=>true, 'message'=>"#Partie/getLinkedWithEvenementEtJoueur : ".$e->getMessage());
    }
    return null;
  }

  ##################################### METHODES #####################################

  public function getIdProprietaire()
  {
    return $this->values['idProprietaire'];
  }

  public function getEvenement()
  {
    return Evenement::getObject($this->values['idEvenement']);
  }

  public function customDelete()
  {
    $options = array("partie"=>$this->id);
    return EssaiJoueur::deleteList($options);
  }

  public function insert_validation($data=array())
  {
    $errors = array();

    if (!isset($data['idEvenement']))
    {
      $errors['evenement'] = "Il faut préciser l'id d'un événement";
    }
    else
    {
      $idE = (integer) $data['idEvenement'];
      $evenement = Evenement::getObject($idE);
      if ($evenement===null)
      {
        $errors['evenement'] = "L'événement n'existe pas";
      }
      elseif (!$evenement->isActif())
      {
        $errors['evenement'] = "L'événement doit être actif";
      }
    }

    if (!isset($data['idProprietaire']))
    {
      $errors['proprietaire'] = "Il faut préciser l'id d'un propriétaire";
    }
    // il faut vérifier l'inexistance d'un couple de valeurs
    require_once BDD_CONFIG;
    try {
      $bdd_result = DB::queryFirstRow("SELECT id FROM ".PREFIX_BDD."parties WHERE idEvenement=%i AND idProprietaire=%i", $data['idEvenement'], $data['idProprietaire']);
    }
    catch(MeekroDBException $e)
    {
      if (DEV) return array('error'=>true, 'message'=>"#Partie/insert_validation : ".$e->getMessage());
      return array('error'=>true, 'message'=>'Erreur BDD');
    }
    if ($bdd_result !== null)
    {
      $errors['evenement'] = "Ce joueur a déjà une partie liée à cet événement";
    }

    if (count($errors)>0)
      return $errors;
    else
      return true;
  }

  public function parseBeforeUpdate($modifs=array())
  {
    if ($this->id!==null)
    {
      return array();
    }
    else
    {
      $modifs["dateDebut"] = date("Y-m-d H:i:s");
      return array_intersect_key($modifs, array("idEvenement"=>true, "idProprietaire"=>true, "dateDebut"=>true));
    }
  }

}

?>
