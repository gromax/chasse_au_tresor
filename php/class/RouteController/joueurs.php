<?php

namespace RouteController;
use ErrorController as EC;
use AuthController as AC;
use BDDObject\Joueur as Item;

class joueurs
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

        $id = (integer) $this->params['id'];
        if (!$ac->isRoot() && ($ac->getLoggedUserId()!==$id)) {
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
        $ac = new AC();
        if (!$ac->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }

        if ($ac->isRoot()) return Item::getList(array("root"=>true));
        EC::set_error_code(403);
        return false;
    }


    public function delete()
    {
        // Seul root peut effacer un joueur
        $ac = new AC();
        if (!$ac->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }
        if (!$ac->isRoot())
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
        $ac = new AC();
        if (!$ac->connexionOk())
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
        $ac = new AC();
        if (!$ac->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }

        $id = (integer) $this->params['id'];
        if (!$ac->isRoot()&& (!$ac->isJoueur() || !($ac->getLoggedUserId() == $id)))
        {
            // Seul root ou joueur soi-même peut faire la modif
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
