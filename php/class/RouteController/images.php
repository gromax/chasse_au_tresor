<?php

namespace RouteController;
use ErrorController as EC;
use BDDObject\Image;
use BDDObject\Logged;

class itemsEvenement
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
        // Rédacteur seul
        $uLog =Logged::getConnectedUser();
        if (!$uLog->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }

        if (!$uLog->isRedacteur()) {
            EC::set_error_code(403);
            return false;
        }

        $id = (integer) $this->params['id'];
        $item = Image::getObject($id);
        if ($item===null)
        {
            EC::set_error_code(404);
            return false;
        }

        if ($uLog->getId()!==$item->getIdProprietaire())
        {
            EC::set_error_code(403);
            return false;
        }

        return $item->getValues();
    }

    public function delete()
    {
        // Rédacteur seul
        $uLog=Logged::getConnectedUser();
        if (!$uLog->connexionOk())
        {
            EC::set_error_code(401);
            return false;
        }

        if (!$uLog->isRedacteur()) {
            EC::set_error_code(403);
            return false;
        }

        $id = (integer) $this->params['id'];
        $item=Image::getObject($id);
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

        if ($item->delete())
        {
            return array("message" => "Model successfully destroyed!");
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
            if (isset($_FILES['image']) && isset($data['idEvenement']))
            {
                $file = $_FILES['image']['tmp_name'];
                $hash = md5_file($file);
                $data['hash'] = $hash;
                $item = new Image($data);
                $item->moveUploadedFile($file);
                $id = $item->update($data);
                if ($id!==null)
                {
                    return $item->getValues();
                }
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
        // Effacé et remplacé, jamais modifié
        EC::set_error_code(501);
        return false;
    }

}
?>
