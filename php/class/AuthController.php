<?php
//use DB; inutile
//use MeekroDBException; inutile
use ErrorController as EC;
use SessionController as SC;

class AuthController
{
  /* Classe statique */
  const TIME_OUT = 5400; // durée d'inactivité avant déconnexion = 90min
  const SAVE_CONNEXION_ATTEMPTS_IN_BDD = true;

  const RANK_ROOT="root";
  const RANK_REDAC="redacteur";
  const RANK_JOUEUR="joueur";

  private $loggedUserData = null;

  ##################################### METHODES STATIQUES #####################################

  public function __construct()
  {
    // la sauvegarde de l'ip crée problème avec connexion sur portable
    //$loggedUserIp = SC::get()->getParam("loggedUserIp", null);
    $loggedUserData = SC::get()->getParam("loggedUserData", null);
    //if ( ($loggedUserIp == $_SERVER['REMOTE_ADDR']) && ($loggedUserData !==null) )
    if ( $loggedUserData !==null )
    {
      $this->loggedUserData = $loggedUserData;
    }
    else
    {
      EC::addDebugError("Pas de data user dans la session");
    }
  }

  private static function createSession($id, $nom, $username, $rank)
  {
    // $params est un tableau contenantms
    $loggedUserData = array(
      "nom" => $nom,
      "username" => $username,
      "rank" => $rank,
    );
    if ($id!==false){
      $loggedUserData["id"] = (integer) $id;
    }
    SC::get()->setParam('loggedUserData', $loggedUserData);
    // la sauvegarde de l'ip crée problème avec connexion sur portable
    // SC::get()->setParam('loggedUserIp', $_SERVER['REMOTE_ADDR']);
  }

  public static function tryLogin($username, $pwd, $adm)
  {
    // $adm true spécifie une connexion de rédac ou adm
    if ($username !== ''){
      if ($pwd === "") {
        EC::addError("Vous avez envoyé un mot de passe vide !");
        EC::set_error_code(422);
        return false;
      }

      if ($adm){
        // connexion rédac ou adm
        if ($username==ROOT_USERNAME){
          if ($pwd == ROOT_PASSWORD) {
            // succès de la connexion root
            self::createSession(false,"Root",ROOT_USERNAME,self::RANK_ROOT);
            return true;
          }
        } else {
          // sinon connexion rédacteur
          require_once BDD_CONFIG;
          try {
            $bdd_result = DB::queryFirstRow("SELECT id, nom, username, hash FROM ".PREFIX_BDD."redacteurs WHERE username=%s", $username);
          } catch(MeekroDBException $e) {
            EC::set_error_code(501);
            EC::addBDDError($e->getMessage(), 'AuthController/tryConnexion');
            return false;
          }

          if ($bdd_result !== null) {
            // L'id existe, reste à vérifier le mot de passe
            $hash = $bdd_result['hash'];
            if (($hash=="") || (password_verify($pwd, $hash))) {
              // Le hash correspond, connexion réussie
              self::createSession($bdd_result['id'], $bdd_result['nom'], $bdd_result['username'], self::RANK_REDAC);
              return true;
            }
          }
        }
      } else {
        require_once BDD_CONFIG;
        try {
          $bdd_result = DB::queryFirstRow("SELECT id, nom, username, hash FROM ".PREFIX_BDD."joueurs WHERE username=%s", $username);
        } catch(MeekroDBException $e) {
          EC::set_error_code(501);
          EC::addBDDError($e->getMessage(), 'AuthController/tryConnexion');
          return false;
        }

        if ($bdd_result !== null) {
          // L'id existe, reste à vérifier le mot de passe
          $hash = $bdd_result['hash'];
          if (($hash=="") || (password_verify($pwd, $hash))) {
            // Le hash correspond, connexion réussie
            self::createSession($bdd_result['id'], $bdd_result['nom'], $bdd_result['username'], self::RANK_JOUEUR);
            return true;
          }
        }
      }

    }
    EC::addError("Mot de passe ou identifiant/email invalide.");
    EC::set_error_code(422);
    return false;
  }

  // fonction de l'instance du controlleur

  public function connexionOk()
  {
    return ($this->loggedUserData !== null);
  }

  public function getloggedUserData()
  {
    if ($this->loggedUserData === null)
    {
      return null;
    }
    else
    {
      return array_merge($this->loggedUserData);
    }
  }

  public function getLoggedUserId()
  {
    if (($this->loggedUserData === null)||!isset($this->loggedUserData['id']))
    {
      return false;
    }
    return $this->loggedUserData['id'];
  }

  public function isRoot()
  {
    return (($this->loggedUserData !== null)&&($this->loggedUserData['rank'] == self::RANK_ROOT));
  }

  public function isRedacteur()
  {
    return (($this->loggedUserData !== null)&&($this->loggedUserData['rank'] == self::RANK_REDAC));
  }

  public function isJoueur()
  {
    return (($this->loggedUserData !== null)&&($this->loggedUserData['rank'] == self::RANK_JOUEUR));
  }


}

?>
