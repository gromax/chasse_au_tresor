<?php

namespace BDDObject;

use DB;
use ErrorController as EC;
use SessionController as SC;
use MeekroDBException;
use BDDObject\Evenement;
use BDDObject\EssaiJoueur;

final class ItemEvenement extends Item
{
  const ITEM_INITIAL = 1;
  const ITEM_FINAL = 2;
  const ITEM_NORMAL = 0;
  protected static $BDDName = "itemsEvenement";

  ##################################### METHODES STATIQUES #####################################

  protected static function champs()
  {
    return array(
      'idEvenement' => array( 'def' => 0, 'type'=> 'integer'),  // id de l'événement lié
      'subItemsData' => array( 'def' => "", 'type'=> 'string'), // données paramétrant cet item
      'tagCle' => array( 'def' => "", 'type'=> 'string'), // étiquette pour la clé
      'regexCle' => array( 'def' => "", 'type'=> 'string'), // regex pour la clé
      'type' => array( 'def' => static::ITEM_NORMAL, 'type' => 'integer'), // type d'item
      'pts' => array( 'def' => 0, 'type' => 'integer') // nombre de points
      );
  }

  public static function deleteList($options = array())
  {
    if (self::SAVE_IN_SESSION) {
      SC::get()->unsetParam("itemsEvenement");
    }
    require_once BDD_CONFIG;
    try {
      if (isset($options['redacteur'])) {
        DB::query("DELETE ".PREFIX_BDD."itemsEvenement FROM (".PREFIX_BDD."itemsEvenement JOIN ".PREFIX_BDD."evenements ON ".PREFIX_BDD."itemsEvenement.idEvenement = ".PREFIX_BDD."evenements.id) WHERE ".PREFIX_BDD."evenements.idProprietaire=%i", $options['redacteur']);
      } elseif (isset($options['evenement'])) {
        DB::delete(PREFIX_BDD."itemsEvenement", "idEvenement=%i", $options['evenement']);
      }
      return true;
    } catch(MeekroDBException $e) {
      EC::addBDDError($e->getMessage(), "ItemEvenement/Suppression liste");
    }
    return false;
  }

  public static function getList($options = array())
  {
    require_once BDD_CONFIG;
    try {
      if (isset($options['redacteur']))
        // rédacteur
        return DB::query("SELECT i.id, i.idEvenement, i.subItemsData, i.tagCle, i.regexCle, i.type, i.pts FROM (".PREFIX_BDD."itemsEvenement i JOIN ".PREFIX_BDD."evenements e ON e.id = i.idEvenement) WHERE e.idProprietaire=%i", $options['redacteur']);
      elseif (isset($options['evenement']))
        return DB::query("SELECT id, idEvenement, subItemsData, tagCle, regexCle, type, pts FROM ".PREFIX_BDD."itemsEvenement WHERE idEvenement=%i", $options['evenement']);
      elseif (isset($options['root']))
        return DB::query("SELECT id, idEvenement, subItemsData, tagCle, regexCle, type, pts FROM ".PREFIX_BDD."itemsEvenement");
      elseif (isset($options['starting']))
      {
        // Cas où on veut les clés des points de départ d'un événement
        return DB::query("SELECT id, tagCle FROM ".PREFIX_BDD."itemsEvenement WHERE idEvenement=%i AND type=".static::ITEM_INITIAL,$options['starting']);
      }
      else
      {
        return array();
      }

    } catch(MeekroDBException $e) {
      if (BDD_DEBUG_ON) return array('error'=>true, 'message'=>"#ItemEvenement/getList : ".$e->getMessage());
      return array('error'=>true, 'message'=>'Erreur BDD');
    }
  }

  public static function tryCle($idEvenement, $cleEssai)
  {
    require_once BDD_CONFIG;
    try
    {
      $list = DB::query("SELECT id, regexCle FROM ".PREFIX_BDD."itemsEvenement WHERE idEvenement=%i",$idEvenement);
      // On teste si la proposition est de type gps
      // attention la lattitude est donnée en premier
      $regexGPS = "/^gps=[0-9]+\.[0-9]+,[0-9]+\.[0-9]+(,[0-9]+)?$/";
      if (preg_match($regexGPS,$cleEssai)==1)
      {
        $ecartMax2 = (GPS_LIMIT/1852)*(GPS_LIMIT/1852);
        // Il faut récupérer les coordonnées
        $arr1 = explode("=",$cleEssai);
        $arrCoordsEssaiStr = explode(",",$arr1[1]);
        $arrCoordsEssai = array("y"=>0+$arrCoordsEssaiStr[0] , "x"=> 0+$arrCoordsEssaiStr[1]);
        foreach ($list as $value) {
          if (preg_match($regexGPS,$value['regexCle'])==1)
          {
            // l'item est une localisation gps
            // on va pouvoir faire une comparaison
            $arr1 = explode("=",$value['regexCle']);
            $arrCoordsItemStr = explode(",",$arr1[1]);
            $arrCoordsItem = array("y"=>0+trim($arrCoordsItemStr[0]) , "x"=> 0+trim($arrCoordsItemStr[1]));
            $ym = ($arrCoordsEssai["y"]+$arrCoordsItem["y"])/2;
            $dx = 60*($arrCoordsEssai["x"]-$arrCoordsItem["x"])*cos($ym*0.01745329251994329577);
            $dy = 60*($arrCoordsEssai["x"]-$arrCoordsItem["x"]);
            $dist2 = ($dx*$dx + $dy*$dy); // en minutes

            if ($dist2<=$ecartMax2) // (GPS_LIMIT / 1852m)²
            {
              // à moins de GPS_LIMIT
              // correspondance trouvée
              return self::getObject($value['id']);
            }

          }
        }
      }
      else
      {
        foreach ($list as $value) {
          $regexCleItem = "/".$value['regexCle']."/i";

          // Il faut vérifier si $value['cle'] match $cle
          // debug: echo "$re ? ".$value['cle']." -> ".preg_match($re,$value['cle'])."<br>";

          if (preg_match($regexCleItem,$cleEssai)==1)
          {
            // correspondance trouvée
            return self::getObject($value['id']);
          }
        }
      }
    }
    catch(MeekroDBException $e)
    {
      EC::addBDDError($e->getMessage(), "ItemEvenement/tryCle");
    }
    return null;
  }

  ##################################### METHODES #####################################

  public function getEvenement()
  {
    return Evenement::getObject($this->values['idEvenement']);
  }

  public function getIdProprietaire()
  {
    $parent = $this->getEvenement();
    if ($parent!=null)
    {
      return $parent->getIdProprietaire();
    }
    else
    {
      return null;
    }
  }

  public function customDelete()
  {
    $options = array("evenement"=>$this->id);
    return (EssaiJoueur::deleteList($options));
  }



}

?>
