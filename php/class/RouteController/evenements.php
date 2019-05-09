<?php

namespace RouteController;
use ErrorController as EC;
use AuthController as AC;
use BDDObject\Evenement;
use BDDObject\ItemEvenement;


class evenements
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
        $item = Evenement::getObject($id);
        if ($item===null)
        {
            EC::set_error_code(404);
            return false;
        }

        if ($ac->isRedacteur() && ($ac->getLoggedUserId()!==$item->getIdProprietaire()))
        {
            EC::set_error_code(403);
            return false;
        }

        $values = $item->getValues();
        $values['cles'] = CleEvenement::getList(array('idEvenement'=>$id));
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

        if ($ac->isRoot()) return Evenement::getList(array("root"=>true));
        if ($ac->isRedacteur()) return Evenement::getList(array('redacteur'=>$ac->getLoggedUserId()));

        EC::set_error_code(403);
        return false;
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
        $item=Evenement::getObject($id);
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
        // Seul un rédacteur peut créer un événement
        $ac = new AC();
        if ($ac->isRedacteur())
        {
            $data = json_decode(file_get_contents("php://input"),true);
            $data['idProprietaire'] = $ac->getLoggedUserId();
            $item = new Evenement();
            $data["hash"] = bin2hex(random_bytes(20));
            $id = $item->update($data);
            if ($id!==null)
                $out = $item->getValues();
                $out["nomProprietaire"] = $ac->getloggedUserData()["nom"];
                return $out;
        }
        else
        {
            EC::set_error_code(403);
            return false;
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
        if (!$ac->isRedacteur()){
            EC::set_error_code(403);
            return false;
        }
        $id = (integer) $this->params['id'];
        $item=Evenement::getObject($id);
        if ($item === null)
        {
            EC::set_error_code(404);
            return false;
        }

        if ($ac->getLoggedUserId()!==$item->getIdProprietaire())
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

}
?>
