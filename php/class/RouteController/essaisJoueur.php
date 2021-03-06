<?php

namespace RouteController;
use ErrorController as EC;
use AuthController as AC;
use BDDObject\EssaiJoueur;
use BDDObject\Partie;

class essaisJoueur
{
    /**
     * paramères de la requète
     * @array
     */
    private $params;
    /**
     * Constructeur
     */
    public function __construct($params)
    {
        $this->params = $params;
    }

    public function delete()
    {
        $ac = new AC();
        if (!$ac->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }

        if (!$ac->isRoot() && !$ac->isRedacteur()) {
            EC::set_error_code(403);
            return false;
        }

        $id = (integer) $this->params['id'];
        $item=EssaiJoueur::getObject($id);
        if ($item === null)
        {
            EC::set_error_code(404);
            return false;
        }

        if ($ac->isRedacteur())
        {
            $partie = $item->getPartie();
            if ($partie === null)
            {
                EC::set_error_code(501);
                return false;
            }
            $evenement = $partie->getEvenement();
            if ($evenement === null)
            {
                EC::set_error_code(501);
                return false;
            }
            if ($evenement->getIdProprietaire() !== $ac->getLoggedUserId())
            {
                EC::set_error_code(403);
                return false;
            }
        }
        if ($item->delete())
        {
            return array( "message" => "Model successfully destroyed!");
        }
        EC::set_error_code(501);
        return false;
    }

    public function getCount()
    {
        $ac = new AC();
        if (!$ac->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }
        if (!$ac->isJoueur()) {
            EC::set_error_code(403);
            return false;
        }
        $id = (integer) $this->params['id'];
        $idJoueur = $ac->getLoggedUserId();
        $partie=Partie::getObject($id);
        if ($partie===null)
        {
            EC::set_error_code(404);
            return false;
        }
        if ($partie->getIdProprietaire() !== $idJoueur)
        {
            var_dump($idJoueur);
            var_dump($partie->getIdProprietaire());

            EC::set_error_code(403);
            return false;
        }
        $cnt = EssaiJoueur::getOkCount($id);
        if ($cnt===null)
        {
            EC::set_error_code(501);
            return false;
        }
        return array("cnt"=>$cnt);
    }



}
?>
