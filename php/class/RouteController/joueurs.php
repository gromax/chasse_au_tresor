<?php

namespace RouteController;
use ErrorController as EC;
use BDDObject\Joueur as Item;
use BDDObject\Logged;

class joueurs
{
    /**
     * paramères de la requète
     * @array
     */
    const $testMethod = "isJoueur"
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

        $id = (integer) $this->params['id'];
        if (!$uLog->isRoot() && ($uLog->getId()!==$id)) {
            EC::set_error_code(403);
            return false;
        }


        $user = Item::getObject($id);
        if ($user===null)
        {
            EC::set_error_code(404);
            return false;
        }

        return $user->getValues();
    }

    public function fetchList()
    {
        $uLog =Logged::getConnectedUser();
        if (!$uLog->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }

        if ($uLog->isRoot()) return Item::getList(array("root"=>true));
        EC::set_error_code(403);
        return false;
    }


    public function delete()
    {
        // Seul root peut effacer un rédacteur
        $uLog=Logged::getConnectedUser();
        if (!$uLog->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }
        if (!$uLog->isRoot())
        {
            EC::set_error_code(403);
            return false;
        }
        $id = (integer) $this->params['id'];
        $redac = Item::getObject($id);
        if ($redac === null)
        {
            EC::set_error_code(404);
            return false;
        }
        if ($redac->delete())
        {
            return array( "message" => "Model successfully destroyed!");
        }
        EC::set_error_code(501);
        return false;
    }

    public function insert()
    {
        $uLog=Logged::getConnectedUser();
        if ($uLog->isRoot())
        {
            $data = json_decode(file_get_contents("php://input"),true);
            $itAdd = new Item();
            $validation = $itAdd->update_validation($data, true);
            if ($validation === true)
            {
                $id = $itAdd->update($data);
                if ($id!==null)
                    return $itAdd->getValues();
            }
            else
            {
                EC::set_error_code(422);
                return array('errors'=>$validation);
            }

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
        $uLog=Logged::getConnectedUser();
        if (!$uLog->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }
        if (!$uLog->{static::testMethod}() && !$uLog->isRoot())
        {
            EC::set_error_code(403);
            return false;
        }

        $id = (integer) $this->params['id'];
        if ($uLog->{static::testMethod}() && ($uLog->getId() != $id)) {
            // Un rédacteur ne peut modifier que se modifier lui même
            EC::set_error_code(403);
            return false;
        }

        $data = json_decode(file_get_contents("php://input"),true);

        $userToMod = Item::getObject($id);
        if ($userToMod==null)
        {
            EC::set_error_code(404);
            return false;
        }

        $validation = $userToMod->update_validation($data);
        if ($validation === true)
        {
            $modOk=$userToMod->update($data);
            if ($modOk === true)
            {
                return $userToMod->getValues();
            }
            else
            {
                EC::set_error_code(501);
                return false;
            }
        }
        else
        {
            EC::set_error_code(422);
            return array('errors' => $validation);
        }
    }





}
?>
