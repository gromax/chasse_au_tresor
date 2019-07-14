<?php

namespace RouteController;
use ErrorController as EC;
use AuthController as AC;
use BDDObject\User;

class redacteurs
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
        // Seul root peut effacer un rédacteur
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
        $redac = User::getObject($id);
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
        if ($ac->isRoot())
        {
            $data = json_decode(file_get_contents("php://input"),true);
            $data['isredac'] = 1;
            $itAdd = new User();
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
            // Seuls admin et root peuvent créer des utilisateurs
            EC::set_error_code(403);
            return false;
        }
        EC::set_error_code(501);
        return false;
    }

    public function update()
    {
        // Seul un utilisateur peut changer ses propres paramètres
        $ac = new AC();
        if (!$ac->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }

        $id = (integer) $this->params['id'];
        if (!$ac->isRoot() && (!$ac->isRedacteur() || ($ac->getLoggedUserId() != $id)))
        {
            // Seul root ou rédacteur soi même peut modifier
            EC::set_error_code(403);
            return false;
        }

        $data = json_decode(file_get_contents("php://input"),true);

        $userToMod = User::getObject($id);
        if ($userToMod==null)
        {
            EC::set_error_code(404);
            return false;
        }

        $validation = $userToMod->update_validation($data);
        if ($validation === true)
        {
            unset($data["isredac"]); // ne peut être modifié
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
