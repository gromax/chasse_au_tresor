<?php

namespace RouteController;
use ErrorController as EC;
use BDDObject\Evenement;
use BDDObject\ItemEvenement;
use BDDObject\Logged;

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
        $uLog =Logged::getConnectedUser();
        if (!$uLog->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }

        if (!$uLog->isRoot() && !$uLog->isRedacteur()) {
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

        if ($uLog->isRedacteur() && ($uLog->getId()!==$item->getIdProprietaire()))
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
        $uLog =Logged::getConnectedUser();
        if (!$uLog->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }

        if ($uLog->isRoot()) return Evenement::getList(array("root"=>true));
        if ($uLog->isRedacteur()) return Evenement::getList(array('redacteur'=>$uLog->getId()));

        EC::set_error_code(403);
        return false;
    }


    public function delete()
    {
        $uLog=Logged::getConnectedUser();
        if (!$uLog->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }

        if (!$uLog->isRoot() && !$uLog->isRedacteur()) {
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

        if ($uLog->isRedacteur() && ($uLog->getId()!==$item->getIdProprietaire()))
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
        $uLog=Logged::getConnectedUser();
        if ($uLog->isRedacteur())
        {
            $data = json_decode(file_get_contents("php://input"),true);
            $data['idProprietaire'] = $uLog->getId();
            $item = new Evenement();
            $id = $item->update($data);
            if ($id!==null)
                $out = $item->getValues();
                $out["nomProprietaire"] = $uLog->toArray()["nom"];
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
        $uLog=Logged::getConnectedUser();
        if (!$uLog->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }
        if (!$uLog->isRedacteur()){
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

        if ($uLog->getId()!==$item->getIdProprietaire())
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
