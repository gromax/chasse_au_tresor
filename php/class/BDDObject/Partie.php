<?php

namespace BDDObject;

use DB;
use ErrorController as EC;
use SessionController as SC;
use MeekroDBException;

use BDDObject\ClePartie;

final class Partie extends Item
{
	protected static $BDDName = "parties";

	##################################### METHODES STATIQUES #####################################

	protected static function champs()
	{
		return array(
			'idEvenement' => array( 'def' => 0, 'type' => 'integer'),	// id de l'événement lié
			'idProprietaire' => array( 'def' => 0, 'type'=> 'integer'),	// id du Joueur propriétaire
			'dateDebut' => array( 'def' => "", 'type'=> 'dateHeure'),	// date de création de la partie
			'fini' => array( 'def'=> false, 'type'=> 'boolean'),	// partie finie
			'dateFin' => array( 'def' => "", 'type'=> 'dateHeure'),	// date d'arrivée à l'item final
			);
	}

	public static function deleteList($options = array())
	{
		if (!ClePartie::deleteList($options))
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
				return DB::query("SELECT p.id, p.idEvenement, e.titre AS titreEvenement, p.idProprietaire, j.nom AS nomProprietaire, p.dateDebut, p.dateFin, p.fini FROM ((".PREFIX_BDD."parties p JOIN ".PREFIX_BDD."joueurs j ON j.id=p.idProprietaire) JOIN ".PREFIX_BDD."evenements e ON e.id=p.idEvenement) WHERE p.idProprietaire=%i", $options['joueur']);
			}
			elseif (isset($options['redacteur']))
			{
				return DB::query("SELECT p.id, p.idEvenement, e.titre AS titreEvenement, p.idProprietaire, j.nom AS nomProprietaire, p.dateDebut, p.dateFin, p.fini FROM ((".PREFIX_BDD."parties p JOIN ".PREFIX_BDD."joueurs j ON j.id=p.idProprietaire) JOIN ".PREFIX_BDD."evenements e ON e.id=p.idEvenement) WHERE e.idProprietaire=%i", $options['redacteur']);
			}
			elseif (isset($options['evenement']))
			{
				return DB::query("SELECT p.id, p.idEvenement, e.titre AS titreEvenement, p.idProprietaire, j.nom AS nomProprietaire, p.dateDebut, p.dateFin, p.fini FROM ((".PREFIX_BDD."parties p JOIN ".PREFIX_BDD."joueurs j ON j.id=p.idProprietaire) JOIN ".PREFIX_BDD."evenements e ON e.id=p.idEvenement) WHERE e.id=%i", $options['evenement']);
			}
			elseif (isset($options['root']))
			{
				return DB::query("SELECT p.id, p.idEvenement, e.titre AS titreEvenement, p.idProprietaire, j.nom AS nomProprietaire, p.dateDebut, p.dateFin, p.fini FROM ((".PREFIX_BDD."parties p JOIN ".PREFIX_BDD."joueurs j ON j.id=p.idProprietaire) JOIN ".PREFIX_BDD."evenements e ON e.id=p.idEvenement)");
			}
			else
			{
				return array();
			}

		} catch(MeekroDBException $e) {
			if (BDD_DEBUG_ON) return array('error'=>true, 'message'=>"#Partie/getList : ".$e->getMessage());
			return array('error'=>true, 'message'=>'Erreur BDD');
		}
	}

	##################################### METHODES #####################################

	public function customDelete()
	{
		$options = array("partie"=>$this->id);
		return ClePartie::deleteList($options);
	}

}

?>
