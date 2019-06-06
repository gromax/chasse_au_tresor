<?php

namespace BDDObject;

use DB;
use ErrorController as EC;
use SessionController as SC;
use MeekroDBException;

use BDDObject\Partie;

final class Joueur extends Item
{
	protected static $BDDName = "joueurs";
	protected static $privates = "hash";

	##################################### METHODES STATIQUES #####################################

	protected static function champs()
	{
		return array(
			'nom' => array( 'def' => "", 'type' => 'string'),	// nom du joueur
			'username' => array( 'def' => "", 'type'=> 'string'),	// username ou identifiant du joueur
			'hash' => array( 'def' => "", 'type'=> 'string'),	// hash du mdp
			);
	}

	public static function checkPwd($pwd)
	{
		return true;
	}

	public static function checkEMail($email)
	{
		return preg_match("#^[a-zA-Z0-9_-]+(.[a-zA-Z0-9_-]+)*@[a-zA-Z0-9._-]{2,}\.[a-z]{2,4}$#", $email);
	}

	public static function usernameExists($username)
	{
		if ($username==ROOT_USERNAME)
			return true;

		require_once BDD_CONFIG;
		try {
			// Vérification que l'username
			$results = DB::query("SELECT id FROM ".PREFIX_BDD."joueurs WHERE username=%s",$username);
			if (DB::count()>0) return $results[0]["id"];
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage());
		}
		return false;
	}

	public static function getList($options = array())
	{
		require_once BDD_CONFIG;
		try {
			if (isset($options['root']))
				return DB::query("SELECT j.id, j.nom, j.username, (SELECT COUNT(p.id) FROM ".PREFIX_BDD."parties p where p.idProprietaire = j.id) AS count_parties FROM ".PREFIX_BDD."joueurs j");
			else
				return array();
		} catch(MeekroDBException $e) {
			if (DEV) return array('error'=>true, 'message'=>"#Joueur/getList : ".$e->getMessage());
			return array('error'=>true, 'message'=>'Erreur BDD');
		}
	}

	##################################### METHODES #####################################

	public function update_validation($modifs=array())
	{
		if(isset($modifs['username']))
		{
			$username = $modifs['username'];
		}
		else
		{
			$username = false;
		}
		$errors = array();
		// $username == false et $this->values['username']==="" -> erreur
		// test uniquement si $username !==false et $username !== $this->values['username']
		if (($username===false)&&($this->values['username']===""))
		{
			$errors['username'] = "L'identifiant / email indéfini.";
		}
		elseif (($username!==false)&&($username!=$this->values['username'])&&(self::usernameExists($username)!==false ))
		{
			$errors['username'] = "L'identifiant / email existe déjà.";
		}
		if (($this->values['hash']==="") && !isset($modifs['pwd']))
		{
			$errors['pwd'] = "Mot de passe invalide";
		}
		if (isset($modifs['pwd']) && (self::checkPwd($modifs['pwd'])!==true) )
		{
			$errors['pwd'] = "Mot de passe invalide";
		}
		if (count($errors)>0)
		{
			return $errors;
		}
		else
		{
			return true;
		}
	}

	public function parseBeforeUpdate($modifs)
	{
		if (isset($modifs['pwd']))
			$modifs['hash'] = password_hash($modifs['pwd'],PASSWORD_DEFAULT);
			unset($modifs['pwd']);
		return $modifs;
	}

	public function customDelete()
	{
		$options = array("joueur"=>$this->id);
		return Partie::deleteList($options);
	}

	public function addHashForPasswordLost()
	{
		$hash = bin2hex(random_bytes(20));
		$values = array( "hash"=>$hash, "idProprietaire"=>$this->id, "type"=>JOUEUR_PWD_LOST);
		require_once BDD_CONFIG;
		try {
			DB::insert(PREFIX_BDD."hashs", $values);
			return $hash;
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage());
		}
		return false;
	}

	public function resetHashsForPasswordLost()
	{
		require_once BDD_CONFIG;
		try {
			DB::delete(PREFIX_BDD."hashs", "idProprietaire=%i AND type=".JOUEUR_PWD_LOST, $this->id);
			return true;
		} catch(MeekroDBException $e) {
			EC::addBDDError($e->getMessage());
		}
		return false;
	}

}

?>
