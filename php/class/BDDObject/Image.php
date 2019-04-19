<?php

namespace BDDObject;

use DB;
use ErrorController as EC;
use SessionController as SC;
use MeekroDBException;
use BDDObject\Evenement;

final class Image extends Item
{
	protected static $BDDName = "images";

	##################################### METHODES STATIQUES #####################################

	protected static function champs()
	{
		return array(
			'idEvenement' => array( 'def' => 0, 'type'=> 'integer'),	// id de l'événement lié
			'hash' => array( 'def' => "", 'type'=> 'string'),	// données paramétrant cet item
			'ext' => array( 'def' => "", 'type'=> 'string'),	// extension
			);
	}

	public static function deleteList($options = array())
	{
		if (self::SAVE_IN_SESSION) {
			SC::get()->unsetParam("images");
		}
		$list = self::getList($options);
		foreach ($list as $value) {
			if (file_exists(PATH_TO_UPLOAD.$value['hash']))
			{
				unlink(PATH_TO_UPLOAD.$value['hash']);
			}
		}
		require_once BDD_CONFIG;
		try {
			if (isset($options['redacteur'])) {
				DB::query("DELETE ".PREFIX_BDD."images FROM (".PREFIX_BDD."images JOIN ".PREFIX_BDD."evenements ON ".PREFIX_BDD."images.idEvenement = ".PREFIX_BDD."evenements.id) WHERE ".PREFIX_BDD."evenements.idProprietaire=%i", $options['redacteur']);
			} elseif (isset($options['evenement'])) {
				DB::delete(PREFIX_BDD."images", "idEvenement=%i", $options['evenement']);
			}
			return true;
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage(), "Images/Suppression liste");
		}
		return false;
	}

	public static function getList($options = array())
	{
		require_once BDD_CONFIG;
		try {
			if (isset($options['redacteur']))
				// rédacteur
				return DB::query("SELECT i.id, i.idEvenement, i.hash, i.ext FROM (".PREFIX_BDD."images i JOIN ".PREFIX_BDD."evenements e ON e.id = i.idEvenement) WHERE e.idProprietaire=%i", $options['redacteur']);
			elseif (isset($options['evenement']))
				return DB::query("SELECT id, idEvenement, hash, ext FROM ".PREFIX_BDD."images WHERE idEvenement=%i", $options['evenement']);
			elseif (isset($options['root']))
				return DB::query("SELECT id, idEvenement, hash, ext FROM ".PREFIX_BDD."images");
			else
				return array();

		} catch(MeekroDBException $e) {
			if (BDD_DEBUG_ON) return array('error'=>true, 'message'=>"#Images/getList : ".$e->getMessage());
			return array('error'=>true, 'message'=>'Erreur BDD');
		}
	}

	##################################### METHODES #####################################

	protected function custom_delete()
	{
		$filename = PATH_TO_UPLOAD.$this->hash;
		if (file_exists($filename))
		{
			unlink($filename);
		}
	}

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

	public function moveUploadedFile($uploadedFileName)
	{
		return move_uploaded_file($uploadedFileName, PATH_TO_UPLOAD.$this->values['hash']);
	}

}

?>
