<?php

namespace BDDObject;

use DB;
use ErrorController as EC;
use SessionController as SC;
use MeekroDBException;

final class ClePartie extends Item
{
	protected static $BDDName = "clesPartie";

	##################################### METHODES STATIQUES #####################################

	protected static function champs()
	{
		return array(
			'idPartie' => array( 'def' => 0, 'type'=> 'integer'),	// id de la partie liée
			'essai' => array( 'def' => "", 'type'=> 'string'),	// données décrivant la clé
			'data' => array( 'def' => "", 'type'=> 'string'),	// données décrivant les éventuelles réponses
			'date' => array( 'def' => "", 'type'=> 'dateHeure'),	// date de création
			);
	}

	public static function deleteList($options = array())
	{
		if (self::SAVE_IN_SESSION) {
			SC::get()->unsetParam("clesPartie");
		}
		require_once BDD_CONFIG;
		try {
			if (isset($options['redacteur'])) {
				DB::query("DELETE ".PREFIX_BDD."clesPartie FROM ((".PREFIX_BDD."clesPartie JOIN ".PREFIX_BDD."parties ON ".PREFIX_BDD."clesPartie.idPartie = ".PREFIX_BDD."parties.id) JOIN ".PREFIX_BDD."evenements ON ".PREFIX_BDD."parties.idEvenement = ".PREFIX_BDD."evenements.id) WHERE ".PREFIX_BDD."evenements.idProprietaire=%i", $options['redacteur']);
			} elseif (isset($options['joueur'])) {
				DB::query("DELETE ".PREFIX_BDD."clesPartie FROM (".PREFIX_BDD."clesPartie JOIN ".PREFIX_BDD."parties ON ".PREFIX_BDD."clesPartie.idPartie = ".PREFIX_BDD."parties.id) WHERE ".PREFIX_BDD."parties.idProprietaire=%i", $options['joueur']);
			} elseif (isset($options['evenement'])) {
				DB::query("DELETE ".PREFIX_BDD."clesPartie FROM (".PREFIX_BDD."clesPartie JOIN ".PREFIX_BDD."parties ON ".PREFIX_BDD."clesPartie.idPartie = ".PREFIX_BDD."parties.id) WHERE ".PREFIX_BDD."parties.idEvenement=%i", $options['evenement']);
			} elseif (isset($options['partie'])) {
				DB::delete(PREFIX_BDD."clesPartie", "idPartie=%i", $options['partie']);
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
				return DB::query("SELECT c.id, c.essai, c.date FROM (".PREFIX_BDD."cleParties c JOIN ".PREFIX_BDD."parties p ON p.id = c.idPartie) WHERE p.idProprietaire=%i", $options['joueur']);
			elseif (isset($options['redacteur']))
				return DB::query("SELECT c.id, c.essai, c.date FROM ((".PREFIX_BDD."cleParties c JOIN ".PREFIX_BDD."parties p ON p.id = c.idPartie) JOIN ".PREFIX_BDD."evenements e ON e.id = p.idEvenement) WHERE e.idProprietaire=%i", $options['redacteur']);
			elseif (isset($options['evenement']))
				return DB::query("SELECT c.id, c.essai, c.date FROM (".PREFIX_BDD."cleParties c JOIN ".PREFIX_BDD."parties p ON p.id = c.idPartie) WHERE p.idEvenement=%i", $options['evenement']);
			elseif (isset($options['partie']))
				return DB::query("SELECT id, essai, date FROM ".PREFIX_BDD."clesPartie WHERE idPartie=%i", $options['partie']);
			elseif (isset($options['root']))
				return DB::query("SELECT id, essai, date FROM ".PREFIX_BDD."clesPartie");
			else
				return array();

		} catch(MeekroDBException $e) {
			if (BDD_DEBUG_ON) return array('error'=>true, 'message'=>"#Redacteur/getList : ".$e->getMessage());
			return array('error'=>true, 'message'=>'Erreur BDD');
		}
	}

	##################################### METHODES #####################################

}

?>
