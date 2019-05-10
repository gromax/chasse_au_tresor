<?php

namespace BDDObject;

use DB;
use ErrorController as EC;
use SessionController as SC;
use MeekroDBException;

use BDDObject\Evenement;


final class Redacteur extends Item
{
	protected static $BDDName = "redacteurs";
	protected static $privates = "hash";

	##################################### METHODES STATIQUES #####################################

	protected static function champs()
	{
		return array(
			'nom' => array( 'def' => "", 'type' => 'string'),	// nom du rédacteur
			'username' => array( 'def' => "", 'type'=> 'string'),	// username du rédacteur
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
			$results = DB::query("SELECT id FROM ".PREFIX_BDD."users WHERE username=%s",$username);
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
				return DB::query("SELECT r.id, r.nom, r.username, (SELECT COUNT(e.id) FROM ".PREFIX_BDD."evenements e where e.idProprietaire = r.id) AS count_evenements FROM ".PREFIX_BDD."redacteurs r");
			else
				return array();
		} catch(MeekroDBException $e) {
			if (BDD_DEBUG_ON) return array('error'=>true, 'message'=>"#Redacteur/getList : ".$e->getMessage());
			return array('error'=>true, 'message'=>'Erreur BDD');
		}
	}


	##################################### METHODES #####################################

	public function update_validation($modifs=array(), $full=false)
	{
		if(isset($modifs['username']))
			$username = $modifs['username'];
		elseif ($full)
			$username = $this->values['username'];
		else
			$username = false;
		$errors = array();
		if ($username!==false){
			$username_errors = array();
			if (!self::checkEMail($username))
				$username_errors[] = "Email invalide.";
			if (self::usernameExists($username)!==false )
				$username_errors[] = "L'identifiant / email existe déjà.";
			if (count($username_errors)>0)
				$errors['username'] = $username_errors;
		}
		if ($full && ($this->values['hash']==="") && !isset($modifs['pwd']))
			$errors['pwd'] = "Mot de passe invalide";
		if (isset($modifs['pwd']) && !self::checkPwd($modifs['pwd']) )
			$errors['pwd'] = "Mot de passe invalide";
		if (count($errors)>0)
			return $errors;
		else
			return true;
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
		$options = array("redacteur"=>$this->id);
		return Evenement::deleteList($options);
	}

}

?>
