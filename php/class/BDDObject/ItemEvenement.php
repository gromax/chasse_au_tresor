<?php

namespace BDDObject;

use DB;
use ErrorController as EC;
use SessionController as SC;
use MeekroDBException;
use BDDObject\Evenement;
use BDDObject\ClePartie;

final class ItemEvenement extends Item
{
	const	ITEM_INITIAL = 1;
	const	ITEM_FINAL = 2;
	const	ITEM_NORMAL = 0;
	protected static $BDDName = "itemsEvenement";

	##################################### METHODES STATIQUES #####################################

	protected static function champs()
	{
		return array(
			'idEvenement' => array( 'def' => 0, 'type'=> 'integer'),	// id de l'événement lié
			'subItemsData' => array( 'def' => "", 'type'=> 'string'),	// données paramétrant cet item
			'cle' => array( 'def' => "", 'type'=> 'string'), // mots clé pour entrer
			'type' => array( 'def' => static::ITEM_NORMAL, 'type' => 'integer') // type d'item
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
				return DB::query("SELECT i.id, i.idEvenement, i.subItemsData, i.cle, i.type FROM (".PREFIX_BDD."itemsEvenement i JOIN ".PREFIX_BDD."evenements e ON e.id = i.idEvenement) WHERE e.idProprietaire=%i", $options['redacteur']);
			elseif (isset($options['evenement']))
				return DB::query("SELECT id, idEvenement, subItemsData, cle, type FROM ".PREFIX_BDD."itemsEvenement WHERE idEvenement=%i", $options['evenement']);
			elseif (isset($options['root']))
				return DB::query("SELECT id, idEvenement, subItemsData, cle, type FROM ".PREFIX_BDD."itemsEvenement");
			elseif (isset($options['starting']))
			{
				// Cas où on veut les clés des points de départ d'un événement
				return DB::query("SELECT id, cle FROM ".PREFIX_BDD."itemsEvenement WHERE idEvenement=%i AND type=".static::ITEM_INITIAL,$options['starting']);
			}
			else
				return array();

		} catch(MeekroDBException $e) {
			if (BDD_DEBUG_ON) return array('error'=>true, 'message'=>"#ItemEvenement/getList : ".$e->getMessage());
			return array('error'=>true, 'message'=>'Erreur BDD');
		}
	}

	public static function tryCle($idEvenement, $cle)
	{
		require_once BDD_CONFIG;
		$re = "/".$cle."/i";
		try
		{
			$list = DB::query("SELECT id, cle FROM ".PREFIX_BDD."itemsEvenement WHERE idEvenement=%i",$idEvenement);
			foreach ($list as $value) {
				// Il faut vérifier si $value['cle'] match $cle
				// debug: echo "$re ? ".$value['cle']." -> ".preg_match($re,$value['cle'])."<br>";
				if (preg_match($re,$value['cle'])==1)
				{
					// correspondance trouvée
					return self::getObject($value['id']);
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
		return (ClePartie::deleteList($options));
	}



}

?>
