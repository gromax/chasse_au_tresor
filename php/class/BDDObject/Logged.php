<?php
	// C'est la classe de l'utilisateur connecté

namespace BDDObject;
use DB;
use MeekroDBException;
use ErrorController as EC;
use SessionController as SC;

class Logged
{
	const	TIME_OUT = 5400; // durée d'inactivité avant déconnexion = 90min
	const	SAVE_CONNEXION_ATTEMPTS_IN_BDD = true;

	const	RANK_ROOT="root";
	const	RANK_REDAC="redacteur";
	const	RANK_JOUEUR="joueur";
	const	RANK_OFF="off";
	private static $_connectedUser=null;

	private $lastTime = null;
	private $ip = null;
	private $isConnected = null; 	// Permet d'éviter de répéter la modification de bdd en vas de plusieurs check de connexion

	private $nom = "Déconnecté";
	private $description = false;
	private $email = "";
	private $rank = false;
	private $id = false;

	##################################### METHODES STATIQUES #####################################

	public function __construct($params=array())
	{
		if(isset($params['email'])){
			$this->email = $params['email'];
		}
		if(isset($params['nom'])){
			$this->nom = $params['nom'];
		}
		if(isset($params['rank'])){
			$this->rank = $params['rank'];
		} else {
			$this->rank = self::RANK_OFF;
		}
		if(isset($params['id'])){
			$this->id = (integer) $params['id']; // pas pour root
		}
		if(isset($params['description'])){
			$this->description = (integer) $params['description']; // seulement pour joueur
		}

		$this->ip=$_SERVER['REMOTE_ADDR'];
		$this->refreshTimeOut();
	}

	public static function getConnectedUser($force = false)
	{
		if ( (self::$_connectedUser === null) || ($force === true) ) {
			$trySession = SC::get()->getParam('user', null);
			if (($trySession instanceof Logged) && $trySession->connexionOk())
			{
				self::$_connectedUser = $trySession;
			}
			else
			{
				self::$_connectedUser = new Logged();
			}
		}
		return self::$_connectedUser;
	}


	public static function tryConnexion($identifiant, $pwd, $adm)
	{
		// $adm true spécifie une connexion de rédac ou adm
		if ($identifiant !== ''){
			if ($pwd === "") {
				EC::addError("Vous avez envoyé un mot de passe vide !");
				EC::set_error_code(422);
				return null;
			}

			if ($adm){
				// connexion rédac ou adm
				if ($identifiant==ROOT_USERNAME){
					if (password_verify($pwd, ROOT_PASSWORD_HASH)) {
						// succès de la connexion root

						return (new Logged(array("id"=>-1, "nom"=>"Root", "email"=>ROOT_USERNAME, "rank"=>self::RANK_ROOT)))->setConnectedUser();
					}
				} else {
					// sinon connexion rédacteur
					require_once BDD_CONFIG;
					try {
						$bdd_result = DB::queryFirstRow("SELECT id, nom, email, hash FROM ".PREFIX_BDD."redacteurs WHERE email=%s", $identifiant);
					} catch(MeekroDBException $e) {
						EC::set_error_code(501);
						EC::addBDDError($e->getMessage(), 'Logged/tryConnexion');
						return null;
					}

					if ($bdd_result !== null) {
						// L'id existe, reste à vérifier le mot de passe
						$hash = $bdd_result['hash'];
						if (($hash=="") || (password_verify($pwd, $hash))) {
							// Le hash correspond, connexion réussie
							$bdd_result['rank'] = self::RANK_REDAC;
							return (new Logged($bdd_result))->setConnectedUser();
						}
					}
				}
			} else {
				require_once BDD_CONFIG;
				try {
					$bdd_result = DB::queryFirstRow("SELECT id, nom, description, email, hash FROM ".PREFIX_BDD."joueurs WHERE email=%s", $identifiant);
				} catch(MeekroDBException $e) {
					EC::set_error_code(501);
					EC::addBDDError($e->getMessage(), 'Logged/tryConnexion');
					return null;
				}

				if ($bdd_result !== null) {
					// L'id existe, reste à vérifier le mot de passe
					$hash = $bdd_result['hash'];
					if (($hash=="") || (password_verify($pwd, $hash))) {
						// Le hash correspond, connexion réussie
						$bdd_result['rank'] = self::RANK_JOUEUR;
						return (new Logged($bdd_result))->setConnectedUser();
					}
				}
			}

		}
		EC::addError("Mot de passe ou identifiant invalide.");
		EC::set_error_code(422);
		return null;
	}

	public static function setUser($user)
	{
		return (new Logged($user->toArray()))->updateTime()->setConnectedUser();
	}

	##################################### METHODES #####################################

	public function __wakeup()
	{
		$this->isConnected=null; // Réinitialise le flag de connexion au moment du redémarrage de la session
	}

	public function __sleep()
	{
		return array_keys(get_object_vars($this));
	}

	private function refreshTimeOut()
	{
		$this->lastTime=time();
		return $this;
	}

	public function setConnectedUser()
	{
		SC::get()->setParam('user',$this);
		return self::getConnectedUser(true);
	}

	public function connexionOk()
	{
		if ($this->isConnected === null){
			if ($this->rank==self::RANK_OFF) $this->isConnected=false;
			else {
				//$this->isConnected= ( ((time()-$this->lastTime)<self::TIME_OUT) && ($this->ip == $_SERVER['REMOTE_ADDR']) && ($this->id !== null));
				$this->isConnected= ( ((time()-$this->lastTime)<self::TIME_OUT) && ($this->id !== null));
			}
		}
		if ($this->isConnected) $this->lastTime = time();
		return ($this->isConnected === true);
	}

	public function toArray()
	{
		if($this->rank == self::RANK_ROOT){
			return array("nom"=>$this->nom, "rank"=>self::RANK_ROOT, "logged_in"=>true);
		} elseif ($this->rank == self::RANK_REDAC){
			return array("id"=>$this->id, "nom"=>$this->nom, "email"=>$this->email, "rank"=>self::RANK_REDAC, "logged_in"=>true);
		} elseif ($this->rank == self::RANK_JOUEUR){
			return array("id"=>$this->id, "nom"=>$this->nom, "description"=>$this->description, "email"=>$this->email, "rank"=>self::RANK_JOUEUR, "logged_in"=>true);
		} else {
			return array("nom"=>$this->nom, "rank"=>self::RANK_OFF, "logged_in"=>false);
		}
	}

	public function isRoot()
	{
		return $this->rank == self::RANK_ROOT;
	}

	public function isRedacteur()
	{
		return $this->rank == self::RANK_REDAC;
	}

	public function isJoueur()
	{
		return $this->rank == self::RANK_JOUEUR;
	}

	public function getId()
	{
		return $this->id;
	}

}

?>
