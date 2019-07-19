<?php

namespace RouteController;
use ErrorController as EC;
use AuthController as AC;
use BDDObject\Partage;
use BDDObject\Evenement;

class partages
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

    public function fetch()
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
        $item = Partage::getObject($id);
        if ($item===null)
        {
            EC::set_error_code(404);
            return false;
        }

        if ($ac->isRedacteur() && ($ac->getLoggedUserId()!==$item->getIdProprietaire()) && ($ac->getLoggedUserId()!==$item->getIdRedacteur()))
        {
            EC::set_error_code(403);
            return false;
        }

        $values = $item->getValues();
        return $values;
    }

    public function fetchList()
    {
        $ac = new AC();
        if (!$ac->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }

        if ($ac->isRoot()) return Partage::getList(array("root"=>true));
        if ($ac->isRedacteur()) return Partage::getList(array('redacteur'=>$ac->getLoggedUserId()));

        EC::set_error_code(403);
        return false;
    }

    public function fetchEventList()
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
        $idEvenement = (integer) $this->params['id'];
        $evenement=Evenement::getObject($idEvenement);
        if ($evenement === null)
        {
            EC::set_error_code(404);
            return false;
        }
        if ($ac->isRedacteur() && ($ac->getLoggedUserId()!==$evenement->getIdProprietaire()))
        {
            EC::set_error_code(403);
            return false;
        }
        return array(
            "evenement"=> $evenement->getValues(),
            "partages" => Partage::getList(array("evenement"=>$idEvenement))
        );
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
        $item=Partage::getObject($id);
        if ($item === null)
        {
            EC::set_error_code(404);
            return false;
        }

        if ($ac->isRedacteur() && ($ac->getLoggedUserId()!==$item->getIdProprietaire()))
        {
            EC::set_error_code(403);
            return false;
        }

        if ($item->delete())
        {
            return array( "message" => "Model successfully destroyed!");
        }
        EC::set_error_code(501);
        return false;
    }

    public function insert()
    {
        // Seul un rédacteur peut créer un partage
        $ac = new AC();
        if (!$ac->isRedacteur())
        {
            EC::set_error_code(403);
            return false;
        }

        $data = json_decode(file_get_contents("php://input"),true);
        if (!isset($data['idEvenement']))
        {
            EC::set_error_code(501);
            return false;
        }
        $idEvenement = (integer) $data['idEvenement'];
        $evenement=Evenement::getObject($idEvenement);
        if ($evenement === null)
        {
            EC::set_error_code(404);
            return false;
        }
        if ($ac->isRedacteur() && ($ac->getLoggedUserId()!==$evenement->getIdProprietaire()))
        {
            EC::set_error_code(403);
            return false;
        }

        $item = new Partage();
        $validation = $item->insert_validation($data);
        if ($validation===true)
        {
            $id = $item->update($data);
        }
        if ($id!==null)
        {
            $user = $item->getRedacteur();
            $out = $item->getValues();
            $out["nom"] = $user->getValues()["nom"];
            return $out;
        }

        EC::set_error_code(501);
        return false;
    }

    public function update()
    {
        // Seul le rédacteur propriétaire peut changer un événement
        $ac = new AC();
        if (!$ac->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }
        if ((!$ac->isRedacteur()) && (!$ac->isRoot()))
        {
            EC::set_error_code(403);
            return false;
        }
        $id = (integer) $this->params['id'];
        $item=Partage::getObject($id);
        if ($item === null)
        {
            EC::set_error_code(404);
            return false;
        }

        if (!$ac->isRoot() && ($ac->getLoggedUserId()!==$item->getIdProprietaire()))
        {
            EC::set_error_code(403);
            return false;
        }

        $data = json_decode(file_get_contents("php://input"),true);

        $modOk=$item->update($data);
        if ($modOk === true)
        {
            return $item->getValues();
        }
        else
        {
            EC::set_error_code(501);
            return false;
        }
    }

    public function getUsersWithNoPartageList()
    {
        $ac = new AC();
        if (!$ac->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }
        if ((!$ac->isRedacteur()) && (!$ac->isRoot()))
        {
            EC::set_error_code(403);
            return false;
        }
        $idEvenement = (integer) $this->params['id'];
        $evenement=Evenement::getObject($idEvenement);
        if ($evenement === null)
        {
            EC::set_error_code(404);
            return false;
        }
        if (!$ac->isRoot() && ($ac->getLoggedUserId()!==$evenement->getIdProprietaire()))
        {
            EC::set_error_code(403);
            return false;
        }
        return $evenement->getRedacteursWithNoPartage();
    }

}
?>
